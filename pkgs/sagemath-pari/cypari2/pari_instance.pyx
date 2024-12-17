# sage_setup: distribution = sagemath-pari
r"""
Interface to the PARI library
*****************************

AUTHORS:

- William Stein (2006-03-01): updated to work with PARI 2.2.12-beta

- William Stein (2006-03-06): added newtonpoly

- Justin Walker: contributed some of the function definitions

- Gonzalo Tornaria: improvements to conversions; much better error
  handling.

- Robert Bradshaw, Jeroen Demeyer, William Stein (2010-08-15):
  Upgrade to PARI 2.4.3 (:trac:`9343`)

- Jeroen Demeyer (2011-11-12): rewrite various conversion routines
  (:trac:`11611`, :trac:`11854`, :trac:`11952`)

- Peter Bruin (2013-11-17): split off this file from gen.pyx
  (:trac:`15185`)

- Jeroen Demeyer (2014-02-09): upgrade to PARI 2.7 (:trac:`15767`)

- Jeroen Demeyer (2014-09-19): upgrade to PARI 2.8 (:trac:`16997`)

- Jeroen Demeyer (2015-03-17): automatically generate methods from
  ``pari.desc`` (:trac:`17631` and :trac:`17860`)

- Luca De Feo (2016-09-06): Separate Sage-specific components from
  generic C-interface in ``Pari`` (:trac:`20241`)

Examples:

>>> import cypari2
>>> pari = cypari2.Pari()
>>> pari('5! + 10/x')
(120*x + 10)/x
>>> pari('intnum(x=0,13,sin(x)+sin(x^2) + x)')
85.6215190762676
>>> f = pari('x^3 - 1')
>>> v = f.factor(); v
[x - 1, 1; x^2 + x + 1, 1]
>>> v[0]   # indexing is 0-based unlike in GP.
[x - 1, x^2 + x + 1]~
>>> v[1]
[1, 1]~

For most functions, you can call the function as method of ``pari``
or you can first create a :class:`Gen` object and then call the
function as method of that. In other words, the following two commands
do the same:

>>> pari('x^3 - 1').factor()
[x - 1, 1; x^2 + x + 1, 1]
>>> pari.factor('x^3 - 1')
[x - 1, 1; x^2 + x + 1, 1]

Arithmetic operations cause all arguments to be converted to PARI:

>>> type(pari(1) + 1)
<... 'cypari2.gen.Gen'>
>>> type(1 + pari(1))
<... 'cypari2.gen.Gen'>

Guide to real precision in the PARI interface
=============================================

In the PARI interface, "real precision" refers to the precision of real
numbers, so it is the floating-point precision. This is a non-trivial
issue, since there are various interfaces for different things.

Internal representation of floating-point numbers in PARI
---------------------------------------------------------

Real numbers in PARI have a precision associated to them, which is
always a multiple of the CPU wordsize. So, it is a multiple of 32
of 64 bits. When converting a ``float`` from Python to PARI, the
``float`` has 53 bits of precision which is rounded up to 64 bits
in PARI:

>>> x = 1.0
>>> pari(x)
1.00000000000000
>>> pari(x).bitprecision()
64

It is possible to change the precision of a PARI object with the
:meth:`Gen.bitprecision` method:

>>> p = pari(1.0)
>>> p.bitprecision()
64
>>> p = p.bitprecision(100)
>>> p.bitprecision()   # Rounded up to a multiple of the wordsize
128

Beware that these extra bits are just bogus. For example, this will not
magically give a more precise approximation of ``math.pi``:

>>> import math
>>> p = pari(math.pi)
>>> pari("Pi") - p
1.225148... E-16
>>> p = p.bitprecision(1000)
>>> pari("Pi") - p
1.225148... E-16

Another way to create numbers with many bits is to use a string with
many digits:

>>> p = pari("3.1415926535897932384626433832795028842")
>>> p.bitprecision()
128

.. _pari_output_precision:

Output precision for printing
-----------------------------

Even though PARI reals have a precision, not all significant bits are
printed by default. The maximum number of digits when printing a PARI
real can be set using the methods
:meth:`Pari.set_real_precision_bits` or
:meth:`Pari.set_real_precision`.
Note that this will also change the input precision for strings,
see :ref:`pari_input_precision`.

We create a very precise approximation of pi and see how it is printed
in PARI:

>>> pi = pari.pi(precision=1024)

The default precision is 15 digits:

>>> pi
3.14159265358979

With a different precision, we see more digits. Note that this does not
affect the object ``pi`` at all, it only affects how it is printed:

>>> _ = pari.set_real_precision(50)
>>> pi
3.1415926535897932384626433832795028841971693993751

Back to the default:

>>> _ = pari.set_real_precision(15)
>>> pi
3.14159265358979

.. _pari_input_precision:

Input precision for function calls
----------------------------------

When we talk about precision for PARI functions, we need to distinguish
three kinds of calls:

1. Using the string interface, for example ``pari("sin(1)")``.

2. Using the library interface with *exact* inputs, for example
   ``pari.sin(1)``.

3. Using the library interface with *inexact* inputs, for example
   ``pari.sin(1.0)``.

In the first case, the relevant precision is the one set by the methods
:meth:`Pari.set_real_precision_bits` or
:meth:`Pari.set_real_precision`:

>>> pari.set_real_precision_bits(150)
>>> pari("sin(1)")
0.841470984807896506652502321630298999622563061
>>> pari.set_real_precision_bits(53)
>>> pari("sin(1)")
0.841470984807897

In the second case, the precision can be given as the argument
``precision`` in the function call, with a default of 53 bits.
The real precision set by
:meth:`Pari.set_real_precision_bits` or
:meth:`Pari.set_real_precision` does not affect the call
(but it still affects printing).

As explained before, the precision increases to a multiple of the
wordsize (and you should not assume that the extra bits are meaningful):

>>> a = pari.sin(1, precision=180); a
0.841470984807897
>>> a.bitprecision()
192
>>> b = pari.sin(1, precision=40); b
0.841470984807897
>>> b.bitprecision()
64
>>> c = pari.sin(1); c
0.841470984807897
>>> c.bitprecision()
64
>>> pari.set_real_precision_bits(90)
>>> print(a); print(b); print(c)
0.841470984807896506652502322
0.8414709848078965067
0.8414709848078965067

In the third case, the precision is determined only by the inexact
inputs and the ``precision`` argument is ignored:

>>> pari.sin(1.0, precision=180).bitprecision()
64
>>> pari.sin(1.0, precision=40).bitprecision()
64
>>> pari.sin("1.0000000000000000000000000000000000000").bitprecision()
128

Tests:

Check that the documentation is generated correctly:

>>> from inspect import getdoc
>>> getdoc(pari.Pi)
'The constant :math:`\\pi` ...'

Check that output from PARI's print command is actually seen by
Python (:trac:`9636`):

>>> pari('print("test")')
test

Verify that ``nfroots()`` (which has an unusual signature with a
non-default argument following a default argument) works:

>>> pari.nfroots(x='x^4 - 1')
[-1, 1]
>>> pari.nfroots(pari.nfinit('t^2 + 1'), "x^4 - 1")
[-1, 1, Mod(-t, t^2 + 1), Mod(t, t^2 + 1)]

Reset default precision for the following tests:

>>> pari.set_real_precision_bits(53)

Test the trashcan mechanism (without the trashcan, this would cause
a stack overflow):

>>> pari.allocatemem(2**27, silent=True)
>>> L = [pari(i) for i in range(2**20)]
>>> x = pari.Pi()
>>> del L
>>> del x

Test that interrupts work properly:

>>> pari.allocatemem(8000000, 2**29)
PARI stack size set to 8000000 bytes, maximum size set to ...
>>> from cysignals.alarm import alarm, AlarmInterrupt
>>> for i in range(1, 11):
...     try:
...         alarm(i/11.0)
...         pari.binomial(2**100, 2**22)
...     except AlarmInterrupt:
...         pass

Test that changing the stack size using ``default`` works properly:

>>> pari.default("parisizemax", 2**23)
>>> pari = cypari2.Pari()  # clear stack
>>> a = pari(1)
>>> pari.default("parisizemax", 2**29)
>>> a + a
2
>>> pari.default("parisizemax")
536870912
"""

