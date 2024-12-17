# sage_setup: distribution = sagemath-pari
# cython: cdivision = True
"""
Convert PARI objects to/from Python/C native types
**************************************************

This modules contains the following conversion routines:

- integers, long integers <-> PARI integers
- list of integers -> PARI polynomials
- doubles -> PARI reals
- pairs of doubles -> PARI complex numbers

PARI integers are stored as an array of limbs of type ``pari_ulong``
(which are 32-bit or 64-bit integers). Depending on the kernel
(GMP or native), this array is stored little-endian or big-endian.
This is encapsulated in macros like ``int_W()``:
see section 4.5.1 of the
`PARI library manual <http://pari.math.u-bordeaux.fr/pub/pari/manuals/2.7.0/libpari.pdf>`_.

Python integers of type ``int`` are just C longs. Python integers of
type ``long`` are stored as a little-endian array of type ``digit``
with 15 or 30 bits used per digit. The internal format of a ``long`` is
not documented, but there is some information in
`longintrepr.h <https://github.com/python-git/python/blob/master/Include/longintrepr.h>`_.

Because of this difference in bit lengths, converting integers involves
some bit shuffling.
"""

# ****************************************************************************
#       Copyright (C) 2016 Jeroen Demeyer <jdemeyer@cage.ugent.be>
#       Copyright (C) 2016 Luca De Feo <luca.defeo@polytechnique.edu>
#       Copyright (C) 2016 Vincent Delecroix <vincent.delecroix@u-bordeaux.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from cysignals.signals cimport sig_on, sig_off, sig_error

from cpython.version cimport PY_MAJOR_VERSION
from cpython.int cimport PyInt_AS_LONG, PyInt_FromLong
from cpython.longintrepr cimport (_PyLong_New,
                                  digit, PyLong_SHIFT, PyLong_MASK)
from libc.limits cimport LONG_MIN, LONG_MAX
from libc.math cimport INFINITY

from .paridecl cimport *
from .stack cimport new_gen, reset_avma
from .string_utils cimport to_string, to_bytes
from .pycore_long cimport (ob_digit, _PyLong_IsZero, _PyLong_IsPositive,
                           _PyLong_DigitCount, _PyLong_SetSignAndDigitCount)

########################################################################
# Conversion PARI -> Python
########################################################################

