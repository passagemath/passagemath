# sage_setup: distribution = sagemath-pari
"""
Convert Python functions to PARI closures
*****************************************

AUTHORS:

- Jeroen Demeyer (2015-04-10): initial version, :trac:`18052`.

Examples:

>>> def the_answer():
...     return 42
>>> import cypari2
>>> pari = cypari2.Pari()
>>> f = pari(the_answer)
>>> f()
42

>>> cube = pari(lambda i: i**3)
>>> cube.apply(range(10))
[0, 1, 8, 27, 64, 125, 216, 343, 512, 729]
"""

# ****************************************************************************
#       Copyright (C) 2015 Jeroen Demeyer <jdemeyer@cage.ugent.be>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from cysignals.signals cimport sig_on, sig_off, sig_block, sig_unblock, sig_error

from cpython.tuple cimport *
from cpython.object cimport PyObject_Call
from cpython.ref cimport Py_INCREF

from .paridecl cimport *
from .stack cimport (new_gen, new_gen_noclear, clone_gen_noclear, DetachGen,
                     callback_stack_limit, move_gens_above_to_heap)
from .gen cimport objtogen
from .types cimport gp_context
from .paripriv cimport mt_is_thread

include "callback_signals.pxi"

try:
    from inspect import getfullargspec as getargspec
except ImportError:
    from inspect import getargspec


# Nested Python callbacks share the calling thread's PARI evaluator.
# A PARI error invalidates every enclosing callback's saved context.
cdef list callback_errors = []

cdef void note_callback_pari_error():
    for i in range(len(callback_errors)):
        callback_errors[i] = True

cdef gp_context *enclosing_callback = NULL

cdef extern from "pari/pari.h":
    void *iferr_env

cdef inline GEN call_python_func_impl(GEN* args, object py_func) except NULL:
    """
    Call ``py_func(*args)`` where ``py_func`` is a Python function
    and ``args`` is an array of ``GEN``s terminated by ``NULL``.

    The arguments are converted from ``GEN`` to a cypari ``gen`` before
    calling ``py_func``. The result is converted back to a PARI ``GEN``.
    """
    # Use a real stack object as the boundary, since callbacks may clone it.
    avmaguard = new_gen_noclear(cgetg(1, t_VEC))

    # How many arguments are there?
    cdef Py_ssize_t n = 0
    while args[n] is not NULL:
        n += 1

    # Construct a Python tuple for args
    cdef tuple t = PyTuple_New(n)
    cdef Py_ssize_t i
    for i in range(n):
        a = clone_gen_noclear(args[i])
        Py_INCREF(a)  # Need to increase refcount because the tuple steals it
        PyTuple_SET_ITEM(t, i, a)

    # Call the Python function.  Give PARI operations made by the callback a
    # nested cysignals jump target, so their errors return through Python
    # normally instead of jumping across the callback's Python frames.
    cdef void *signal_state = NULL
    cdef bint callback_had_pari_error = False
    cdef GEN res = gnil
    converted = None
    callback_errors.append(False)
    try:
        signal_state = callback_signal_push()
        try:
            r = PyObject_Call(py_func, t, <dict>NULL)
            if callback_errors[-1]:
                raise RuntimeError(
                    "a PARI error cannot be caught and suppressed inside a "
                    "Python callback; the enclosing PARI evaluation was aborted"
                )
            if r is not None:
                converted = objtogen(r)
                if callback_errors[-1]:
                    raise RuntimeError(
                        "a PARI error cannot be caught and suppressed while "
                        "converting a Python callback result; the enclosing "
                        "PARI evaluation was aborted"
                    )
        finally:
            # A callback or its result conversion can retain a Gen through a
            # side effect instead of returning it.  Clone every stack Gen
            # above the guard while the nested signal target is still active.
            # If the guard was already cloned, this also handles Gens created
            # after that move.
            move_gens_above_to_heap(avmaguard)

        if r is not None:
            d = DetachGen(converted)
            del converted
            del r
            res = d.detach()
        d = DetachGen(avmaguard)
        del avmaguard
        d.detach()
    finally:
        callback_signal_pop(signal_state)
        callback_had_pari_error = callback_errors.pop()

    if callback_had_pari_error:
        raise RuntimeError(
            "a PARI error cannot be caught and suppressed inside a Python "
            "callback; the enclosing PARI evaluation was aborted"
        )

    return res


cdef GEN call_python_with_context "call_python_func"(GEN* args, object py_func) except NULL:
    global enclosing_callback, iferr_env, callback_stack_limit
    cdef pari_sp previous_limit = callback_stack_limit
    callback_stack_limit = avma
    cdef gp_context context
    cdef gp_context *parent = enclosing_callback
    gp_context_save(&context)
    enclosing_callback = &context
    # A nested PARI error must return through the Python callback before
    # control can go back to an enclosing GP iferr handler.
    iferr_env = NULL
    try:
        result = call_python_func_impl(args, py_func)
    except BaseException:
        if parent != NULL and not callback_errors[-1]:
            # Unwind the abandoned GP frames, preserving user variables and
            # live Gen objects created by the enclosing Python callback.
            gp_context_save(&context)
            context.eval = parent.eval
            context.eval.avma = avma
            context.parse = parent.parse
            context.err_data = parent.err_data
            context.iferr_env = NULL
            gp_context_restore(&context)
        raise
    else:
        iferr_env = context.iferr_env
        return result
    finally:
        enclosing_callback = parent
        callback_stack_limit = previous_limit