# ****************************************************************************
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

import sys
from libc.stdio cimport *
cimport cython

from cysignals.signals cimport sig_check, sig_on, sig_off, sig_error

from .string_utils cimport to_string, to_bytes
from .paridecl cimport *
from .paripriv cimport *
from .gen cimport Gen, objtogen
from .stack cimport (new_gen, new_gen_noclear, clear_stack,
                     set_pari_stack_size, before_resize, after_resize)
from .handle_error cimport _pari_init_error_handling
from .closure cimport _pari_init_closure

# Default precision (in PARI words) for the PARI library interface,
# when no explicit precision is given and the inputs are exact.
cdef long prec = prec_bits_to_words(53)


#################################################################
# conversions between various real precision models
#################################################################

def prec_bits_to_dec(long prec_in_bits):
    r"""
    Convert from precision expressed in bits to precision expressed in
    decimal.

    Examples:

    >>> from cypari2.pari_instance import prec_bits_to_dec
    >>> prec_bits_to_dec(53)
    15
    >>> [(32*n, prec_bits_to_dec(32*n)) for n in range(1, 9)]
    [(32, 9), (64, 19), (96, 28), (128, 38), (160, 48), (192, 57), (224, 67), (256, 77)]
    """
    return nbits2ndec(prec_in_bits)


def prec_dec_to_bits(long prec_in_dec):
    r"""
    Convert from precision expressed in decimal to precision expressed
    in bits.

    Examples:

    >>> from cypari2.pari_instance import prec_dec_to_bits
    >>> prec_dec_to_bits(15)
    50
    >>> [(n, prec_dec_to_bits(n)) for n in range(10, 100, 10)]
    [(10, 34), (20, 67), (30, 100), (40, 133), (50, 167), (60, 200), (70, 233), (80, 266), (90, 299)]
    """
    cdef double log_10 = 3.32192809488736
    return int(prec_in_dec*log_10 + 1.0)  # Add one to round up