cpdef gen_to_python(Gen z):
    r"""
    Convert the PARI element ``z`` to a Python object.

    OUTPUT:

    - a Python integer for integers (type ``t_INT``)

    - a ``Fraction`` (``fractions`` module) for rationals (type ``t_FRAC``)

    - a ``float`` for real numbers (type ``t_REAL``)

    - a ``complex`` for complex numbers (type ``t_COMPLEX``)

    - a ``list`` for vectors (type ``t_VEC`` or ``t_COL``). The function
      ``gen_to_python`` is then recursively applied on the entries.

    - a ``list`` of Python integers for small vectors (type ``t_VECSMALL``)

    - a ``list`` of ``list``s for matrices (type ``t_MAT``). The function
      ``gen_to_python`` is then recursively applied on the entries.

    - the floating point ``inf`` or ``-inf`` for infinities (type ``t_INFINITY``)

    - a string for strings (type ``t_STR``)

    - other PARI types are not supported and the function will raise a
      ``NotImplementedError``

    Examples:

    >>> from cypari2 import Pari
    >>> from cypari2.convert import gen_to_python
    >>> pari = Pari()

    Converting integers:

    >>> z = pari('42'); z
    42
    >>> a = gen_to_python(z); a
    42
    >>> type(a)
    <... 'int'>

    >>> gen_to_python(pari('3^50')) == 3**50
    True
    >>> type(gen_to_python(pari('3^50'))) == type(3**50)
    True

    Converting rational numbers:

    >>> z = pari('2/3'); z
    2/3
    >>> a = gen_to_python(z); a
    Fraction(2, 3)
    >>> type(a)
    <class 'fractions.Fraction'>

    Converting real numbers (and infinities):

    >>> z = pari('1.2'); z
    1.20000000000000
    >>> a = gen_to_python(z); a
    1.2
    >>> type(a)
    <... 'float'>

    >>> z = pari('oo'); z
    +oo
    >>> a = gen_to_python(z); a
    inf
    >>> type(a)
    <... 'float'>

    >>> z = pari('-oo'); z
    -oo
    >>> a = gen_to_python(z); a
    -inf
    >>> type(a)
    <... 'float'>

    Converting complex numbers:

    >>> z = pari('1 + I'); z
    1 + I
    >>> a = gen_to_python(z); a
    (1+1j)
    >>> type(a)
    <... 'complex'>

    >>> z = pari('2.1 + 3.03*I'); z
    2.10000000000000 + 3.03000000000000*I
    >>> a = gen_to_python(z); a
    (2.1+3.03j)

    Converting vectors:

    >>> z1 = pari('Vecsmall([1,2,3])'); z1
    Vecsmall([1, 2, 3])
    >>> z2 = pari('[1, 3.4, [-5, 2], oo]'); z2
    [1, 3.40000000000000, [-5, 2], +oo]
    >>> z3 = pari('[1, 5.2]~'); z3
    [1, 5.20000000000000]~
    >>> z1.type(), z2.type(), z3.type()
    ('t_VECSMALL', 't_VEC', 't_COL')

    >>> a1 = gen_to_python(z1); a1
    [1, 2, 3]
    >>> type(a1)
    <... 'list'>
    >>> [type(x) for x in a1]
    [<... 'int'>, <... 'int'>, <... 'int'>]

    >>> a2 = gen_to_python(z2); a2
    [1, 3.4, [-5, 2], inf]
    >>> type(a2)
    <... 'list'>
    >>> [type(x) for x in a2]
    [<... 'int'>, <... 'float'>, <... 'list'>, <... 'float'>]

    >>> a3 = gen_to_python(z3); a3
    [1, 5.2]
    >>> type(a3)
    <... 'list'>
    >>> [type(x) for x in a3]
    [<... 'int'>, <... 'float'>]

    Converting matrices:

    >>> z = pari('[1,2;3,4]')
    >>> gen_to_python(z)
    [[1, 2], [3, 4]]

    >>> z = pari('[[1, 3], [[2]]; 3, [4, [5, 6]]]')
    >>> gen_to_python(z)
    [[[1, 3], [[2]]], [3, [4, [5, 6]]]]

    Converting strings:

    >>> z = pari('"Hello"')
    >>> a = gen_to_python(z); a
    'Hello'
    >>> type(a)
    <... 'str'>

    Some currently unsupported types:

    >>> z = pari('x')
    >>> z.type()
    't_POL'
    >>> gen_to_python(z)
    Traceback (most recent call last):
    ...
    NotImplementedError: conversion not implemented for t_POL

    >>> z = pari('12 + O(2^13)')
    >>> z.type()
    't_PADIC'
    >>> gen_to_python(z)
    Traceback (most recent call last):
    ...
    NotImplementedError: conversion not implemented for t_PADIC
    """
    return PyObject_FromGEN(z.g)