# We rename this function to be able to call it with a different
# signature. In particular, we want manual exception handling and we
# implicitly convert py_func from a PyObject* to an object.
cdef extern from *:
    GEN call_python_func(GEN* args, PyObject* py_func)


cdef GEN call_python(GEN arg1, GEN arg2, GEN arg3, GEN arg4, GEN arg5,
                     ulong nargs, ulong py_func) noexcept:
    """
    This function, which will be installed in PARI, is a front-end for
    ``call_python_func_impl``.

    It has 5 optional ``GEN``s as argument, a ``nargs`` argument
    specifying how many arguments are valid and one ``ulong``, which is
    actually a Python callable object cast to ``ulong``.
    """
    # PARI's pthread workers do not own the Python GIL and cannot safely
    # enter this callback.  Report the condition through PARI's worker error
    # channel without touching the Python C API.  Users can still use a
    # Python callback with parallel APIs after setting ``nbthreads`` to 1;
    # native PARI closures remain fully parallel.
    global iferr_env
    if mt_is_thread():
        pari_err(e_MISC, "Python callbacks cannot run in PARI worker threads; set nbthreads to 1")
        return NULL

    if nargs > 5:
        sig_error()

    # Convert arguments to a NULL-terminated array.
    cdef GEN args[6]
    args[0] = arg1
    args[1] = arg2
    args[2] = arg3
    args[3] = arg4
    args[4] = arg5
    args[nargs] = NULL

    sig_block()
    # Disallow interrupts during the Python code inside
    # call_python_func_impl(). We need to do this because this function
    # is very likely called within sig_on() and interrupting arbitrary
    # Python code is bad.
    cdef GEN r = call_python_func(args, <PyObject*>py_func)
    sig_unblock()
    if not r:  # An exception was raised
        if enclosing_callback == NULL:
            # A direct jump out of PARI would leave its evaluator pointing at
            # the abandoned closure. Use normal PARI recovery, bypassing GP
            # iferr handlers because the pending exception belongs to Python.
            iferr_env = NULL
            pari_err(e_MISC, "Python callback failed")
        sig_error()
    return r


# Install the function "call_python" for use in the PARI library.
cdef entree* ep_call_python

cdef int _pari_init_closure() except -1:
    sig_on()
    global ep_call_python
    ep_call_python = install(<void*>call_python, "call_python", 'DGDGDGDGDGD5,U,U')
    sig_off()


cpdef Gen objtoclosure(f):
    """
    Convert a Python function (more generally, any callable) to a PARI
    ``t_CLOSURE``.

    .. NOTE::

        With the current implementation, the function can be called
        with at most 5 arguments.

    .. WARNING::

        The function ``f`` which is called through the closure cannot
        be interrupted. Therefore, it is advised to use this only for
        simple functions which do not take a long time.

    Examples:

    >>> from cypari2.closure import objtoclosure
    >>> def pymul(i,j): return i*j
    >>> mul = objtoclosure(pymul)
    >>> mul
    (v1,v2)->call_python(v1,v2,0,0,0,2,...)
    >>> mul(6,9)
    54
    >>> mul.type()
    't_CLOSURE'
    >>> mul.arity()
    2
    >>> def printme(x):
    ...     print(x)
    >>> objtoclosure(printme)('matid(2)')
    [1, 0; 0, 1]

    Construct the Riemann zeta function using a closure:

    >>> from cypari2 import Pari; pari = Pari()
    >>> def coeffs(n):
    ...     return [1 for i in range(n)]
    >>> Z = pari.lfuncreate([coeffs, 0, [0], 1, 1, 1, 1])
    >>> Z.lfun(2)
    1.64493406684823

    A trivial closure:

    >>> f = pari(lambda x: x)
    >>> f(10)
    10

    Test various kinds of errors:

    >>> mul(4)
    Traceback (most recent call last):
    ...
    TypeError: pymul() ...
    >>> mul(None, None)
    Traceback (most recent call last):
    ...
    ValueError: Cannot convert None to pari
    >>> mul(*range(100))
    Traceback (most recent call last):
    ...
    PariError: too many parameters in user-defined function call
    >>> mul([1], [2])
    Traceback (most recent call last):
    ...
    PariError: call_python: ...
    """
    if not callable(f):
        raise TypeError("argument to objtoclosure() must be callable")

    # Determine number of arguments of f
    cdef Py_ssize_t i, nargs
    try:
        argspec = getargspec(f)
    except Exception:
        nargs = 5
    else:
        nargs = len(argspec.args)

    # Only 5 arguments are supported for now...
    if nargs > 5:
        nargs = 5

    # Fill in default arguments of PARI function
    sig_on()
    cdef GEN args = cgetg((5 - nargs) + 2 + 1, t_VEC)
    for i in range(5 - nargs):
        set_gel(args, i + 1, gnil)
    set_gel(args, (5 - nargs) + 1, stoi(nargs))
    # Convert f to a t_INT containing the address of f
    set_gel(args, (5 - nargs) + 1 + 1, utoi(<ulong><PyObject*>f))

    # Create a t_CLOSURE which calls call_python() with py_func equal to f
    cdef Gen res = new_gen(snm_closure(ep_call_python, args))

    # We need to keep a reference to f somewhere and there is no way to
    # have PARI handle this reference for us. So the only way out is to
    # force f to be never deallocated
    Py_INCREF(f)

    return res
