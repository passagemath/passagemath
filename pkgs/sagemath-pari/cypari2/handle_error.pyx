# sage_setup: distribution = sagemath-pari
"""
Handling PARI errors
********************

AUTHORS:

- Peter Bruin (September 2013): initial version (:trac:`9640`)

- Jeroen Demeyer (January 2015): use ``cb_pari_err_handle`` (:trac:`14894`)

"""

# ****************************************************************************
#       Copyright (C) 2013 Peter Bruin
#       Copyright (C) 2015 Jeroen Demeyer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from cpython cimport PyErr_Occurred

from cysignals.signals cimport sig_block, sig_unblock, sig_error

from .paridecl cimport *
from .paripriv cimport *
from .stack cimport clone_gen_noclear, reset_avma, after_resize


# We derive PariError from RuntimeError, for backward compatibility with
# code that catches the latter.
class PariError(RuntimeError):
    """
    Error raised by PARI
    """
    def errnum(self):
        r"""
        Return the PARI error number corresponding to this exception.

        EXAMPLES:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> try:
        ...     pari('1/0')
        ... except PariError as err:
        ...     print(err.errnum())
        31
        """
        return self.args[0]

    def errtext(self):
        """
        Return the message output by PARI when this error occurred.

        EXAMPLES:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> try:
        ...     pari('pi()')
        ... except PariError as e:
        ...     print(e.errtext())
        not a function in function call
        """
        return self.args[1]

    def errdata(self):
        """
        Return the error data (a ``t_ERROR`` gen) corresponding to this
        error.

        EXAMPLES:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> try:
        ...     pari('Mod(2,6)')**-1
        ... except PariError as e:
        ...     E = e.errdata()
        >>> E
        error("impossible inverse in Fp_inv: Mod(2, 6).")
        >>> E.component(2)
        Mod(2, 6)
        """
        return self.args[2]

    def __repr__(self):
        r"""
        TESTS:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> PariError(11)
        PariError(11)
        """
        return "PariError(%d)" % self.errnum()

    def __str__(self):
        r"""
        Return a suitable message for displaying this exception.

        This is simply the error text with certain trailing characters
        stripped.

        EXAMPLES:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> try:
        ...     pari('1/0')
        ... except PariError as err:
        ...     print(err)
        _/_: impossible inverse in gdiv: 0

        A syntax error:

        >>> pari('!@#$%^&*()')
        Traceback (most recent call last):
        ...
        PariError: syntax error, unexpected ...
        """
        return self.errtext().rstrip(" .:")


cdef void _pari_init_error_handling() noexcept:
    """
    Set up our code for handling PARI errors.

    TESTS:

    >>> import cypari2
    >>> pari = cypari2.Pari()
    >>> try:
    ...     p = pari.polcyclo(-1)
    ... except PariError as e:
    ...     print(e.errtext())
    domain error in polcyclo: index <= 0

    Warnings still work just like in GP::

    >>> pari('warning("test")')
    """
    global cb_pari_err_handle
    global cb_pari_err_recover
    cb_pari_err_handle = _pari_err_handle
    cb_pari_err_recover = _pari_err_recover


cdef int _pari_err_handle(GEN E) except 0:
    """
    Convert a PARI error into a Python exception.

    This function is a callback from the PARI error handler.

    EXAMPLES:

    >>> import cypari2
    >>> pari = cypari2.Pari()
    >>> pari('error("test")')
    Traceback (most recent call last):
    ...
    PariError: error: user error: test
    >>> pari(1)/pari(0)
    Traceback (most recent call last):
    ...
    PariError: impossible inverse in gdiv: 0

    Test exceptions with a pointer to a PARI object:

    >>> from cypari2 import Pari
    >>> def exc():
    ...     K = Pari().nfinit("x^2 + 1")
    ...     I = K.idealhnf(2)
    ...     I[0]
    ...     try:
    ...         K.idealaddtoone(I, I)
    ...     except RuntimeError as e:
    ...         return e
    >>> L = [exc(), exc()]
    >>> print(L[0])
    elements not coprime in idealaddtoone:
        [2, 0; 0, 2]
        [2, 0; 0, 2]
    """
    cdef long errnum = E[1]
    cdef char* errstr
    cdef const char* s

    if errnum == e_STACK:
        # Custom error message for PARI stack overflow
        pari_error_string = "the PARI stack overflows (current size: {}; maximum size: {})\n"
        pari_error_string += "You can use pari.allocatemem() to change the stack size and try again"
        pari_error_string = pari_error_string.format(pari_mainstack.size, pari_mainstack.vsize)
    else:
        sig_block()
        try:
            errstr = pari_err2str(E)
            pari_error_string = errstr.decode('ascii')
            pari_free(errstr)
        finally:
            sig_unblock()

    s = closure_func_err()
    if s is not NULL:
        pari_error_string = s.decode('ascii') + ": " + pari_error_string

    raise PariError(errnum, pari_error_string, clone_gen_noclear(E))


cdef void _pari_err_recover(long errnum) noexcept:
    """
    Reset the error string and jump back to ``sig_on()``, either to
    retry the code (in case of no error) or to make the already-raised
    exception known to Python.
    """
    reset_avma()

    # Special case errnum == -1 corresponds to a reallocation of the
    # PARI stack. This is not an error, so call after_resize() and
    # proceed as if nothing happened.
    if errnum < 0:
        after_resize()
        return

    # An exception was raised.  Jump to the signal-handling code
    # which will cause sig_on() to see the exception.
    sig_error()