cpdef gen_to_integer(Gen x):
    """
    Convert a PARI ``gen`` to a Python ``int`` or ``long``.

    INPUT:

    - ``x`` -- a PARI ``t_INT``, ``t_FRAC``, ``t_REAL``, a purely
      real ``t_COMPLEX``, a ``t_INTMOD`` or ``t_PADIC`` (which are
      lifted).

    Examples:

    >>> from cypari2.convert import gen_to_integer
    >>> from cypari2 import Pari
    >>> pari = Pari()
    >>> a = gen_to_integer(pari("12345")); a; type(a)
    12345
    <... 'int'>
    >>> gen_to_integer(pari("10^30")) == 10**30
    True
    >>> gen_to_integer(pari("19/5"))
    3
    >>> gen_to_integer(pari("1 + 0.0*I"))
    1
    >>> gen_to_integer(pari("3/2 + 0.0*I"))
    1
    >>> gen_to_integer(pari("Mod(-1, 11)"))
    10
    >>> gen_to_integer(pari("5 + O(5^10)"))
    5
    >>> gen_to_integer(pari("Pol(42)"))
    42
    >>> gen_to_integer(pari("u"))
    Traceback (most recent call last):
    ...
    TypeError: unable to convert PARI object u of type t_POL to an integer
    >>> s = pari("x + O(x^2)")
    >>> s
    x + O(x^2)
    >>> gen_to_integer(s)
    Traceback (most recent call last):
    ...
    TypeError: unable to convert PARI object x + O(x^2) of type t_SER to an integer
    >>> gen_to_integer(pari("1 + I"))
    Traceback (most recent call last):
    ...
    TypeError: unable to convert PARI object 1 + I of type t_COMPLEX to an integer

    Tests:

    >>> gen_to_integer(pari("1.0 - 2^64")) == -18446744073709551615
    True
    >>> gen_to_integer(pari("1 - 2^64")) == -18446744073709551615
    True
    >>> import sys
    >>> if sys.version_info.major == 3:
    ...     long = int
    >>> for i in range(10000):
    ...     x = 3**i
    ...     if long(pari(x)) != long(x) or int(pari(x)) != x:
    ...         print(x)

    Check some corner cases:

    >>> for s in [1, -1]:
    ...     for a in [1, 2**31, 2**32, 2**63, 2**64]:
    ...         for b in [-1, 0, 1]:
    ...             Nstr = str(s * (a + b))
    ...             N1 = gen_to_integer(pari(Nstr))  # Convert via PARI
    ...             N2 = int(Nstr)                   # Convert via Python
    ...             if N1 != N2:
    ...                 print(Nstr, N1, N2)
    ...             if type(N1) is not type(N2):
    ...                 print(N1, type(N1), N2, type(N2))
    """
    return PyInt_FromGEN(x.g)


cdef PyObject_FromGEN(GEN g):
    cdef long t = typ(g)
    cdef Py_ssize_t i, j
    cdef Py_ssize_t lr, lc

    if t == t_INT:
        return PyInt_FromGEN(g)
    elif t == t_FRAC:
        from fractions import Fraction
        num = PyInt_FromGEN(gel(g, 1))
        den = PyInt_FromGEN(gel(g, 2))
        return Fraction(num, den)
    elif t == t_REAL:
        return rtodbl(g)
    elif t == t_COMPLEX:
        re = PyObject_FromGEN(gel(g, 1))
        im = PyObject_FromGEN(gel(g, 2))
        return complex(re, im)
    elif t == t_VEC or t == t_COL:
        return [PyObject_FromGEN(gel(g, i)) for i in range(1, lg(g))]
    elif t == t_VECSMALL:
        return [g[i] for i in range(1, lg(g))]
    elif t == t_MAT:
        lc = lg(g)
        if lc <= 1:
            return [[]]
        lr = lg(gel(g, 1))
        return [[PyObject_FromGEN(gcoeff(g, i, j)) for j in range(1, lc)]
                for i in range(1, lr)]
    elif t == t_INFINITY:
        if inf_get_sign(g) >= 0:
            return INFINITY
        else:
            return -INFINITY
    elif t == t_STR:
        return to_string(GSTR(g))
    else:
        tname = to_string(type_name(t))
        raise NotImplementedError(f"conversion not implemented for {tname}")


cdef PyInt_FromGEN(GEN g):
    # First convert the input to a t_INT
    try:
        g = gtoi(g)
    finally:
        # Reset avma now. This is OK as long as we are not calling further
        # PARI functions before this function returns.
        reset_avma()

    if not signe(g):
        return PyInt_FromLong(0)

    cdef ulong u
    if PY_MAJOR_VERSION == 2:
        # Try converting to a Python 2 "int" first. Note that we cannot
        # use itos() from PARI since that does not deal with LONG_MIN
        # correctly.
        if lgefint(g) == 3:  # abs(x) fits in a ulong
            u = g[2]         # u = abs(x)
            # Check that <long>(u) or <long>(-u) does not overflow
            if signe(g) >= 0:
                if u <= <ulong>LONG_MAX:
                    return PyInt_FromLong(u)
            else:
                if u <= -<ulong>LONG_MIN:
                    return PyInt_FromLong(-u)

    # Result does not fit in a C long
    res = PyLong_FromINT(g)
    return res


