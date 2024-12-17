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
from .stack cimport new_gen, new_gen_noclear, clone_gen_noclear, DetachGen
from .gen cimport objtogen

try:
    from inspect import getfullargspec as getargspec
except ImportError:
    from inspect import getargspec


cdef inline GEN call_python_func_impl "call_python_func"(GEN* args, object py_func) except NULL:
    """
    Call ``py_func(*args)`` where ``py_func`` is a Python function
    and ``args`` is an array of ``GEN``s terminated by ``NULL``.

    The arguments are converted from ``GEN`` to a cypari ``gen`` before
    calling ``py_func``. The result is converted back to a PARI ``GEN``.
    """
    # We need to ensure that nothing above avma is touched
    avmaguard = new_gen_noclear(<GEN>avma)

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

    # Call the Python function
    r = PyObject_Call(py_func, t, <dict>NULL)

    # Convert the result to a GEN and copy it to the PARI stack
    # (with a special case for None)
    if r is None:
        return gnil

    # Safely delete r and avmaguard
    d = DetachGen(objtogen(r))
    del r
    res = d.detach()
    d = DetachGen(avmaguard)
    del avmaguard
    d.detach()

    return res


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
    PariError: call_python: too many parameters in user-defined function call
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