cpdef long prec_bits_to_words(unsigned long prec_in_bits) noexcept:
    r"""
    Convert from precision expressed in bits to pari real precision
    expressed in words. Note: this rounds up to the nearest word,
    adjusts for the two codewords of a pari real, and is
    architecture-dependent.

    Examples:

    >>> from cypari2.pari_instance import prec_bits_to_words
    >>> import sys
    >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
    >>> prec_bits_to_words(70) == (5 if bitness == '32' else 4)
    True

    >>> ans32 = [(32, 3), (64, 4), (96, 5), (128, 6), (160, 7), (192, 8), (224, 9), (256, 10)]
    >>> ans64 = [(32, 3), (64, 3), (96, 4), (128, 4), (160, 5), (192, 5), (224, 6), (256, 6)]
    >>> [(32*n, prec_bits_to_words(32*n)) for n in range(1, 9)] == (ans32 if bitness == '32' else ans64)
    True
    """
    if not prec_in_bits:
        return prec
    cdef unsigned long wordsize = BITS_IN_LONG

    # This equals ceil(prec_in_bits/wordsize) + 2
    return (prec_in_bits - 1)//wordsize + 3


cpdef long prec_words_to_bits(long prec_in_words) noexcept:
    r"""
    Convert from pari real precision expressed in words to precision
    expressed in bits. Note: this adjusts for the two codewords of a
    pari real, and is architecture-dependent.

    Examples:

    >>> from cypari2.pari_instance import prec_words_to_bits
    >>> import sys
    >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
    >>> prec_words_to_bits(10) == (256 if bitness == '32' else 512)
    True

    >>> ans32 = [(3, 32), (4, 64), (5, 96), (6, 128), (7, 160), (8, 192), (9, 224)]
    >>> ans64 = [(3, 64), (4, 128), (5, 192), (6, 256), (7, 320), (8, 384), (9, 448)] # 64-bit
    >>> [(n, prec_words_to_bits(n)) for n in range(3, 10)] == (ans32 if bitness == '32' else ans64)
    True
    """
    # see user's guide to the pari library, page 10
    return (prec_in_words - 2) * BITS_IN_LONG


cpdef long default_bitprec() noexcept:
    r"""
    Return the default precision in bits.

    Examples:

    >>> from cypari2.pari_instance import default_bitprec
    >>> default_bitprec()
    64
    """
    return (prec - 2) * BITS_IN_LONG


def prec_dec_to_words(long prec_in_dec):
    r"""
    Convert from precision expressed in decimal to precision expressed
    in words. Note: this rounds up to the nearest word, adjusts for the
    two codewords of a pari real, and is architecture-dependent.

    Examples:

    >>> from cypari2.pari_instance import prec_dec_to_words
    >>> import sys
    >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
    >>> prec_dec_to_words(38) == (6 if bitness == '32' else 4)
    True

    >>> ans32 = [(10, 4), (20, 5), (30, 6), (40, 7), (50, 8), (60, 9), (70, 10), (80, 11)]
    >>> ans64 = [(10, 3), (20, 4), (30, 4), (40, 5), (50, 5), (60, 6), (70, 6), (80, 7)] # 64-bit
    >>> [(n, prec_dec_to_words(n)) for n in range(10, 90, 10)] == (ans32 if bitness == '32' else ans64)
    True
    """
    return prec_bits_to_words(prec_dec_to_bits(prec_in_dec))


def prec_words_to_dec(long prec_in_words):
    r"""
    Convert from precision expressed in words to precision expressed in
    decimal. Note: this adjusts for the two codewords of a pari real,
    and is architecture-dependent.

    Examples:

    >>> from cypari2.pari_instance import prec_words_to_dec
    >>> import sys
    >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
    >>> prec_words_to_dec(5) == (28 if bitness == '32' else 57)
    True

    >>> ans32 = [(3, 9), (4, 19), (5, 28), (6, 38), (7, 48), (8, 57), (9, 67)]
    >>> ans64 = [(3, 19), (4, 38), (5, 57), (6, 77), (7, 96), (8, 115), (9, 134)]
    >>> [(n, prec_words_to_dec(n)) for n in range(3, 10)] == (ans32 if bitness == '32' else ans64)
    True
    """
    return prec_bits_to_dec(prec_words_to_bits(prec_in_words))


# Callbacks from PARI to print stuff using sys.stdout.write() instead
# of C library functions like puts().
cdef PariOUT python_pariOut

cdef void python_putchar(char c) noexcept:
    cdef char s[2]
    s[0] = c
    s[1] = 0
    try:
        # avoid string conversion if possible
        sys.stdout.buffer.write(s)
    except AttributeError:
        sys.stdout.write(to_string(s))
    # Let PARI think the last character was a newline,
    # so it doesn't print one when an error occurs.
    pari_set_last_newline(1)

cdef void python_puts(const char* s) noexcept:
    try:
        # avoid string conversion if possible
        sys.stdout.buffer.write(s)
    except AttributeError:
        sys.stdout.write(to_string(s))
    pari_set_last_newline(1)

cdef void python_flush() noexcept:
    sys.stdout.flush()

include 'auto_instance.pxi'