cdef GEN gtoi(GEN g0) except NULL:
    """
    Convert a PARI object to a PARI integer.

    This function is shallow and not stack-clean.
    """
    if typ(g0) == t_INT:
        return g0
    cdef GEN g
    try:
        sig_on()
        g = simplify_shallow(g0)
        if typ(g) == t_COMPLEX:
            if gequal0(gel(g, 2)):
                g = gel(g, 1)
        if typ(g) == t_INTMOD:
            g = gel(g, 2)
        g = trunc_safe(g)
        if typ(g) != t_INT:
            sig_error()
        sig_off()
    except RuntimeError:
        s = to_string(stack_sprintf(
            "unable to convert PARI object %Ps of type %s to an integer",
            g0, type_name(typ(g0))))
        raise TypeError(s)
    return g


cdef PyLong_FromINT(GEN g):
    # Size of input in words, bits and Python digits. The size in
    # digits might be a small over-estimation, but that is not a
    # problem.
    cdef size_t sizewords = (lgefint(g) - 2)
    cdef size_t sizebits = sizewords * BITS_IN_LONG
    cdef size_t sizedigits = (sizebits + PyLong_SHIFT - 1) // PyLong_SHIFT

    # Actual correct computed size
    cdef Py_ssize_t sizedigits_final = 0

    cdef py_long x = _PyLong_New(sizedigits)
    cdef digit* D = ob_digit(x)

    cdef digit d
    cdef ulong w
    cdef size_t i, j, bit
    for i in range(sizedigits):
        # The least significant bit of digit number i of the output
        # integer is bit number "bit" of word "j".
        bit = i * PyLong_SHIFT
        j = bit // BITS_IN_LONG
        bit = bit % BITS_IN_LONG

        w = int_W(g, j)[0]
        d = w >> bit

        # Do we need bits from the next word too?
        if BITS_IN_LONG - bit < PyLong_SHIFT and j+1 < sizewords:
            w = int_W(g, j+1)[0]
            d += w << (BITS_IN_LONG - bit)

        d = d & PyLong_MASK
        D[i] = d

        # Keep track of last non-zero digit
        if d:
            sizedigits_final = i+1

    # Set correct size
    _PyLong_SetSignAndDigitCount(x, signe(g), sizedigits_final)

    return x


########################################################################
# Conversion Python -> PARI
########################################################################

cdef GEN PyLong_AS_GEN(py_long x) noexcept:
    cdef const digit* D = ob_digit(x)

    # Size of the input
    cdef size_t sizedigits
    cdef long sgn
    if _PyLong_IsZero(x):
        return gen_0
    elif _PyLong_IsPositive(x):
        sizedigits = _PyLong_DigitCount(x)
        sgn = evalsigne(1)
    else:
        sizedigits = _PyLong_DigitCount(x)
        sgn = evalsigne(-1)

    # Size of the output, in bits and in words
    cdef size_t sizebits = sizedigits * PyLong_SHIFT
    cdef size_t sizewords = (sizebits + BITS_IN_LONG - 1) // BITS_IN_LONG

    # Compute the most significant word of the output.
    # This is a special case because we need to be careful not to
    # overflow the ob_digit array. We also need to check for zero,
    # in which case we need to decrease sizewords.
    # See the loop below for an explanation of this code.
    cdef size_t bit = (sizewords - 1) * BITS_IN_LONG
    cdef size_t dgt = bit // PyLong_SHIFT
    bit = bit % PyLong_SHIFT

    cdef ulong w = <ulong>(D[dgt]) >> bit
    if 1*PyLong_SHIFT - bit < BITS_IN_LONG and dgt+1 < sizedigits:
        w += <ulong>(D[dgt+1]) << (1*PyLong_SHIFT - bit)
    if 2*PyLong_SHIFT - bit < BITS_IN_LONG and dgt+2 < sizedigits:
        w += <ulong>(D[dgt+2]) << (2*PyLong_SHIFT - bit)
    if 3*PyLong_SHIFT - bit < BITS_IN_LONG and dgt+3 < sizedigits:
        w += <ulong>(D[dgt+3]) << (3*PyLong_SHIFT - bit)
    if 4*PyLong_SHIFT - bit < BITS_IN_LONG and dgt+4 < sizedigits:
        w += <ulong>(D[dgt+4]) << (4*PyLong_SHIFT - bit)
    if 5*PyLong_SHIFT - bit < BITS_IN_LONG and dgt+5 < sizedigits:
        w += <ulong>(D[dgt+5]) << (5*PyLong_SHIFT - bit)

    # Effective size in words plus 2 special codewords
    cdef size_t pariwords = sizewords+2 if w else sizewords+1
    cdef GEN g = cgeti(pariwords)
    g[1] = sgn + evallgefint(pariwords)

    if w:
        int_MSW(g)[0] = w

    # Fill all words
    cdef GEN ptr = int_LSW(g)
    cdef size_t i
    for i in range(sizewords - 1):
        # The least significant bit of word number i of the output
        # integer is bit number "bit" of Python digit "dgt".
        bit = i * BITS_IN_LONG
        dgt = bit // PyLong_SHIFT
        bit = bit % PyLong_SHIFT

        # Now construct the output word from the Python digits: we need
        # to check that we shift less than the number of bits in the
        # type. 6 digits are enough assuming that PyLong_SHIFT >= 15 and
        # BITS_IN_LONG <= 76. A clever compiler should optimize away all
        # but one of the "if" statements below.
        w = <ulong>(D[dgt]) >> bit
        if 1*PyLong_SHIFT - bit < BITS_IN_LONG:
            w += <ulong>(D[dgt+1]) << (1*PyLong_SHIFT - bit)
        if 2*PyLong_SHIFT - bit < BITS_IN_LONG:
            w += <ulong>(D[dgt+2]) << (2*PyLong_SHIFT - bit)
        if 3*PyLong_SHIFT - bit < BITS_IN_LONG:
            w += <ulong>(D[dgt+3]) << (3*PyLong_SHIFT - bit)
        if 4*PyLong_SHIFT - bit < BITS_IN_LONG:
            w += <ulong>(D[dgt+4]) << (4*PyLong_SHIFT - bit)
        if 5*PyLong_SHIFT - bit < BITS_IN_LONG:
            w += <ulong>(D[dgt+5]) << (5*PyLong_SHIFT - bit)

        ptr[0] = w
        ptr = int_nextW(ptr)

    return g


cdef GEN PyObject_AsGEN(x) except? NULL:
    """
    Convert basic Python types to a PARI GEN.
    """
    cdef GEN g = NULL
    if isinstance(x, unicode):
        x = to_bytes(x)
    if isinstance(x, bytes):
        sig_on()
        g = gp_read_str(<bytes>x)
        sig_off()
    elif isinstance(x, long):
        sig_on()
        g = PyLong_AS_GEN(x)
        sig_off()
    elif isinstance(x, int):
        sig_on()
        g = PyInt_AS_GEN(x)
        sig_off()
    elif isinstance(x, float):
        sig_on()
        g = PyFloat_AS_GEN(x)
        sig_off()
    elif isinstance(x, complex):
        sig_on()
        g = PyComplex_AS_GEN(x)
        sig_off()
    return g


####################################
# Deprecated functions
####################################

cdef Gen new_gen_from_double(double x):
    sig_on()
    return new_gen(double_to_REAL(x))


cdef Gen new_t_COMPLEX_from_double(double re, double im):
    sig_on()
    return new_gen(doubles_to_COMPLEX(re, im))


def integer_to_gen(x):
    """
    Convert a Python ``int`` or ``long`` to a PARI ``gen`` of type
    ``t_INT``.

    Examples:

    >>> from cypari2.convert import integer_to_gen
    >>> from cypari2 import Pari
    >>> pari = Pari()
    >>> a = integer_to_gen(int(12345)); a; type(a)
    12345
    <... 'cypari2.gen.Gen'>
    >>> integer_to_gen(float(12345))
    Traceback (most recent call last):
    ...
    TypeError: integer_to_gen() needs an int or long argument, not float
    >>> integer_to_gen(2**100)
    1267650600228229401496703205376

    Tests:

    >>> import sys
    >>> if sys.version_info.major == 3:
    ...     long = int
    >>> assert integer_to_gen(long(12345)) == 12345
    >>> for i in range(10000):
    ...     x = 3**i
    ...     if pari(long(x)) != pari(x) or pari(int(x)) != pari(x):
    ...         print(x)
    """
    if isinstance(x, long):
        sig_on()
        return new_gen(PyLong_AS_GEN(x))
    if isinstance(x, int):
        sig_on()
        return new_gen(stoi(PyInt_AS_LONG(x)))
    raise TypeError("integer_to_gen() needs an int or long "
                    "argument, not {}".format(type(x).__name__))