cdef class Pari(Pari_auto):
    def __cinit__(self):
        r"""
        (Re)-initialize the PARI library.

        Tests:

        >>> from cypari2.pari_instance import Pari
        >>> Pari.__new__(Pari)
        Interface to the PARI C library
        >>> pari = Pari()
        >>> pari("print('hello')")
        """
        # PARI is already initialized, nothing to do...
        if avma:
            return

        # Take 1MB as minimal stack. Use maxprime=0, which PARI will
        # internally increase to some small value like 65537.
        # (see function initprimes in src/language/forprime.c)
        pari_init_opts(1000000 * sizeof(long), 0, INIT_DFTm)
        after_resize()

        # Disable PARI's stack overflow checking which is incompatible
        # with multi-threading.
        pari_stackcheck_init(NULL)

        _pari_init_error_handling()
        _pari_init_closure()

        # Set printing functions
        global pariOut, pariErr

        pariOut = &python_pariOut
        pariOut.putch = python_putchar
        pariOut.puts = python_puts
        pariOut.flush = python_flush

        # Use 53 bits as default precision
        self.set_real_precision_bits(53)

        # Disable pretty-printing
        GP_DATA.fmt.prettyp = 0

        # This causes PARI/GP to use output independent of the terminal
        # (which is what we want for the PARI library interface).
        GP_DATA.flags = gpd_TEST

        # Ensure that Galois groups are represented in a sane way,
        # see the polgalois section of the PARI users manual.
        global new_galois_format
        new_galois_format = 1

        # By default, factor() should prove primality of returned
        # factors. This not only influences the factor() function, but
        # also many functions indirectly using factoring.
        global factor_proven
        factor_proven = 1

        # Monkey-patch default(parisize) and default(parisizemax)
        ep = pari_is_default("parisize")
        if ep:
            ep.value = <void*>patched_parisize
        ep = pari_is_default("parisizemax")
        if ep:
            ep.value = <void*>patched_parisizemax

    def __init__(self, size_t size=8000000, size_t sizemax=0, unsigned long maxprime=500000):
        """
        (Re)-Initialize the PARI system.

        INPUT:

        - ``size`` -- (default: 8000000) the number of bytes for the
          initial PARI stack (see notes below)

        - ``sizemax`` -- the maximal number of bytes for the
          dynamically increasing PARI stack. The default ``0`` means
          to use the same value as ``size`` (see notes below)

        - ``maxprime`` -- (default: 500000) limit on the primes in the
          precomputed prime number table which is used for sieving
          algorithms

        When the PARI system is already initialized, the PARI stack is only
        grown if ``size`` is greater than the current stack, and the table
        of primes is only computed if ``maxprime`` is larger than the current
        bound.

        Examples:

        >>> from cypari2.pari_instance import Pari
        >>> pari = Pari()
        >>> pari2 = Pari(10**7)
        >>> pari2
        Interface to the PARI C library
        >>> pari2 is pari
        False
        >>> pari2.PARI_ZERO == pari.PARI_ZERO
        True
        >>> pari2 = Pari(10**6)
        >>> pari.stacksize(), pari2.stacksize()
        (10000000, 10000000)

        >>> Pari().default("primelimit")
        500000
        >>> Pari(maxprime=20000).default("primelimit")
        20000

        For more information about how precision works in the PARI
        interface, see :mod:`cypari2.pari_instance`.

        .. NOTE::

            PARI has a "real" stack size (``size``) and a "virtual"
            stack size (``sizemax``). The idea is that the real stack
            will be used if possible, but that the stack might be
            increased up to ``sizemax`` bytes. Therefore, it is not a
            problem to set ``sizemax`` to a large value. On the other
            hand, it also makes no sense to set this to a value larger
            than what your system can handle.

        .. NOTE::

           Normally, all results from PARI computations end up on the
           PARI stack. CyPari2 tries to keep everything on the PARI
           stack. However, if over half of the PARI stack space is used,
           all live objects on the PARI stack are copied to the PARI
           heap (they become so-called clones).
        """
        # Increase (but don't decrease) size and sizemax to the
        # requested value
        size = max(size, pari_mainstack.rsize)
        sizemax = max(max(size, pari_mainstack.vsize), sizemax)
        set_pari_stack_size(size, sizemax)

        # Increase the table of primes if needed
        GP_DATA.primelimit = maxprime
        self.init_primes(maxprime)

        # Initialize some constants
        self.PARI_ZERO = new_gen_noclear(gen_0)
        self.PARI_ONE = new_gen_noclear(gen_1)
        self.PARI_TWO = new_gen_noclear(gen_2)

        IF HAVE_PLOT_SVG:
            # If we are running under IPython, setup for displaying SVG plots.
            if "IPython" in sys.modules:
                pari_set_plot_engine(get_plot_ipython)

    def debugstack(self):
        r"""
        Print the internal PARI variables ``top`` (top of stack), ``avma``
        (available memory address, think of this as the stack pointer),
        ``bot`` (bottom of stack).
        """
        # We deliberately use low-level functions to minimize the
        # chances that something goes wrong here (for example, if we
        # are out of memory).
        printf("top =  %p\navma = %p\nbot =  %p\nsize = %lu\n",
               <void*>pari_mainstack.top,
               <void*>avma,
               <void*>pari_mainstack.bot,
               <unsigned long>pari_mainstack.rsize)
        fflush(stdout)

    def __repr__(self):
        return "Interface to the PARI C library"

    def __hash__(self):
        return 907629390

    def set_debug_level(self, level):
        """
        Set the debug PARI C library variable.
        """
        self.default('debug', int(level))

    def get_debug_level(self):
        """
        Set the debug PARI C library variable.
        """
        return int(self.default('debug'))

    def set_real_precision_bits(self, n):
        """
        Sets the PARI default real precision in bits.

        This is used both for creation of new objects from strings and
        for printing. It determines the number of digits in which real
        numbers numbers are printed. It also determines the precision
        of objects created by parsing strings (e.g. pari('1.2')), which
        is *not* the normal way of creating new PARI objects using
        cypari. It has *no* effect on the precision of computations
        within the PARI library.

        .. seealso:: :meth:`set_real_precision` to set the
           precision in decimal digits.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.set_real_precision_bits(200)
        >>> pari('1.2')
        1.20000000000000000000000000000000000000000000000000000000000
        >>> pari.set_real_precision_bits(53)
        """
        cdef bytes strn = to_bytes(n)
        sig_on()
        sd_realbitprecision(strn, d_SILENT)
        clear_stack()

    def get_real_precision_bits(self):
        """
        Return the current PARI default real precision in bits.

        This is used both for creation of new objects from strings and
        for printing. It determines the number of digits in which real
        numbers numbers are printed. It also determines the precision
        of objects created by parsing strings (e.g. pari('1.2')), which
        is *not* the normal way of creating new PARI objects using
        cypari. It has *no* effect on the precision of computations
        within the PARI library.

        .. seealso:: :meth:`get_real_precision` to get the
           precision in decimal digits.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.get_real_precision_bits()
        53
        """
        sig_on()
        r = itos(sd_realbitprecision(NULL, d_RETURN))
        clear_stack()
        return r

    def set_real_precision(self, long n):
        """
        Sets the PARI default real precision in decimal digits.

        This is used both for creation of new objects from strings and for
        printing. It is the number of digits *IN DECIMAL* in which real
        numbers are printed. It also determines the precision of objects
        created by parsing strings (e.g. pari('1.2')), which is *not* the
        normal way of creating new PARI objects in CyPari2. It has *no*
        effect on the precision of computations within the pari library.

        Returns the previous PARI real precision.

        .. seealso:: :meth:`set_real_precision_bits` to set the
           precision in bits.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.set_real_precision(60)
        15
        >>> pari('1.2')
        1.20000000000000000000000000000000000000000000000000000000000
        >>> pari.set_real_precision(15)
        60
        """
        old = self.get_real_precision()
        self.set_real_precision_bits(prec_dec_to_bits(n))
        return old

    def get_real_precision(self):
        """
        Returns the current PARI default real precision.

        This is used both for creation of new objects from strings and for
        printing. It is the number of digits *IN DECIMAL* in which real
        numbers are printed. It also determines the precision of objects
        created by parsing strings (e.g. pari('1.2')), which is *not* the
        normal way of creating new PARI objects in CyPari2. It has *no*
        effect on the precision of computations within the pari library.

        .. seealso:: :meth:`get_real_precision_bits` to get the
           precision in bits.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.get_real_precision()
        15
        """
        cdef long r
        sig_on()
        r = itos(sd_realprecision(NULL, d_RETURN))
        sig_off()
        return r

    def set_series_precision(self, long n):
        global precdl
        precdl = n

    def get_series_precision(self):
        return precdl

    def version(self):
        """
        Return the PARI version as tuple with 3 or 4 components:
        (major, minor, patch) or (major, minor, patch, VCSversion).

        Examples:

        >>> from cypari2 import Pari
        >>> Pari().version() >= (2, 9, 0)
        True
        """
        return tuple(Pari_auto.version(self))

    def complex(self, re, im):
        """
        Create a new complex number, initialized from re and im.
        """
        cdef Gen t0 = objtogen(re)
        cdef Gen t1 = objtogen(im)
        sig_on()
        return new_gen(mkcomplex(t0.g, t1.g))

    def __call__(self, s):
        """
        Create the PARI object obtained by evaluating s using PARI.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari(0)
        0
        >>> pari([2,3,5])
        [2, 3, 5]

        >>> a = pari(1); a, a.type()
        (1, 't_INT')
        >>> a = pari('1/2'); a, a.type()
        (1/2, 't_FRAC')

        >>> s = pari(u'"éàèç"')
        >>> s.type()
        't_STR'

        Some commands are just executed without returning a value:

        >>> pari("dummy = 0; kill(dummy)")
        >>> print(pari("dummy = 0; kill(dummy)"))
        None

        See :func:`objtogen` for more examples.
        """
        cdef Gen g = objtogen(s)
        if g.g is gnil:
            return None
        return g

    cpdef Gen zero(self):
        """
        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.zero()
        0
        """
        return self.PARI_ZERO

    cpdef Gen one(self):
        """
        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.one()
        1
        """
        return self.PARI_ONE

    def new_with_bits_prec(self, s, long precision):
        r"""
        pari.new_with_bits_prec(self, s, precision) creates s as a PARI
        Gen with (at most) precision *bits* of precision.
        """
        # TODO: deprecate
        cdef unsigned long old_prec
        old_prec = GP_DATA.fmt.sigd
        precision = prec_bits_to_dec(precision)
        if not precision:
            precision = old_prec
        self.set_real_precision(precision)
        x = objtogen(s)
        self.set_real_precision(old_prec)
        return x

    ############################################################
    # Initialization
    ############################################################

    def stacksize(self):
        r"""
        Return the current size of the PARI stack, which is `10^6`
        by default.  However, the stack size is automatically
        increased when needed up to the given maximum stack size.

        .. SEEALSO::

            - :meth:`stacksizemax` to get the maximum stack size
            - :meth:`allocatemem` to change the current or maximum
              stack size

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.stacksize()
        8000000
        >>> pari.allocatemem(2**18, silent=True)
        >>> pari.stacksize()
        262144
        """
        return pari_mainstack.size

    def stacksizemax(self):
        r"""
        Return the maximum size of the PARI stack, which is determined
        at startup in terms of available memory. Usually, the PARI
        stack size is (much) smaller than this maximum but the stack
        will be increased up to this maximum if needed.

        .. SEEALSO::

            - :meth:`stacksize` to get the current stack size
            - :meth:`allocatemem` to change the current or maximum
              stack size

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.allocatemem(2**18, 2**26, silent=True)
        >>> pari.stacksizemax()
        67108864
        """
        return pari_mainstack.vsize

    def allocatemem(self, size_t s=0, size_t sizemax=0, *, silent=False):
        r"""
        Change the PARI stack space to the given size ``s`` (or double
        the current size if ``s`` is `0`) and change the maximum stack
        size to ``sizemax``.

        PARI tries to use only its current stack (the size which is set
        by ``s``), but it will increase its stack if needed up to the
        maximum size which is set by ``sizemax``.

        The PARI stack is never automatically shrunk.  You can use the
        command ``pari.allocatemem(10^6)`` to reset the size to `10^6`,
        which is the default size at startup.  Note that the results of
        computations using cypari are copied to the Python heap, so they
        take up no space in the PARI stack. The PARI stack is cleared
        after every computation.

        It does no real harm to set this to a small value as the PARI
        stack will be automatically enlarged when we run out of memory.

        INPUT:

        - ``s`` - an integer (default: 0).  A non-zero argument is the
          size in bytes of the new PARI stack.  If `s` is zero, double
          the current stack size.

        - ``sizemax`` - an integer (default: 0).  A non-zero argument
          is the maximum size in bytes of the PARI stack.  If
          ``sizemax`` is 0, the maximum of the current maximum and
          ``s`` is taken.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.allocatemem(10**7, 10**7)
        PARI stack size set to 10000000 bytes, maximum size set to 100...
        >>> pari.allocatemem()  # Double the current size
        PARI stack size set to 20000000 bytes, maximum size set to 200...
        >>> pari.stacksize()
        20000000
        >>> pari.allocatemem(10**6)
        PARI stack size set to 1000000 bytes, maximum size set to 200...

        The following computation will automatically increase the PARI
        stack size:

        >>> a = pari('2^100000000')

        ``a`` is now a Python variable on the Python heap and does not
        take up any space on the PARI stack.  The PARI stack is still
        large because of the computation of ``a``:

        >>> pari.stacksize() > 10**6
        True

        Setting a small maximum size makes this fail:

        >>> pari.allocatemem(10**6, 2**22)
        PARI stack size set to 1000000 bytes, maximum size set to 4194304
        >>> a = pari('2^100000000')
        Traceback (most recent call last):
        ...
        PariError: _^s: the PARI stack overflows (current size: 1000000; maximum size: 4194304)
        You can use pari.allocatemem() to change the stack size and try again

        Tests:

        Do the same without using the string interface and starting
        from a very small stack size:

        >>> pari.allocatemem(1, 2**26)
        PARI stack size set to 1024 bytes, maximum size set to 67108864
        >>> a = pari(2)**100000000
        >>> pari.stacksize() > 10**6
        True

        We do not allow ``sizemax`` less than ``s``:

        >>> pari.allocatemem(10**7, 10**6)
        Traceback (most recent call last):
        ...
        ValueError: the maximum size (10000000) should be at least the stack size (1000000)
        """
        if s == 0:
            s = pari_mainstack.size * 2
            if s < pari_mainstack.size:
                raise OverflowError("cannot double stack size")
        elif s < 1024:
            s = 1024  # arbitrary minimum size
        if sizemax == 0:
            # For the default sizemax, use the maximum of current
            # sizemax and the given size s.
            if pari_mainstack.vsize > s:
                sizemax = pari_mainstack.vsize
            else:
                sizemax = s
        elif sizemax < s:
            raise ValueError("the maximum size ({}) should be at least the stack size ({})".format(s, sizemax))
        set_pari_stack_size(s, sizemax)
        if not silent:
            print("PARI stack size set to {} bytes, maximum size set to {}".
                  format(self.stacksize(), self.stacksizemax()))

    @staticmethod
    def pari_version():
        """
        Return a string describing the version of PARI/GP.

        >>> from cypari2 import Pari
        >>> Pari.pari_version()
        'GP/PARI CALCULATOR Version ...'
        """
        return to_string(PARIVERSION)

    def init_primes(self, unsigned long M):
        """
        Recompute the primes table including at least all primes up to M
        (but possibly more).

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.init_primes(200000)

        We make sure that ticket :trac:`11741` has been fixed:

        >>> pari.init_primes(2**30)
        Traceback (most recent call last):
        ...
        ValueError: Cannot compute primes beyond 436273290
        """
        # Hardcoded bound in PARI sources (language/forprime.c)
        if M > 436273289:
            raise ValueError("Cannot compute primes beyond 436273290")

        if M <= maxprime():
            return
        sig_on()
        initprimetable(M)
        sig_off()

    def primes(self, n=None, end=None):
        """
        Return a pari vector containing the first `n` primes, the primes
        in the interval `[n, end]`, or the primes up to `end`.

        INPUT:

        Either

        - ``n`` -- integer

        or

        - ``n`` -- list or tuple `[a, b]` defining an interval of primes

        or

        - ``n, end`` -- start and end point of an interval of primes

        or

        - ``end`` -- end point for the list of primes

        OUTPUT: a PARI list of prime numbers

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.primes(3)
        [2, 3, 5]
        >>> pari.primes(10)
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
        >>> pari.primes(20)
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71]
        >>> len(pari.primes(1000))
        1000
        >>> pari.primes(11,29)
        [11, 13, 17, 19, 23, 29]
        >>> pari.primes((11,29))
        [11, 13, 17, 19, 23, 29]
        >>> pari.primes(end=29)
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
        >>> pari.primes(10**30, 10**30 + 100)
        [1000000000000000000000000000057, 1000000000000000000000000000099]

        Tests:

        >>> pari.primes(0)
        []
        >>> pari.primes(-1)
        []
        >>> pari.primes(end=1)
        []
        >>> pari.primes(end=-1)
        []
        >>> pari.primes(3,2)
        []
        """
        cdef Gen t0, t1
        if end is None:
            t0 = objtogen(n)
            sig_on()
            return new_gen(primes0(t0.g))
        elif n is None:
            t0 = self.PARI_TWO  # First prime
        else:
            t0 = objtogen(n)
        t1 = objtogen(end)
        sig_on()
        return new_gen(primes_interval(t0.g, t1.g))

    euler = Pari_auto.Euler
    pi = Pari_auto.Pi

    def polchebyshev(self, long n, v=None):
        """
        Chebyshev polynomial of the first kind of degree `n`,
        in the variable `v`.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.polchebyshev(7)
        64*x^7 - 112*x^5 + 56*x^3 - 7*x
        >>> pari.polchebyshev(7, 'z')
        64*z^7 - 112*z^5 + 56*z^3 - 7*z
        >>> pari.polchebyshev(0)
        1
        """
        sig_on()
        return new_gen(polchebyshev1(n, get_var(v)))

    def factorial_int(self, long n):
        """
        Return the factorial of the integer n as a PARI gen.
        Give result as an integer.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.factorial_int(0)
        1
        >>> pari.factorial_int(1)
        1
        >>> pari.factorial_int(5)
        120
        >>> pari.factorial_int(25)
        15511210043330985984000000
        """
        sig_on()
        return new_gen(mpfact(n))

    def polsubcyclo(self, long n, long d, v=None):
        r"""
        polsubcyclo(n, d, v=x): return the pari list of polynomial(s)
        defining the sub-abelian extensions of degree `d` of the
        cyclotomic field `\QQ(\zeta_n)`, where `d`
        divides `\phi(n)`.

        Examples::

        >>> import cypari2
        >>> pari = cypari2.Pari()

            >>> pari.polsubcyclo(8, 4)
            [x^4 + 1]
            >>> pari.polsubcyclo(8, 2, 'z')
            [z^2 + 2, z^2 - 2, z^2 + 1]
            >>> pari.polsubcyclo(8, 1)
            [x - 1]
            >>> pari.polsubcyclo(8, 3)
            []
        """
        cdef Gen plist
        sig_on()
        plist = new_gen(polsubcyclo(n, d, get_var(v)))
        if typ(plist.g) != t_VEC:
            return self.vector(1, [plist])
        else:
            return plist

    def setrand(self, seed):
        """
        Sets PARI's current random number seed.

        INPUT:

        - ``seed`` -- either a strictly positive integer or a GEN of
          type ``t_VECSMALL`` as output by ``getrand()``

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.setrand(50)
        >>> a = pari.getrand()
        >>> pari.setrand(a)
        >>> a == pari.getrand()
        True

        Tests:

        Check that invalid inputs are handled properly:

        >>> pari.setrand("foobar")
        Traceback (most recent call last):
        ...
        PariError: incorrect type in setrand (t_POL)
        """
        cdef Gen t0 = objtogen(seed)
        sig_on()
        setrand(t0.g)
        sig_off()

    def vector(self, long n, entries=None):
        """
        vector(long n, entries=None): Create and return the length n PARI
        vector with given list of entries.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.vector(5, [1, 2, 5, 4, 3])
        [1, 2, 5, 4, 3]
        >>> pari.vector(2, ['x', 1])
        [x, 1]
        >>> pari.vector(2, ['x', 1, 5])
        Traceback (most recent call last):
        ...
        IndexError: length of entries (=3) must equal n (=2)
        """
        # TODO: deprecate
        v = self._empty_vector(n)
        if entries is not None:
            if len(entries) != n:
                raise IndexError(f"length of entries (={len(entries)}) must equal n (={n})")
            for i, x in enumerate(entries):
                v[i] = x
        return v

    cdef Gen _empty_vector(self, long n):
        cdef Gen v
        sig_on()
        v = new_gen(zerovec(n))
        return v

    def matrix(self, long m, long n, entries=None):
        """
        matrix(long m, long n, entries=None): Create and return the m x n
        PARI matrix with given list of entries.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.matrix(3, 3, range(9))
        [0, 1, 2; 3, 4, 5; 6, 7, 8]
        """
        cdef long i, j, k
        cdef Gen x

        sig_on()
        A = new_gen(zeromatcopy(m, n))
        if entries is not None:
            if len(entries) != m * n:
                raise IndexError("len of entries (=%s) must be %s*%s=%s" % (len(entries), m, n, m*n))
            k = 0
            for i in range(m):
                for j in range(n):
                    sig_check()
                    x = objtogen(entries[k])
                    set_gcoeff(A.g, i+1, j+1, x.ref_target())
                    A.cache((i, j), x)
                    k += 1
        return A

    def genus2red(self, P, p=None):
        r"""
        Let `P` be a polynomial with integer coefficients.
        Determines the reduction of the (proper, smooth) genus 2
        curve `C/\QQ`, defined by the hyperelliptic equation `y^2 = P`.
        The special syntax ``genus2red([P,Q])`` is also allowed, where
        the polynomials `P` and `Q` have integer coefficients, to
        represent the model `y^2 + Q(x)y = P(x)`.

        If the second argument `p` is specified, it must be a prime.
        Then only the local information at `p` is computed and returned.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> x = pari('x')
        >>> pari.genus2red([-5*x**5, x**3 - 2*x**2 - 2*x + 1])
        [1416875, [2, -1; 5, 4; 2267, 1], ..., [[2, [2, [Mod(1, 2)]], []], [5, [1, []], ["[V] page 156", [3]]], [2267, [2, [Mod(432, 2267)]], ["[I{1-0-0}] page 170", []]]]]
        >>> pari.genus2red([-5*x**5, x**3 - 2*x**2 - 2*x + 1],2267)
        [2267, Mat([2267, 1]), ..., [2267, [2, [Mod(432, 2267)]], ["[I{1-0-0}] page 170", []]]]
        """
        cdef Gen t0 = objtogen(P)
        if p is None:
            sig_on()
            return new_gen(genus2red(t0.g, NULL))
        cdef Gen t1 = objtogen(p)
        sig_on()
        return new_gen(genus2red(t0.g, t1.g))

    def List(self, x=None):
        """
        Create an empty list or convert `x` to a list.

        Examples:

        >>> import cypari2
        >>> pari = cypari2.Pari()
        >>> pari.List(range(5))
        List([0, 1, 2, 3, 4])
        >>> L = pari.List()
        >>> L
        List([])
        >>> L.listput(42, 1)
        42
        >>> L
        List([42])
        >>> L.listinsert(24, 1)
        24
        >>> L
        List([24, 42])
        """
        if x is None:
            sig_on()
            return new_gen(mklist())
        cdef Gen t0 = objtogen(x)
        sig_on()
        return new_gen(gtolist(t0.g))


cdef long get_var(v) except -2:
    """
    Convert ``v`` into a PARI variable number.

    If ``v`` is a PARI object, return the variable number of
    ``variable(v)``. If ``v`` is ``None``, return -1.
    Otherwise, treat ``v`` as a string and return the number of
    the variable named ``v``.

    OUTPUT: a PARI variable number (varn) or -1 if there is no
    variable number.

    .. WARNING::

        You can easily create variables with garbage names using
        this function. This can actually be used as a feature, if
        you want variable names which cannot be confused with
        ordinary user variables.

    Examples:

    We test this function using ``Pol()`` which calls this function:

    >>> import cypari2
    >>> pari = cypari2.Pari()
    >>> pari("[1,0]").Pol()
    x
    >>> pari("[2,0]").Pol('x')
    2*x
    >>> pari("[Pi,0]").Pol('!@#$%^&')
    3.14159265358979*!@#$%^&

    We can use ``varhigher()`` and ``varlower()`` to create
    temporary variables without a name. The ``"xx"`` below is just a
    string to display the variable, it doesn't create a variable
    ``"xx"``:

    >>> xx = pari.varhigher("xx")
    >>> pari("[x,0]").Pol(xx)
    x*xx

    Indeed, this is not the same as:

    >>> pari("[x,0]").Pol("xx")
    Traceback (most recent call last):
    ...
    PariError: incorrect priority in gtopoly: variable x <= xx
    """
    if v is None:
        return -1
    cdef long varno
    if isinstance(v, Gen):
        sig_on()
        varno = gvar((<Gen>v).g)
        sig_off()
        if varno < 0:
            return -1
        else:
            return varno
    cdef bytes s = to_bytes(v)
    sig_on()
    varno = fetch_user_var(s)
    sig_off()
    return varno


# Monkey-patched versions of default(parisize) and default(parisizemax)
# which call before_resize() and after_resize().
# The monkey-patching is set up in PariInstance.__cinit__
cdef GEN patched_parisize(const char* v, long flag) noexcept:
    # Cast to `int(*)() noexcept` to avoid exception handling
    if (<int(*)() noexcept>before_resize)():
        sig_error()
    return sd_parisize(v, flag)


cdef GEN patched_parisizemax(const char* v, long flag) noexcept:
    # Cast to `int(*)() noexcept` to avoid exception handling
    if (<int(*)() noexcept>before_resize)():
        sig_error()
    return sd_parisizemax(v, flag)


IF HAVE_PLOT_SVG:
    cdef void get_plot_ipython(PARI_plot* T) noexcept:
        # Values copied from src/graph/plotsvg.c in PARI sources
        T.width = 480
        T.height = 320
        T.hunit = 3
        T.vunit = 3
        T.fwidth = 9
        T.fheight = 12

        T.draw = draw_ipython

    cdef void draw_ipython(PARI_plot *T, GEN w, GEN x, GEN y) noexcept:
        global avma
        cdef pari_sp av = avma
        cdef char* svg = rect2svg(w, x, y, T)
        from IPython.core.display import SVG, display
        display(SVG(svg))
        avma = av
