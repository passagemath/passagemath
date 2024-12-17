# sage_setup: distribution = sagemath-pari
# cython: language_level=3str
"""
The Gen class wrapping PARI's GEN type
**************************************

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

- Peter Bruin (2013-11-17): move Pari to a separate file
  (:trac:`15185`)

- Jeroen Demeyer (2014-02-09): upgrade to PARI 2.7 (:trac:`15767`)

- Martin von Gagern (2014-12-17): Added some Galois functions (:trac:`17519`)

- Jeroen Demeyer (2015-01-12): upgrade to PARI 2.8 (:trac:`16997`)

- Jeroen Demeyer (2015-03-17): automatically generate methods from
  ``pari.desc`` (:trac:`17631` and :trac:`17860`)

- Kiran Kedlaya (2016-03-23): implement infinity type

- Luca De Feo (2016-09-06): Separate Sage-specific components from
  generic C-interface in ``Pari`` (:trac:`20241`)

- Vincent Delecroix (2017-04-29): Python 3 support and doctest
  conversion
"""

# ****************************************************************************
#       Copyright (C) 2006,2010 William Stein <wstein@gmail.com>
#       Copyright (C) ???? Justin Walker
#       Copyright (C) ???? Gonzalo Tornaria
#       Copyright (C) 2010 Robert Bradshaw <robertwb@math.washington.edu>
#       Copyright (C) 2010-2018 Jeroen Demeyer <J.Demeyer@UGent.be>
#       Copyright (C) 2016 Luca De Feo <luca.defeo@polytechnique.edu>
#       Copyright (C) 2017 Vincent Delecroix <vincent.delecroix@labri.fr>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

cimport cython

from cpython.object cimport (Py_EQ, Py_NE, Py_LE, Py_GE, Py_LT, PyTypeObject)

from cysignals.memory cimport sig_free, check_malloc
from cysignals.signals cimport sig_check, sig_on, sig_off, sig_block, sig_unblock

from .types cimport *
from .string_utils cimport to_string, to_bytes
from .paripriv cimport *
from .convert cimport PyObject_AsGEN, gen_to_integer
from .pari_instance cimport (prec_bits_to_words,
                             default_bitprec, get_var)
from .stack cimport (new_gen, new_gens2, new_gen_noclear,
                     clone_gen, clear_stack, reset_avma,
                     remove_from_pari_stack, move_gens_to_heap)
from .closure cimport objtoclosure

from .paridecl cimport *

include 'auto_gen.pxi'


cdef bint ellwp_flag1_bug = -1
cdef inline bint have_ellwp_flag1_bug() except -1:
    """
    The PARI function ``ellwp(..., flag=1)`` has a bug in PARI versions
    2.9.x where the derivative is a factor 2 too small.

    This function does a cached check for this bug, returning 1 if
    the bug is there and 0 if not.
    """
    global ellwp_flag1_bug
    if ellwp_flag1_bug >= 0:
        return ellwp_flag1_bug

    # Check whether our PARI/GP version is buggy or not. This
    # computation should return 1.0, but in older PARI versions it
    # returns 0.5.
    sig_on()
    cdef GEN res = gp_read_str(b"localbitprec(128); my(E=ellinit([0,1/4])); ellwp(E,ellpointtoz(E,[0,1/2]),1)[2]")
    cdef double d = gtodouble(res)
    sig_off()

    if d == 1.0:
        ellwp_flag1_bug = 0
    elif d == 0.5:
        ellwp_flag1_bug = 1
    else:
        raise AssertionError(f"unexpected result from ellwp() test: {d}")
    return ellwp_flag1_bug


# Compatibility wrappers
cdef extern from *:
    """
    #if PARI_VERSION_CODE >= PARI_VERSION(2, 10, 1)
    #define new_nf_nfzk nf_nfzk
    #define new_nfeltup nfeltup
    #else
    static GEN new_nf_nfzk(GEN nf, GEN rnfeq)
    {
        GEN zknf, czknf;
        nf_nfzk(nf, rnfeq, &zknf, &czknf);
        return mkvec2(zknf, czknf);
    }

    static GEN new_nfeltup(GEN nf, GEN x, GEN arg)
    {
        GEN zknf = gel(arg, 1);
        GEN czknf = gel(arg, 2);
        return nfeltup(nf, x, zknf, czknf);
    }
    #endif

    #if PARI_VERSION_CODE >= PARI_VERSION(2, 12, 0)
    #define old_nfbasis(x, yptr, p) nfbasis(mkvec2(x, p), yptr)
    #else
    #define old_nfbasis nfbasis
    #endif
    """
    GEN new_nf_nfzk(GEN nf, GEN rnfeq)
    GEN new_nfeltup(GEN nf, GEN x, GEN zknf)
    GEN old_nfbasis(GEN x, GEN * y, GEN p)


@cython.trashcan(True)
cdef class Gen(Gen_base):
    """
    Wrapper for a PARI ``GEN`` with memory management.

    This wraps PARI objects which live either on the PARI stack or on
    the PARI heap. Results from PARI computations appear on the PARI
    stack and we try to keep them there. However, when the stack fills
    up, we copy ("clone" in PARI speak) all live objects from the stack
    to the heap. This happens transparently for the user.
    """
    def __init__(self):
        raise RuntimeError("PARI objects cannot be instantiated directly; use pari(x) to convert x to PARI")

    def __dealloc__(self):
        if self.next is not None:
            # stack
            remove_from_pari_stack(self)
        elif self.address is not NULL:
            # clone
            gunclone_deep(self.address)

    cdef Gen new_ref(self, GEN g):
        """
        Create a new ``Gen`` pointing to ``g``, which is a component
        of ``self.g``.

        In this case, ``g`` should point to some location in the memory
        allocated by ``self``. This will not allocate any new memory:
        the newly returned ``Gen`` will point to the memory allocated
        for ``self``.

        .. NOTE::

            Usually, there is only one ``Gen`` pointing to a given PARI
            ``GEN``.  This function can be used when a complicated
            ``GEN`` is allocated with a single ``Gen`` pointing to it,
            and one needs a ``Gen`` pointing to one of its components.

            For example, doing ``x = pari("[1, 2]")`` allocates a ``Gen``
            pointing to the list ``[1, 2]``.  To create a ``Gen`` pointing
            to the first element, one can do ``x.new_ref(gel(x.fixGEN(), 1))``.
            See :meth:`Gen.__getitem__` for an example of usage.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari("[[1, 2], 3]")[0][1]  # indirect doctest
        2
        """
        if self.next is not None:
            raise TypeError("cannot create reference to PARI stack (call fixGEN() first)")
        if is_on_stack(g):
            raise ValueError("new_ref() called with GEN which does not belong to parent")

        if self.address is not NULL:
            gclone_refc(self.address)
        return Gen_new(g, self.address)

    cdef GEN fixGEN(self) except NULL:
        """
        Return the PARI ``GEN`` corresponding to ``self`` which is
        guaranteed not to change.
        """
        if self.next is not None:
            move_gens_to_heap(self.sp())
        return self.g

    cdef GEN ref_target(self) except NULL:
        """
        Return a PARI ``GEN`` corresponding to ``self`` which is usable
        as target for a reference in another ``GEN``.

        This increases the PARI refcount of ``self``.
        """
        if is_universal_constant(self.g):
            return self.g
        return gcloneref(self.fixGEN())

    def __repr__(self):
        """
        Display representation of a gen.

        OUTPUT: a Python string

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari('vector(5,i,i)')
        [1, 2, 3, 4, 5]
        >>> pari('[1,2;3,4]')
        [1, 2; 3, 4]
        >>> pari('Str(hello)')
        "hello"
        """
        cdef char *c
        sig_on()
        # Use sig_block(), which is needed because GENtostr() uses
        # malloc(), which is dangerous inside sig_on()
        sig_block()
        c = GENtostr(self.g)
        sig_unblock()
        sig_off()

        s = bytes(c)
        pari_free(c)
        return to_string(s)

    def __str__(self):
        """
        Convert this Gen to a string.

        Except for PARI strings, we have ``str(x) == repr(x)``.
        For strings (type ``t_STR``), the returned string is not quoted.

        OUTPUT: a Python string

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> str(pari('vector(5,i,i)'))
        '[1, 2, 3, 4, 5]'
        >>> str(pari('[1,2;3,4]'))
        '[1, 2; 3, 4]'
        >>> str(pari('Str(hello)'))
        'hello'
        """
        # Use __repr__ except for strings
        if typ(self.g) == t_STR:
            return to_string(GSTR(self.g))
        return repr(self)

    def __hash__(self):
        """
        Return the hash of self, computed using PARI's hash_GEN().

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> type(pari('1 + 2.0*I').__hash__())
        <... 'int'>
        >>> L = pari("[42, 2/3, 3.14]")
        >>> hash(L) == hash(L.__copy__())
        True
        >>> hash(pari.isprime(4)) == hash(pari(0))
        True
        """
        # There is a bug in PARI/GP where the hash value depends on the
        # CLONE bit. So we remove that bit before hashing. See
        # https://pari.math.u-bordeaux.fr/cgi-bin/bugreport.cgi?bug=2091
        cdef ulong* G = <ulong*>self.g
        cdef ulong G0 = G[0]
        cdef ulong G0clean = G0 & ~<ulong>CLONEBIT
        if G0 != G0clean:
            # Only write if we actually need to change something, as
            # G may point to read-only memory
            G[0] = G0clean
        h = hash_GEN(self.g)
        if G0 != G0clean:
            # Restore CLONE bit
            G[0] = G0
        return h

    def __iter__(self):
        """
        Iterate over the components of ``self``.

        The items in the iteration are of type :class:`Gen` with the
        following exceptions:

        - items of a ``t_VECSMALL`` are of type ``int``

        - items of a ``t_STR`` are of type ``str``

        Examples:

        We can iterate over PARI vectors or columns:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> L = pari("vector(10,i,i^2)")
        >>> L.__iter__()
        <...generator object at ...>
        >>> [x for x in L]
        [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
        >>> list(L)
        [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
        >>> list(pari("vector(10,i,i^2)~"))
        [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

        For polynomials, we iterate over the list of coefficients:

        >>> pol = pari("x^3 + 5/3*x"); list(pol)
        [0, 5/3, 0, 1]

        For power series or Laurent series, we get all coefficients starting
        from the lowest degree term.  This includes trailing zeros:

        >>> list(pari('x^2 + O(x^8)'))
        [1, 0, 0, 0, 0, 0]
        >>> list(pari('x^-2 + O(x^0)'))
        [1, 0]

        For matrices, we iterate over the columns:

        >>> M = pari.matrix(3,2,[1,4,2,5,3,6]); M
        [1, 4; 2, 5; 3, 6]
        >>> list(M)
        [[1, 2, 3]~, [4, 5, 6]~]

        Other types are first converted to a vector using :meth:`Vec`:

        >>> Q = pari('Qfb(1, 2, 3)')
        >>> tuple(Q)
        (1, 2, 3)
        >>> Q.Vec()
        [1, 2, 3]

        We get an error for "scalar" types or for types which cannot be
        converted to a PARI vector:

        >>> iter(pari(42))
        Traceback (most recent call last):
        ...
        TypeError: PARI object of type t_INT is not iterable
        >>> iter(pari("x->x"))
        Traceback (most recent call last):
        ...
        PariError: incorrect type in gtovec (t_CLOSURE)

        For ``t_VECSMALL``, the items are Python integers:

        >>> v = pari("Vecsmall([1,2,3,4,5,6])")
        >>> list(v)
        [1, 2, 3, 4, 5, 6]
        >>> type(list(v)[0]).__name__
        'int'

        For ``t_STR``, the items are Python strings:

        >>> v = pari('"hello"')
        >>> list(v)
        ['h', 'e', 'l', 'l', 'o']
        """
        # We return a generator expression instead of using "yield"
        # because we want to raise an exception for non-iterable
        # objects immediately when calling __iter__() and not while
        # iterating.
        cdef long i
        cdef long t = typ(self.g)

        # First convert self to a vector type
        cdef Gen v
        if t == t_VEC or t == t_COL or t == t_MAT:
            # These are vector-like and can be iterated over directly
            v = self
        elif t == t_POL:
            v = self.Vecrev()
        elif is_scalar_t(t):
            raise TypeError(f"PARI object of type {self.type()} is not iterable")
        elif t == t_VECSMALL:
            # Special case: items of type int
            return (self.g[i] for i in range(1, lg(self.g)))
        elif t == t_STR:
            # Special case: convert to str
            return iter(to_string(GSTR(self.g)))
        else:
            v = self.Vec()

        # Now iterate over the vector v
        x = v.fixGEN()
        return (v.new_ref(gel(x, i)) for i in range(1, lg(x)))

    def list(self):
        """
        Convert ``self`` to a Python list with :class:`Gen` components.

        Examples:

        A PARI vector becomes a Python list:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> L = pari("vector(10,i,i^2)").list()
        >>> L
        [1, 4, 9, 16, 25, 36, 49, 64, 81, 100]
        >>> type(L)
        <... 'list'>
        >>> type(L[0])
        <... 'cypari2.gen.Gen'>

        For polynomials, list() returns the list of coefficients:

        >>> pol = pari("x^3 + 5/3*x"); pol.list()
        [0, 5/3, 0, 1]

        For power series or Laurent series, we get all coefficients starting
        from the lowest degree term.  This includes trailing zeros:

        >>> pari('x^2 + O(x^8)').list()
        [1, 0, 0, 0, 0, 0]
        >>> pari('x^-2 + O(x^0)').list()
        [1, 0]

        For matrices, we get a list of columns:

        >>> M = pari.matrix(3,2,[1,4,2,5,3,6]); M
        [1, 4; 2, 5; 3, 6]
        >>> M.list()
        [[1, 2, 3]~, [4, 5, 6]~]
        """
        return [x for x in self]

    def __reduce__(self):
        """
        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> from pickle import loads, dumps

        >>> f = pari('x^3 - 3')
        >>> loads(dumps(f)) == f
        True
        >>> f = pari('"hello world"')
        >>> loads(dumps(f)) == f
        True
        """
        s = repr(self)
        return (objtogen, (s,))

    def __add__(left, right):
        """
        Return ``left`` plus ``right``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(15) + pari(6)
        21
        >>> pari("x^3+x^2+x+1") + pari("x^2")
        x^3 + 2*x^2 + x + 1
        >>> 2e20 + pari("1e20")
        3.00000000000000 E20
        >>> -2 + pari(3)
        1
        """
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gadd(t0.g, t1.g))

    def __sub__(left, right):
        """
        Return ``left`` minus ``right``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(15) - pari(6)
        9
        >>> pari("x^3+x^2+x+1") - pari("x^2")
        x^3 + x + 1
        >>> 2e20 - pari("1e20")
        1.00000000000000 E20
        >>> -2 - pari(3)
        -5
        """
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gsub(t0.g, t1.g))

    def __mul__(left, right):
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gmul(t0.g, t1.g))

    def __div__(left, right):
        # Python 2 old-style division: same implementation as __truediv__
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gdiv(t0.g, t1.g))

    def __truediv__(left, right):
        """
        Examples:

        >>> from cypari2 import Pari; pari = Pari()
        >>> pari(11) / pari(4)
        11/4
        >>> pari("x^2 + 2*x + 3") / pari("x")
        (x^2 + 2*x + 3)/x
        """
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gdiv(t0.g, t1.g))

    def __floordiv__(left, right):
        """
        Examples:

        >>> from cypari2 import Pari; pari = Pari()
        >>> pari(11) // pari(4)
        2
        >>> pari("x^2 + 2*x + 3") // pari("x")
        x + 2
        """
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gdivent(t0.g, t1.g))

    def __mod__(left, right):
        """
        Return ``left`` modulo ``right``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(15) % pari(6)
        3
        >>> pari("x^3+x^2+x+1") % pari("x^2")
        x + 1
        >>> pari(-2) % 3
        1
        >>> -2 % pari(3)
        1
        """
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        sig_on()
        return new_gen(gmod(t0.g, t1.g))

    def __pow__(left, right, m):
        """
        Return ``left`` to the power ``right`` (if ``m`` is ``None``) or
        ``Mod(left, m)^right`` if ``m`` is not ``None``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(5) ** pari(3)
        125
        >>> pari("x-1") ** 3
        x^3 - 3*x^2 + 3*x - 1
        >>> pow(pari(5), pari(28), int(29))
        Mod(1, 29)
        >>> 2 ** pari(-5)
        1/32
        >>> pari(2) ** -5
        1/32
        """
        cdef Gen t0, t1
        try:
            t0 = objtogen(left)
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        if m is not None:
            t0 = t0.Mod(m)
        sig_on()
        return new_gen(gpow(t0.g, t1.g, prec_bits_to_words(0)))

    def __neg__(self):
        sig_on()
        return new_gen(gneg(self.g))

    def __rshift__(self, long n):
        """
        Divide ``self`` by `2^n` (truncating or not, depending on the
        input type).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(25) >> 3
        3
        >>> pari('25/2') >> 2
        25/8
        >>> pari("x") >> 3
        1/8*x
        >>> pari(1.0) >> 100
        7.88860905221012 E-31
        >>> 33 >> pari(2)
        8
        """
        cdef Gen t0 = objtogen(self)
        sig_on()
        return new_gen(gshift(t0.g, -n))

    def __lshift__(self, long n):
        """
        Multiply ``self`` by `2^n`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(25) << 3
        200
        >>> pari("25/32") << 2
        25/8
        >>> pari("x") << 3
        8*x
        >>> pari(1.0) << 100
        1.26765060022823 E30
        >>> 33 << pari(2)
        132
        """
        cdef Gen t0 = objtogen(self)
        sig_on()
        return new_gen(gshift(t0.g, n))

    def __invert__(self):
        sig_on()
        return new_gen(ginv(self.g))

    def getattr(self, attr):
        """
        Return the PARI attribute with the given name.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari("nfinit(x^2 - x - 1)")
        >>> K.getattr("pol")
        x^2 - x - 1
        >>> K.getattr("disc")
        5

        >>> K.getattr("reg")
        Traceback (most recent call last):
        ...
        PariError: _.reg: incorrect type in reg (t_VEC)
        >>> K.getattr("zzz")
        Traceback (most recent call last):
        ...
        PariError: not a function in function call
        """
        attr = to_bytes(attr)
        t = b"_." + attr
        sig_on()
        return new_gen(closure_callgen1(strtofunction(t), self.g))

    def mod(self):
        """
        Given an INTMOD or POLMOD ``Mod(a,m)``, return the modulus `m`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(4).Mod(5).mod()
        5
        >>> pari("Mod(x, x*y)").mod()
        y*x
        >>> pari("[Mod(4,5)]").mod()
        Traceback (most recent call last):
        ...
        TypeError: Not an INTMOD or POLMOD in mod()
        """
        if typ(self.g) != t_INTMOD and typ(self.g) != t_POLMOD:
            raise TypeError("Not an INTMOD or POLMOD in mod()")
        # The hardcoded 1 below refers to the position in the internal
        # representation of a INTMOD or POLDMOD where the modulus is
        # stored.
        return self.new_ref(gel(self.fixGEN(), 1))

    # Special case: SageMath uses polred(), so mark it as not
    # obsolete: https://trac.sagemath.org/ticket/22165
    def polred(self, *args, **kwds):
        r'''
        This function is :emphasis:`deprecated`,
        use :meth:`~cypari2.gen.Gen_base.polredbest` instead.
        '''
        import warnings
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            return super(Gen, self).polred(*args, **kwds)

    def nf_get_pol(self):
        """
        Returns the defining polynomial of this number field.

        INPUT:

        - ``self`` -- A PARI number field being the output of ``nfinit()``,
                      ``bnfinit()`` or ``bnrinit()``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**4 - 4*x**2 + 1).bnfinit()
        >>> bnr = K.bnrinit(2*x)
        >>> bnr.nf_get_pol()
        x^4 - 4*x^2 + 1

        For relative number fields, this returns the relative
        polynomial:

        >>> y = pari.varhigher('y')
        >>> L = K.rnfinit(y**2 - 5)
        >>> L.nf_get_pol()
        y^2 - 5

        An error is raised for invalid input:

        >>> pari("[0]").nf_get_pol()
        Traceback (most recent call last):
        ...
        PariError: incorrect type in pol (t_VEC)
        """
        sig_on()
        return clone_gen(member_pol(self.g))

    def nf_get_diff(self):
        """
        Returns the different of this number field as a PARI ideal.

        INPUT:

        - ``self`` -- A PARI number field being the output of ``nfinit()``,
                      ``bnfinit()`` or ``bnrinit()``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**4 - 4*x**2 + 1).nfinit()
        >>> K.nf_get_diff()
        [12, 0, 0, 0; 0, 12, 8, 0; 0, 0, 4, 0; 0, 0, 0, 4]
        """
        sig_on()
        return clone_gen(member_diff(self.g))

    def nf_get_sign(self):
        """
        Returns a Python list ``[r1, r2]``, where ``r1`` and ``r2`` are
        Python ints representing the number of real embeddings and pairs
        of complex embeddings of this number field, respectively.

        INPUT:

        - ``self`` -- A PARI number field being the output of ``nfinit()``,
                      ``bnfinit()`` or ``bnrinit()``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**4 - 4*x**2 + 1).nfinit()
        >>> s = K.nf_get_sign(); s
        [4, 0]
        >>> type(s); type(s[0])
        <... 'list'>
        <... 'int'>
        >>> pari.polcyclo(15).nfinit().nf_get_sign()
        [0, 4]
        """
        cdef long r1
        cdef long r2
        cdef GEN sign
        sig_on()
        sign = member_sign(self.g)
        r1 = itos(gel(sign, 1))
        r2 = itos(gel(sign, 2))
        sig_off()
        return [r1, r2]

    def nf_get_zk(self):
        r"""
        Returns a vector with a `\ZZ`-basis for the ring of integers of
        this number field. The first element is always `1`.

        INPUT:

        - ``self`` -- A PARI number field being the output of ``nfinit()``,
                      ``bnfinit()`` or ``bnrinit()``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**4 - 4*x**2 + 1).nfinit()
        >>> K.nf_get_zk()
        [1, x, x^3 - 4*x, x^2 - 2]
        """
        sig_on()
        return clone_gen(member_zk(self.g))

    def bnf_get_fu(self):
        """
        Return the fundamental units

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')

        >>> (x**2 - 65).bnfinit().bnf_get_fu()
        [Mod(x - 8, x^2 - 65)]
        >>> (x**4 - x**2 + 1).bnfinit().bnf_get_fu()
        [Mod(x - 1, x^4 - x^2 + 1)]
        >>> p = x**8 - 40*x**6 + 352*x**4 - 960*x**2 + 576
        >>> len(p.bnfinit().bnf_get_fu())
        7
        """
        sig_on()
        return clone_gen(member_fu(self.g))

    def bnf_get_tu(self):
        r"""
        Return the torsion unit

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')

        >>> for p in [x**2 - 65, x**4 - x**2 + 1, x**8 - 40*x**6 + 352*x**4 - 960*x**2 + 576]:
        ...     bnf = p.bnfinit()
        ...     n, z = bnf.bnf_get_tu()
        ...     if pari.version() < (2,11,0) and z.lift().poldegree() == 0: z = z.lift()
        ...     print([p, n, z])
        [x^2 - 65, 2, -1]
        [x^4 - x^2 + 1, 12, Mod(x, x^4 - x^2 + 1)]
        [x^8 - 40*x^6 + 352*x^4 - 960*x^2 + 576, 2, -1]
        """
        sig_on()
        return clone_gen(member_tu(self.g))

    def bnfunit(self):
        r"""
        Deprecated in cypari 2.1.2

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()


        >>> x = pari('x')

        >>> import warnings
        >>> with warnings.catch_warnings(record=True) as w:
        ...     warnings.simplefilter('always')
        ...     funits = (x**2 - 65).bnfinit().bnfunit()
        ...     assert len(w) == 1
        ...     assert issubclass(w[0].category, DeprecationWarning)
        >>> funits
        [Mod(x - 8, x^2 - 65)]
        """
        from warnings import warn
        warn("'bnfunit' in cypari2 is deprecated, use 'bnf_get_fu'", DeprecationWarning)
        return self.bnf_get_fu()

    def bnf_get_no(self):
        """
        Returns the class number of ``self``, a "big number field" (``bnf``).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**2 + 65).bnfinit()
        >>> K.bnf_get_no()
        8
        """
        sig_on()
        return clone_gen(bnf_get_no(self.g))

    def bnf_get_cyc(self):
        """
        Returns the structure of the class group of this number field as
        a vector of SNF invariants.

        NOTE: ``self`` must be a "big number field" (``bnf``).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**2 + 65).bnfinit()
        >>> K.bnf_get_cyc()
        [4, 2]
        """
        sig_on()
        return clone_gen(bnf_get_cyc(self.g))

    def bnf_get_gen(self):
        """
        Returns a vector of generators of the class group of this
        number field.

        NOTE: ``self`` must be a "big number field" (``bnf``).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**2 + 65).bnfinit()
        >>> G = K.bnf_get_gen(); G
        [[3, 2; 0, 1], [2, 1; 0, 1]]
        """
        sig_on()
        return clone_gen(bnf_get_gen(self.g))

    def bnf_get_reg(self):
        """
        Returns the regulator of this number field.

        NOTE: ``self`` must be a "big number field" (``bnf``).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari('x')
        >>> K = (x**4 - 4*x**2 + 1).bnfinit()
        >>> K.bnf_get_reg()
        2.66089858019037...
        """
        sig_on()
        return clone_gen(bnf_get_reg(self.g))

    def idealmoddivisor(self, Gen ideal):
        """
        Return a 'small' ideal equivalent to ``ideal`` in the
        ray class group that the bnr structure ``self`` encodes.

        INPUT:

        - ``self`` -- a bnr structure as outputted from bnrinit.
        - ``ideal`` -- an ideal in the underlying number field of
          the bnr structure.

        OUTPUT: An ideal representing the same ray class as ``ideal``
        but with 'small' generators. If ``ideal`` is not coprime to
        the modulus of the bnr, this results in an error.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> i = pari('i')
        >>> K = (i**4 - 2).bnfinit()
        >>> R = K.bnrinit(5,1)
        >>> R.idealmoddivisor(K[6][6][1])
        [2, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]
        >>> R.idealmoddivisor(K.idealhnf(5))
        Traceback (most recent call last):
        ...
        PariError: elements not coprime in idealaddtoone:
            [5, 0, 0, 0; 0, 5, 0, 0; 0, 0, 5, 0; 0, 0, 0, 5]
            [5, 0, 0, 0; 0, 5, 0, 0; 0, 0, 5, 0; 0, 0, 0, 5]
        """
        sig_on()
        return new_gen(idealmoddivisor(self.g, ideal.g))

    def pr_get_p(self):
        r"""
        Returns the prime of `\ZZ` lying below this prime ideal.

        NOTE: ``self`` must be a PARI prime ideal (as returned by
        ``idealprimedec`` for example).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> i = pari('i')
        >>> K = (i**2 + 1).nfinit()
        >>> F = K.idealprimedec(5); F
        [[5, [-2, 1]~, 1, 1, [2, -1; 1, 2]], [5, [2, 1]~, 1, 1, [-2, -1; 1, -2]]]
        >>> F[0].pr_get_p()
        5
        """
        sig_on()
        return clone_gen(pr_get_p(self.g))

    def pr_get_e(self):
        r"""
        Returns the ramification index (over `\QQ`) of this prime ideal.

        NOTE: ``self`` must be a PARI prime ideal (as returned by
        ``idealprimedec`` for example).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> i = pari('i')
        >>> K = (i**2 + 1).nfinit()
        >>> K.idealprimedec(2)[0].pr_get_e()
        2
        >>> K.idealprimedec(3)[0].pr_get_e()
        1
        >>> K.idealprimedec(5)[0].pr_get_e()
        1
        """
        cdef long e
        sig_on()
        e = pr_get_e(self.g)
        sig_off()
        return e

    def pr_get_f(self):
        r"""
        Returns the residue class degree (over `\QQ`) of this prime ideal.

        NOTE: ``self`` must be a PARI prime ideal (as returned by
        ``idealprimedec`` for example).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> i = pari('i')
        >>> K = (i**2 + 1).nfinit()
        >>> K.idealprimedec(2)[0].pr_get_f()
        1
        >>> K.idealprimedec(3)[0].pr_get_f()
        2
        >>> K.idealprimedec(5)[0].pr_get_f()
        1
        """
        cdef long f
        sig_on()
        f = pr_get_f(self.g)
        sig_off()
        return f

    def pr_get_gen(self):
        """
        Returns the second generator of this PARI prime ideal, where the
        first generator is ``self.pr_get_p()``.

        NOTE: ``self`` must be a PARI prime ideal (as returned by
        ``idealprimedec`` for example).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> i = pari('i')
        >>> K = (i**2 + 1).nfinit()
        >>> g = K.idealprimedec(2)[0].pr_get_gen(); g
        [1, 1]~
        >>> g = K.idealprimedec(3)[0].pr_get_gen(); g
        [3, 0]~
        >>> g = K.idealprimedec(5)[0].pr_get_gen(); g
        [-2, 1]~
        """
        sig_on()
        return clone_gen(pr_get_gen(self.g))

    def bid_get_cyc(self):
        """
        Returns the structure of the group `(O_K/I)^*`, where `I` is the
        ideal represented by ``self``.

        NOTE: ``self`` must be a "big ideal" (``bid``) as returned by
        ``idealstar`` for example.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> i = pari('i')
        >>> K = (i**2 + 1).bnfinit()
        >>> J = K.idealstar(4*i + 2)
        >>> J.bid_get_cyc()
        [4, 2]
        """
        sig_on()
        return clone_gen(bid_get_cyc(self.g))

    def bid_get_gen(self):
        """
        Returns a vector of generators of the group `(O_K/I)^*`, where
        `I` is the ideal represented by ``self``.

        NOTE: ``self`` must be a "big ideal" (``bid``) with generators,
        as returned by ``idealstar`` with ``flag`` = 2.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> i = pari('i')
        >>> K = (i**2 + 1).bnfinit()
        >>> J = K.idealstar(4*i + 2, 2)
        >>> J.bid_get_gen()
        [7, [-2, -1]~]

        We get an exception if we do not supply ``flag = 2`` to
        ``idealstar``:

        >>> J = K.idealstar(3)
        >>> J.bid_get_gen()
        Traceback (most recent call last):
        ...
        PariError: missing bid generators. Use idealstar(,,2)
        """
        sig_on()
        return clone_gen(bid_get_gen(self.g))

    def __getitem__(self, n):
        """
        Return the n-th entry of self.

        .. NOTE::

            The indexing is 0-based, like everywhere else in Python,
            but *unlike* in PARI/GP.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> p = pari('1 + 2*x + 3*x^2')
        >>> p[0]
        1
        >>> p[2]
        3
        >>> p[100]
        0
        >>> p[-1]
        0
        >>> q = pari('x^2 + 3*x^3 + O(x^6)')
        >>> q[3]
        3
        >>> q[5]
        0
        >>> q[6]
        Traceback (most recent call last):
        ...
        IndexError: index out of range
        >>> m = pari('[1,2;3,4]')
        >>> m[0]
        [1, 3]~
        >>> m[1,0]
        3
        >>> l = pari('List([1,2,3])')
        >>> l[1]
        2
        >>> s = pari('"hello, world!"')
        >>> s[0]
        'h'
        >>> s[4]
        'o'
        >>> s[12]
        '!'
        >>> s[13]
        Traceback (most recent call last):
        ...
        IndexError: index out of range
        >>> v = pari('[1,2,3]')
        >>> v[0]
        1
        >>> c = pari('Col([1,2,3])')
        >>> c[1]
        2
        >>> sv = pari('Vecsmall([1,2,3])')
        >>> sv[2]
        3
        >>> type(sv[2])
        <... 'int'>
        >>> [pari('1 + 5*I')[i] for i in range(2)]
        [1, 5]
        >>> [pari('Qfb(1, 2, 3)')[i] for i in range(3)]
        [1, 2, 3]
        >>> pari(57)[0]
        Traceback (most recent call last):
        ...
        TypeError: PARI object of type t_INT cannot be indexed
        >>> m = pari("[[1,2;3,4],5]") ; m[0][1,0]
        3
        >>> v = pari(range(20))
        >>> v[2:5]
        [2, 3, 4]
        >>> v[:]
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        >>> v[10:]
        [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        >>> v[:5]
        [0, 1, 2, 3, 4]
        >>> v[5:5]
        []
        >>> v
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        >>> v[-1]
        Traceback (most recent call last):
        ...
        IndexError: index out of range
        >>> v[:-3]
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
        >>> v[5:]
        [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        >>> pari([])[::]
        []
        """
        cdef Py_ssize_t i, j, k
        cdef object ind
        cdef int pari_type

        pari_type = typ(self.g)

        if isinstance(n, tuple):
            if pari_type != t_MAT:
                raise TypeError("tuple indices are only defined for matrices")

            i, j = n

            if i < 0 or i >= glength(gel(self.g, 1)):
                raise IndexError("row index out of range")
            if j < 0 or j >= glength(self.g):
                raise IndexError("column index out of range")

            ind = (i, j)

            if self.itemcache is not None and ind in self.itemcache:
                return self.itemcache[ind]
            else:
                # Create a new Gen as child of self
                # and store it in itemcache
                val = self.new_ref(gmael(self.fixGEN(), j+1, i+1))
                self.cache(ind, val)
                return val

        elif isinstance(n, slice):
            l = glength(self.g)
            start, stop, step = n.indices(l)
            inds = xrange(start, stop, step)
            k = len(inds)
            # fast exit for empty vector
            if k == 0:
                sig_on()
                return new_gen(zerovec(0))
            # fast call, beware pari is one based
            if pari_type == t_VEC:
                if step==1:
                    return self.vecextract('"'+str(start+1)+".."+str(stop)+'"')
                if step==-1:
                    return self.vecextract('"'+str(start+1)+".."+str(stop+2)+'"')
            # slow call
            return objtogen(self[i] for i in inds)

        # Index is not a tuple or slice, convert to integer
        i = n

        # there are no "out of bounds" problems
        # for a polynomial or power series, so these go before
        # bounds testing
        if pari_type == t_POL:
            sig_on()
            return new_gen(polcoeff0(self.g, i, -1))

        elif pari_type == t_SER:
            bound = valp(self.g) + lg(self.g) - 2
            if i >= bound:
                raise IndexError("index out of range")
            sig_on()
            return new_gen(polcoeff0(self.g, i, -1))

        elif pari_type in (t_INT, t_REAL, t_FRAC, t_RFRAC, t_PADIC, t_QUAD, t_FFELT, t_INTMOD, t_POLMOD):
            # these are definitely scalar!
            raise TypeError(f"PARI object of type {self.type()} cannot be indexed")

        elif i < 0 or i >= glength(self.g):
            raise IndexError("index out of range")

        elif pari_type == t_VEC or pari_type == t_MAT:
            # t_VEC    : row vector        [ code ] [  x_1  ] ... [  x_k  ]
            # t_MAT    : matrix            [ code ] [ col_1 ] ... [ col_k ]
            ind = i
            if self.itemcache is not None and ind in self.itemcache:
                return self.itemcache[ind]
            else:
                # Create a new Gen as child of self
                # and store it in itemcache
                val = self.new_ref(gel(self.fixGEN(), i+1))
                self.cache(ind, val)
                return val

        elif pari_type == t_VECSMALL:
            # t_VECSMALL: vec. small ints  [ code ] [ x_1 ] ... [ x_k ]
            return self.g[i+1]

        elif pari_type == t_STR:
            # t_STR    : string            [ code ] [ man_1 ] ... [ man_k ]
            return chr(GSTR(self.g)[i])

        elif pari_type == t_LIST:
            return self.component(i+1)

        else:
            # generic code for other types
            return self.new_ref(gel(self.fixGEN(), i+1))

    def __setitem__(self, n, y):
        r"""
        Set the n-th entry to a reference to y.

        .. NOTE::

            - The indexing is 0-based, like everywhere else in Python,
              but *unlike* in PARI/GP.

            - Assignment sets the nth entry to a reference to y. This is
              the same as in Python, but *different* than what happens in
              the GP interpreter, where assignment makes a copy of y.

            - Because setting creates references it is *possible* to make
              circular references, unlike in GP. Do *not* do this (see the
              example below). If you need circular references, work at the
              Python level (where they work well), not the PARI object
              level.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> l = pari.List([1,2,3])
        >>> l[0] = 3
        >>> l
        List([3, 2, 3])

        >>> v = pari(range(10))
        >>> v
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        >>> v[0] = 10
        >>> w = pari([5,8,-20])
        >>> v
        [10, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        >>> v[1] = w
        >>> v
        [10, [5, 8, -20], 2, 3, 4, 5, 6, 7, 8, 9]
        >>> w[0] = -30
        >>> v
        [10, [-30, 8, -20], 2, 3, 4, 5, 6, 7, 8, 9]
        >>> t = v[1]; t[1] = 10 ; v
        [10, [-30, 10, -20], 2, 3, 4, 5, 6, 7, 8, 9]
        >>> v[1][0] = 54321 ; v
        [10, [54321, 10, -20], 2, 3, 4, 5, 6, 7, 8, 9]
        >>> w
        [54321, 10, -20]
        >>> v = pari([[[[0,1],2],3],4])
        >>> v[0][0][0][1] = 12
        >>> v
        [[[[0, 12], 2], 3], 4]
        >>> m = pari.matrix(2,2,range(4)) ; l = pari([5,6]) ; n = pari.matrix(2,2,[7,8,9,0]) ; m[1,0] = l ; l[1] = n ; m[1,0][1][1,1] = 1111 ; m
        [0, 1; [5, [7, 8; 9, 1111]], 3]
        >>> m = pari("[[1,2;3,4],5,6]") ; m[0][1,1] = 11 ; m
        [[1, 2; 3, 11], 5, 6]

        Finally, we create a circular reference:

        >>> v = pari([0])
        >>> w = pari([v])
        >>> v
        [0]
        >>> w
        [[0]]
        >>> v[0] = w

        Now there is a circular reference. Accessing v[0] will crash Python.

        >>> s = pari.vector(2,[0,0])
        >>> s[:1]
        [0]
        >>> s[:1]=[1]
        >>> s
        [1, 0]
        >>> type(s[0])
        <... 'cypari2.gen.Gen'>
        >>> s = pari(range(20)) ; s
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        >>> s[0:10:2] = range(50,55) ; s
        [50, 1, 51, 3, 52, 5, 53, 7, 54, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
        >>> s[10:20:3] = range(100,150) ; s
        [50, 1, 51, 3, 52, 5, 53, 7, 54, 9, 100, 11, 12, 101, 14, 15, 102, 17, 18, 103]

        Tests:

        >>> v = pari(range(10)) ; v
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        >>> v[:] = range(20, 30)
        >>> v
        [20, 21, 22, 23, 24, 25, 26, 27, 28, 29]
        >>> type(v[0])
        <... 'cypari2.gen.Gen'>
        """
        cdef Py_ssize_t i, j
        cdef Gen x = objtogen(y)

        if isinstance(n, tuple):
            if typ(self.g) != t_MAT:
                raise TypeError("cannot index PARI type %s by tuple" % typ(self.g))

            if len(n) != 2:
                raise ValueError("matrix index must be [row, column]")

            i, j = n

            if i < 0 or i >= glength(gel(self.g, 1)):
                raise IndexError("row i(=%s) must be between 0 and %s" % (i, self.nrows()-1))
            if j < 0 or j >= glength(self.g):
                raise IndexError("column j(=%s) must be between 0 and %s" % (j, self.ncols()-1))

            self.cache((i, j), x)
            xt = x.ref_target()
            set_gcoeff(self.g, i+1, j+1, xt)
            return

        elif isinstance(n, slice):
            l = glength(self.g)
            inds = xrange(*n.indices(l))
            k = len(inds)
            if k > len(y):
                raise ValueError("attempt to assign sequence of size %s to slice of size %s" % (len(y), k))

            # actually set the values
            for a, b in enumerate(inds):
                sig_check()
                self[b] = y[a]
            return

        # Index is not a tuple or slice, convert to integer
        i = n

        if i < 0 or i >= glength(self.g):
            raise IndexError("index (%s) must be between 0 and %s" % (i, glength(self.g)-1))

        self.cache(i, x)
        xt = x.ref_target()
        if typ(self.g) == t_LIST:
            listput(self.g, xt, i+1)
        else:
            # Correct indexing for t_POLs
            if typ(self.g) == t_POL:
                i += 1
            # Actually set the value
            set_gel(self.g, i+1, xt)

    def __len__(self):
        return glength(self.g)

    def __richcmp__(self, right, int op):
        """
        Compare ``self`` and ``right`` using ``op``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> a = pari(5)
        >>> b = 10
        >>> a < b
        True
        >>> a <= b
        True
        >>> a <= 5
        True
        >>> a > b
        False
        >>> a >= b
        False
        >>> a >= pari(10)
        False
        >>> a == 5
        True
        >>> a is 5
        False

        >>> pari(2.5) > None
        True
        >>> pari(3) == pari(3)
        True
        >>> pari('x^2 + 1') == pari('I-1')
        False
        >>> pari(I) == pari(I)
        True

        This does not define a total order.  An error is raised when
        applying inequality operators to non-ordered types:

        >>> pari("Mod(1,3)") <= pari("Mod(2,3)")
        Traceback (most recent call last):
        ...
        PariError: forbidden comparison t_INTMOD , t_INTMOD
        >>> pari("[0]") <= pari("0")
        Traceback (most recent call last):
        ...
        PariError: forbidden comparison t_VEC (1 elts) , t_INT

        Tests:

        Check that :trac:`16127` has been fixed:

        >>> pari('1/2') < pari('1/3')
        False
        >>> pari(1) < pari('1/2')
        False

        >>> pari('O(x)') == 0
        True
        >>> pari('O(2)') == 0
        True
        """
        cdef Gen t1
        try:
            t1 = objtogen(right)
        except Exception:
            return NotImplemented
        cdef bint r
        cdef GEN x = self.g
        cdef GEN y = t1.g
        sig_on()
        if op == Py_EQ:
            r = (gequal(x, y) != 0)
        elif op == Py_NE:
            r = (gequal(x, y) == 0)
        elif op == Py_LE:
            r = (gcmp(x, y) <= 0)
        elif op == Py_GE:
            r = (gcmp(x, y) >= 0)
        elif op == Py_LT:
            r = (gcmp(x, y) < 0)
        else:  # Py_GT
            r = (gcmp(x, y) > 0)
        sig_off()
        return r

    def cmp(self, right):
        """
        Compare ``self`` and ``right``.

        This uses PARI's ``cmp_universal()`` routine, which defines
        a total ordering on the set of all PARI objects (up to the
        indistinguishability relation given by ``gidentical()``).

        .. WARNING::

            This comparison is only mathematically meaningful when
            comparing 2 integers. In particular, when comparing
            rationals or reals, this does not correspond to the natural
            ordering.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari(5).cmp(pari(5))
        0
        >>> pari('x^2 + 1').cmp(pari('I-1'))
        1
        >>> I = pari('I')
        >>> I.cmp(I)
        0
        >>> pari('2/3').cmp(pari('2/5'))
        -1
        >>> two = pari('2.000000000000000000000000')
        >>> two.cmp(pari(1.0))
        1
        >>> two.cmp(pari(2.0))
        1
        >>> two.cmp(pari(3.0))
        1
        >>> f = pari("0*ffgen(ffinit(29, 10))")
        >>> pari(0).cmp(f)
        -1
        >>> pari("'x").cmp(f)
        1
        >>> pari("'x").cmp(0)
        Traceback (most recent call last):
        ...
        TypeError: Cannot convert int to cypari2.gen.Gen_base
        """
        other = <Gen_base?>right
        sig_on()
        r = cmp_universal(self.g, other.g)
        sig_off()
        return r

    def __copy__(self):
        sig_on()
        return clone_gen(self.g)

    def __oct__(self):
        """
        Return the octal digits of self in lower case.
        """
        cdef GEN x
        cdef long lx
        cdef long *xp
        cdef long w
        cdef char *s
        cdef char *sp
        cdef char *octdigits = "01234567"
        cdef int i, j
        cdef int size
        x = self.g
        if typ(x) != t_INT:
            raise TypeError("gen must be of PARI type t_INT")
        if not signe(x):
            return "0"
        lx = lgefint(x) - 2  # number of words
        size = lx * 4 * sizeof(long)
        s = <char *>check_malloc(size+3)  # 1 char for sign, 1 char for 0, 1 char for '\0'
        sp = s + size + 3 - 1  # last character
        sp[0] = 0
        xp = int_LSW(x)
        for i from 0 <= i < lx:
            w = xp[0]
            for j in range(4*sizeof(long)):
                sp -= 1
                sp[0] = octdigits[w & 7]
                w >>= 3
            xp = int_nextW(xp)
        # remove leading zeros!
        while sp[0] == c'0':
            sp += 1
        sp -= 1
        sp[0] = c'0'
        if signe(x) < 0:
            sp -= 1
            sp[0] = c'-'
        k = <bytes> sp
        sig_free(s)
        return k

    def __hex__(self):
        """
        Return the hexadecimal digits of self in lower case.
        """
        cdef GEN x
        cdef long lx
        cdef long *xp
        cdef long w
        cdef char *s
        cdef char *sp
        cdef char *hexdigits = "0123456789abcdef"
        cdef int i, j
        cdef int size
        x = self.g
        if typ(x) != t_INT:
            raise TypeError("gen must be of PARI type t_INT")
        if not signe(x):
            return "0x0"
        lx = lgefint(x) - 2  # number of words
        size = lx*2*sizeof(long)
        s = <char *>check_malloc(size+4)  # 1 char for sign, 2 chars for 0x, 1 char for '\0'
        sp = s + size + 4 - 1  # last character
        sp[0] = 0
        xp = int_LSW(x)
        for i from 0 <= i < lx:
            w = xp[0]
            for j in range(2*sizeof(long)):
                sp -= 1
                sp[0] = hexdigits[w & 15]
                w >>= 4
            xp = int_nextW(xp)
        # remove leading zeros!
        while sp[0] == c'0':
            sp = sp + 1
        sp -= 1
        sp[0] = 'x'
        sp -= 1
        sp[0] = '0'
        if signe(x) < 0:
            sp -= 1
            sp[0] = c'-'
        k = <bytes> sp
        sig_free(s)
        return k

    def __int__(self):
        """
        Convert ``self`` to a Python integer.

        If the number is too large to fit into a Python ``int``, a
        Python ``long`` is returned instead.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> int(pari(0))
        0
        >>> int(pari(10))
        10
        >>> int(pari(-10))
        -10
        >>> int(pari(123456789012345678901234567890)) == 123456789012345678901234567890
        True
        >>> int(pari(-123456789012345678901234567890)) == -123456789012345678901234567890
        True
        >>> int(pari(2**31-1))
        2147483647
        >>> int(pari(-2**31))
        -2147483648
        >>> int(pari("Pol(10)"))
        10
        >>> int(pari("Mod(2, 7)"))
        2

        >>> int(pari(2**63-1)) == 9223372036854775807
        True
        >>> int(pari(2**63+2)) == 9223372036854775810
        True
        """
        return gen_to_integer(self)

    def __index__(self):
        """
        Coerce ``self`` (which must be a :class:`Gen` of type
        ``t_INT``) to a Python integer.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> from operator import index
        >>> i = pari(2)
        >>> index(i)
        2
        >>> L = [0, 1, 2, 3, 4]
        >>> L[i]
        2
        >>> print(index(pari("2^100")))
        1267650600228229401496703205376
        >>> index(pari("2.5"))
        Traceback (most recent call last):
        ...
        TypeError: cannot coerce 2.50000000000000 (type t_REAL) to integer

        >>> for i in [0,1,2,15,16,17,1213051238]:
        ...     assert bin(pari(i)) == bin(i)
        ...     assert bin(pari(-i)) == bin(-i)
        ...     assert oct(pari(i)) == oct(i)
        ...     assert oct(pari(-i)) == oct(-i)
        ...     assert hex(pari(i)) == hex(i)
        ...     assert hex(pari(-i)) == hex(-i)
        """
        if typ(self.g) != t_INT:
            raise TypeError(f"cannot coerce {self!r} (type {self.type()}) to integer")
        return gen_to_integer(self)

    def python_list_small(self):
        """
        Return a Python list of the PARI gens. This object must be of type
        t_VECSMALL, and the resulting list contains python 'int's.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> v=pari([1,2,3,10,102,10]).Vecsmall()
        >>> w = v.python_list_small()
        >>> w
        [1, 2, 3, 10, 102, 10]
        >>> type(w[0])
        <... 'int'>
        """
        cdef long n
        if typ(self.g) != t_VECSMALL:
            raise TypeError("Object (=%s) must be of type t_VECSMALL." % self)
        return [self.g[n+1] for n in range(glength(self.g))]

    def python_list(self):
        """
        Return a Python list of the PARI gens. This object must be of type
        t_VEC or t_COL.

        INPUT: None

        OUTPUT:

        -  ``list`` - Python list whose elements are the
           elements of the input gen.


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> v = pari([1,2,3,10,102,10])
        >>> w = v.python_list()
        >>> w
        [1, 2, 3, 10, 102, 10]
        >>> type(w[0])
        <... 'cypari2.gen.Gen'>
        >>> pari("[1,2,3]").python_list()
        [1, 2, 3]

        >>> pari("[1,2,3]~").python_list()
        [1, 2, 3]
        """
        # TODO: deprecate
        cdef long n
        cdef Gen t

        if typ(self.g) != t_VEC and typ(self.g) != t_COL:
            raise TypeError("Object (=%s) must be of type t_VEC or t_COL." % self)
        return [self[n] for n in range(glength(self.g))]

    def python(self):
        """
        Return the closest Python equivalent of the given PARI object.

        See :func:`~sage.libs.cypari.convert.gen_to_python` for more informations.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('1.2').python()
        1.2
        >>> pari('389/17').python()
        Fraction(389, 17)
        """
        from .convert import gen_to_python
        return gen_to_python(self)

    def sage(self, locals=None):
        r"""
        Return the closest SageMath equivalent of the given PARI object.

        INPUT:

        - ``locals`` -- optional dictionary used in fallback cases that
          involve ``sage_eval``

        See :func:`~sage.libs.pari.convert_sage.gen_to_sage` for more information.
        """
        from sage.libs.pari.convert_sage import gen_to_sage
        return gen_to_sage(self, locals)

    def __long__(self):
        """
        Convert ``self`` to a Python ``long``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> import sys

        >>> if sys.version_info.major == 3:
        ...     long = int
        >>> assert isinstance(long(pari(0)), long)
        >>> assert long(pari(0)) == 0
        >>> assert long(pari(10)) == 10
        >>> assert long(pari(-10)) == -10
        >>> assert long(pari(123456789012345678901234567890)) == 123456789012345678901234567890
        >>> assert long(pari(-123456789012345678901234567890)) == -123456789012345678901234567890
        >>> assert long(pari(2**31-1)) == 2147483647
        >>> assert long(pari(-2**31)) == -2147483648
        >>> assert long(pari("Pol(10)")) == 10
        >>> assert long(pari("Mod(2, 7)")) == 2
        """
        x = gen_to_integer(self)
        if isinstance(x, long):
            return x
        else:
            return long(x)

    def __float__(self):
        """
        Return Python float.
        """
        cdef double d
        sig_on()
        d = gtodouble(self.g)
        sig_off()
        return d

    def __complex__(self):
        r"""
        Return ``self`` as a Python ``complex`` value.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> g = pari(-1.0)**(0.2); g
        0.809016994374947 + 0.587785252292473*I
        >>> g.__complex__()
        (0.8090169943749475+0.5877852522924731j)
        >>> complex(g)
        (0.8090169943749475+0.5877852522924731j)

        >>> g = pari('2/3')
        >>> complex(g)
        (0.6666666666666666+0j)

        >>> g = pari.quadgen(-23)
        >>> complex(g)
        (0.5+2.3979157616563596j)

        >>> g = pari.quadgen(5) + pari('2/3')
        >>> complex(g)
        (2.2847006554165614+0j)

        >>> g = pari('Mod(3,5)'); g
        Mod(3, 5)
        >>> complex(g)
        Traceback (most recent call last):
        ...
        PariError: incorrect type in gtofp (t_INTMOD)
        """
        cdef double re, im
        sig_on()
        # First convert to floating point (t_REAL or t_COMPLEX)
        # Note: DEFAULTPREC means 64 bits of precision
        fp = gtofp(self.g, DEFAULTPREC)
        if typ(fp) == t_REAL:
            re = rtodbl(fp)
            im = 0
        elif typ(fp) == t_COMPLEX:
            re = gtodouble(gel(fp, 1))
            im = gtodouble(gel(fp, 2))
        else:
            sig_off()
            raise AssertionError("unrecognized output from gtofp()")
        clear_stack()
        return complex(re, im)

    def __nonzero__(self):
        """
        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('1').__nonzero__()
        True
        >>> pari('x').__nonzero__()
        True
        >>> bool(pari(0))
        False
        >>> a = pari('Mod(0,3)')
        >>> a.__nonzero__()
        False
        """
        return not gequal0(self.g)

    def gequal(a, b):
        r"""
        Check whether `a` and `b` are equal using PARI's ``gequal``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> a = pari(1); b = pari(1.0); c = pari('"some_string"')
        >>> a.gequal(a)
        True
        >>> b.gequal(b)
        True
        >>> c.gequal(c)
        True
        >>> a.gequal(b)
        True
        >>> a.gequal(c)
        False

        WARNING: this relation is not transitive:

        >>> a = pari('[0]'); b = pari(0); c = pari('[0,0]')
        >>> a.gequal(b)
        True
        >>> b.gequal(c)
        True
        >>> a.gequal(c)
        False
        """
        cdef Gen t0 = objtogen(b)
        sig_on()
        cdef int ret = gequal(a.g, t0.g)
        sig_off()
        return ret != 0

    def gequal0(a):
        r"""
        Check whether `a` is equal to zero.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(0).gequal0()
        True
        >>> pari(1).gequal0()
        False
        >>> pari(1e-100).gequal0()
        False
        >>> pari("0.0 + 0.0*I").gequal0()
        True
        >>> (pari('ffgen(3^20)')*0).gequal0()
        True
        """
        sig_on()
        cdef int ret = gequal0(a.g)
        sig_off()
        return ret != 0

    def gequal_long(a, long b):
        r"""
        Check whether `a` is equal to the ``long int`` `b` using PARI's ``gequalsg``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> a = pari(1); b = pari(2.0); c = pari('3*matid(3)')
        >>> a.gequal_long(1)
        True
        >>> a.gequal_long(-1)
        False
        >>> a.gequal_long(0)
        False
        >>> b.gequal_long(2)
        True
        >>> b.gequal_long(-2)
        False
        >>> c.gequal_long(3)
        True
        >>> c.gequal_long(-3)
        False
        """
        sig_on()
        cdef int ret = gequalsg(b, a.g)
        sig_off()
        return ret != 0

    def isprime(self, long flag=0):
        """
        Return True if x is a PROVEN prime number, and False otherwise.

        INPUT:

        - ``flag`` -- If flag is 0 or omitted, use a combination of
          algorithms. If flag is 1, the primality is  certified by the
          Pocklington-Lehmer Test. If flag is 2, the primality is
          certified using the APRCL test. If flag is 3, use ECPP.

        OUTPUT: bool

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari(9).isprime()
        False
        >>> pari(17).isprime()
        True
        >>> n = pari(561)    # smallest Carmichael number
        >>> n.isprime()      # not just a pseudo-primality test!
        False
        >>> n.isprime(1)
        False
        >>> n.isprime(2)
        False
        >>> n = pari(2**31-1)
        >>> n.isprime(1)
        True
        """
        sig_on()
        x = gisprime(self.g, flag)
        # PARI-2.9 may return a primality certificate if flag==1.
        # So a non-INT is interpreted as True
        cdef bint ret = (typ(x) != t_INT) or (signe(x) != 0)
        clear_stack()
        return ret

    def ispseudoprime(self, long flag=0):
        """
        ispseudoprime(x, flag=0): Returns True if x is a pseudo-prime
        number, and False otherwise.

        INPUT:


        -  ``flag`` - int 0 (default): checks whether x is a
           Baillie-Pomerance-Selfridge-Wagstaff pseudo prime (strong
           Rabin-Miller pseudo prime for base 2, followed by strong Lucas test
           for the sequence (P,-1), P smallest positive integer such that
           `P^2 - 4` is not a square mod x). 0: checks whether x is a
           strong Miller-Rabin pseudo prime for flag randomly chosen bases
           (with end-matching to catch square roots of -1).


        OUTPUT:


        -  ``bool`` - True or False, or when flag=1, either False or a tuple
           (True, cert) where ``cert`` is a primality certificate.


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari(9).ispseudoprime()
        False
        >>> pari(17).ispseudoprime()
        True
        >>> n = pari(561)     # smallest Carmichael number
        >>> n.ispseudoprime(2)
        False
        """
        sig_on()
        cdef long t = ispseudoprime(self.g, flag)
        sig_off()
        return t != 0

    def ispower(self, k=None):
        r"""
        Determine whether or not self is a perfect k-th power. If k is not
        specified, find the largest k so that self is a k-th power.

        INPUT:


        -  ``k`` - int (optional)


        OUTPUT:


        -  ``power`` - int, what power it is

        -  ``g`` - what it is a power of


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari(9).ispower()
        (2, 3)
        >>> pari(17).ispower()
        (1, 17)
        >>> pari(17).ispower(2)
        (False, None)
        >>> pari(17).ispower(1)
        (1, 17)
        >>> pari(2).ispower()
        (1, 2)
        """
        cdef int n
        cdef GEN x
        cdef Gen t0

        if k is None:
            sig_on()
            n = gisanypower(self.g, &x)
            if n == 0:
                sig_off()
                return 1, self
            else:
                return n, new_gen(x)
        else:
            t0 = objtogen(k)
            sig_on()
            n = ispower(self.g, t0.g, &x)
            if n == 0:
                sig_off()
                return False, None
            else:
                return k, new_gen(x)

    def isprimepower(self):
        r"""
        Check whether ``self`` is a prime power (with an exponent >= 1).

        INPUT:

        - ``self`` - A PARI integer

        OUTPUT:

        A tuple ``(k, p)`` where `k` is a Python integer and `p` a PARI
        integer.

        - If the input was a prime power, `p` is the prime and `k` the
          power.
        - Otherwise, `k = 0` and `p` is ``self``.

        .. SEEALSO::

            If you don't need a proof that `p` is prime, you can use
            :meth:`ispseudoprimepower` instead.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari(9).isprimepower()
        (2, 3)
        >>> pari(17).isprimepower()
        (1, 17)
        >>> pari(18).isprimepower()
        (0, 18)
        >>> pari(3**12345).isprimepower()
        (12345, 3)
        """
        cdef GEN x
        cdef long n

        sig_on()
        n = isprimepower(self.g, &x)
        if n == 0:
            sig_off()
            return 0, self
        else:
            return n, new_gen(x)

    def ispseudoprimepower(self):
        r"""
        Check whether ``self`` is the power (with an exponent >= 1) of
        a pseudo-prime.

        INPUT:

        - ``self`` - A PARI integer

        OUTPUT:

        A tuple ``(k, p)`` where `k` is a Python integer and `p` a PARI
        integer.

        - If the input was a pseudoprime power, `p` is the pseudoprime
          and `k` the power.
        - Otherwise, `k = 0` and `p` is ``self``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(3**12345).ispseudoprimepower()
        (12345, 3)
        >>> p = pari(2**1500 + 1465)         # nextprime(2^1500)
        >>> (p**11).ispseudoprimepower()[0]  # very fast
        11
        """
        cdef GEN x
        cdef long n

        sig_on()
        n = ispseudoprimepower(self.g, &x)
        if n == 0:
            sig_off()
            return 0, self
        else:
            return n, new_gen(x)

    def vecmax(x):
        """
        Return the maximum of the elements of the vector/matrix `x`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari([1, '-5/3', 8.0]).vecmax()
        8.00000000000000
        """
        sig_on()
        return new_gen(vecmax(x.g))

    def vecmin(x):
        """
        Return the minimum of the elements of the vector/matrix `x`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari([1, '-5/3', 8.0]).vecmin()
        -5/3
        """
        sig_on()
        return new_gen(vecmin(x.g))

    def Ser(f, v=None, long precision=-1):
        """
        Return a power series or Laurent series in the variable `v`
        constructed from the object `f`.

        INPUT:

        - ``f`` -- PARI gen

        - ``v`` -- PARI variable (default: `x`)

        - ``precision`` -- the desired relative precision (default:
          the value returned by ``pari.get_series_precision()``).
          This is the absolute precision minus the `v`-adic valuation.

        OUTPUT:

        - PARI object of type ``t_SER``

        The series is constructed from `f` in the following way:

        - If `f` is a scalar, a constant power series is returned.

        - If `f` is a polynomial, it is converted into a power series
          in the obvious way.

        - If `f` is a rational function, it will be expanded in a
          Laurent series around `v = 0`.

        - If `f` is a vector, its coefficients become the coefficients
          of the power series, starting from the constant term.  This
          is the convention used by the function ``Polrev()``, and the
          reverse of that used by ``Pol()``.

        .. warning::

           This function will not transform objects containing
           variables of higher priority than `v`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(2).Ser()
        2 + O(x^16)
        >>> pari('Mod(0, 7)').Ser()
        Mod(0, 7)*x^15 + O(x^16)

        >>> x = pari([1, 2, 3, 4, 5])
        >>> x.Ser()
        1 + 2*x + 3*x^2 + 4*x^3 + 5*x^4 + O(x^16)
        >>> f = x.Ser('v'); print(f)
        1 + 2*v + 3*v^2 + 4*v^3 + 5*v^4 + O(v^16)
        >>> pari(1)/f
        1 - 2*v + v^2 + 6*v^5 - 17*v^6 + 16*v^7 - 5*v^8 + 36*v^10 - 132*v^11 + 181*v^12 - 110*v^13 + 25*v^14 + 216*v^15 + O(v^16)

        >>> pari('x^5').Ser(precision=20)
        x^5 + O(x^25)
        >>> pari('1/x').Ser(precision=1)
        x^-1 + O(x^0)

        """
        if precision < 0:
            precision = precdl  # Global PARI series precision
        sig_on()
        cdef long vn = get_var(v)
        if typ(f.g) == t_VEC:
            # The precision flag is ignored for vectors, so we first
            # convert the vector to a polynomial.
            return new_gen(gtoser(gtopolyrev(f.g, vn), vn, precision))
        else:
            return new_gen(gtoser(f.g, vn, precision))

    def Str(self):
        """
        Str(self): Return the print representation of self as a PARI
        object.

        INPUT:


        -  ``self`` - gen


        OUTPUT:


        -  ``gen`` - a PARI Gen of type t_STR, i.e., a PARI
           string


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari([1,2,['abc',1]]).Str()
        "[1, 2, [abc, 1]]"
        >>> pari([1,1, 1.54]).Str()
        "[1, 1, 1.54000000000000]"
        >>> pari(1).Str()       # 1 is automatically converted to string rep
        "1"
        >>> x = pari('x')       # PARI variable "x"
        >>> x.Str()             # is converted to string rep.
        "x"
        >>> x.Str().type()
        't_STR'
        """
        cdef char* c
        sig_on()
        # Use sig_block(), which is needed because GENtostr() uses
        # malloc(), which is dangerous inside sig_on()
        sig_block()
        c = GENtostr(self.g)
        sig_unblock()
        v = new_gen(strtoGENstr(c))
        pari_free(c)
        return v

    def Strexpand(x):
        """
        Concatenate the entries of the vector `x` into a single string,
        then perform tilde expansion and environment variable expansion
        similar to shells.

        INPUT:

        - ``x`` -- PARI gen. Either a vector or an element which is then
          treated like `[x]`.

        OUTPUT:

        - PARI string (type ``t_STR``)

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('"~/subdir"').Strexpand()
        "..."
        >>> pari('"$SHELL"').Strexpand()
        "..."

        Tests:

        >>> a = pari('"$HOME"')
        >>> a.Strexpand() != a
        True
        """
        if typ(x.g) != t_VEC:
            x = list_of_Gens_to_Gen([x])
        sig_on()
        return new_gen(Strexpand(x.g))

    def Strtex(x):
        r"""
        Strtex(x): Translates the vector x of PARI gens to TeX format and
        returns the resulting concatenated strings as a PARI t_STR.

        INPUT:

        - ``x`` -- PARI gen. Either a vector or an element which is then
          treated like `[x]`.

        OUTPUT:

        - PARI string (type ``t_STR``)

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> v = pari('x^2')
        >>> v.Strtex()
        "x^2"
        >>> v = pari(['1/x^2','x'])
        >>> v.Strtex()
        "\\frac{1}{x^2}x"
        >>> v = pari(['1 + 1/x + 1/(y+1)','x-1'])
        >>> v.Strtex()
        "\\frac{ \\left(y\n + 2\\right) \\*x\n + \\left(y\n + 1\\right) }{ \\left(y\n + 1\\right) \\*x}x\n - 1"
        """
        if typ(x.g) != t_VEC:
            x = list_of_Gens_to_Gen([x])
        sig_on()
        return new_gen(Strtex(x.g))

    def bittest(x, long n):
        """
        bittest(x, long n): Returns bit number n (coefficient of
        `2^n` in binary) of the integer x. Negative numbers behave
        as if modulo a big power of 2.

        INPUT:


        -  ``x`` - Gen (pari integer)


        OUTPUT:


        -  ``bool`` - a Python bool


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> x = pari(6)
        >>> x.bittest(0)
        False
        >>> x.bittest(1)
        True
        >>> x.bittest(2)
        True
        >>> x.bittest(3)
        False
        >>> pari(-3).bittest(0)
        True
        >>> pari(-3).bittest(1)
        False
        >>> [pari(-3).bittest(n) for n in range(10)]
        [True, False, True, True, True, True, True, True, True, True]
        """
        sig_on()
        cdef long b = bittest(x.g, n)
        sig_off()
        return b != 0

    lift_centered = Gen_base.centerlift

    def padicprime(self):
        """
        The uniformizer of the p-adic ring this element lies in, as a t_INT.

        INPUT:

        - ``x`` - gen, of type t_PADIC

        OUTPUT:

        - ``p`` - gen, of type t_INT

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> y = pari('11^-10 + 5*11^-7 + 11^-6 + O(11)')
        >>> y.padicprime()
        11
        >>> y.padicprime().type()
        't_INT'
        """
        return self.new_ref(gel(self.fixGEN(), 2))

    def round(x, bint estimate=False):
        """
        round(x,estimate=False): If x is a real number, returns x rounded
        to the nearest integer (rounding up). If the optional argument
        estimate is True, also returns the binary exponent e of the
        difference between the original and the rounded value (the
        "fractional part") (this is the integer ceiling of log_2(error)).

        When x is a general PARI object, this function returns the result
        of rounding every coefficient at every level of PARI object. Note
        that this is different than what the truncate function does (see
        the example below).

        One use of round is to get exact results after a long approximate
        computation, when theory tells you that the coefficients must be
        integers.

        INPUT:


        -  ``x`` - gen

        -  ``estimate`` - (optional) bool, False by default


        OUTPUT:

        - if estimate is False, return a single gen.

        - if estimate is True, return rounded version of x and error
          estimate in bits, both as gens.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('1.5').round()
        2
        >>> pari('1.5').round(True)
        (2, -1)
        >>> pari('1.5 + 2.1*I').round()
        2 + 2*I
        >>> pari('1.0001').round(True)
        (1, -14)
        >>> pari('(2.4*x^2 - 1.7)/x').round()
        (2*x^2 - 2)/x
        >>> pari('(2.4*x^2 - 1.7)/x').truncate()
        2.40000000000000*x
        """
        cdef int n
        cdef long e
        cdef Gen y
        sig_on()
        if not estimate:
            return new_gen(ground(x.g))
        y = new_gen(grndtoi(x.g, &e))
        return y, e

    def sizeword(x):
        """
        Return the total number of machine words occupied by the
        complete tree of the object x.  A machine word is 32 or
        64 bits, depending on the computer.

        INPUT:

        -  ``x`` - gen

        OUTPUT: int (a Python int)

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('0').sizeword()
        2
        >>> pari('1').sizeword()
        3
        >>> pari('1000000').sizeword()
        3

        >>> import sys
        >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
        >>> pari('10^100').sizeword() == (13 if bitness == '32' else 8)
        True
        >>> pari(1.0).sizeword() == (4 if bitness == '32' else 3)
        True

        >>> pari('x + 1').sizeword()
        10
        >>> pari('[x + 1, 1]').sizeword()
        16
        """
        return gsizeword(x.g)

    def sizebyte(x):
        """
        Return the total number of bytes occupied by the complete tree
        of the object x. Note that this number depends on whether the
        computer is 32-bit or 64-bit.

        INPUT:

        -  ``x`` - gen

        OUTPUT: int (a Python int)

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> import sys
        >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
        >>> pari('1').sizebyte() == (12 if bitness == '32' else 24)
        True
        """
        return gsizebyte(x.g)

    def truncate(x, bint estimate=False):
        """
        truncate(x,estimate=False): Return the truncation of x. If estimate
        is True, also return the number of error bits.

        When x is in the real numbers, this means that the part after the
        decimal point is chopped away, e is the binary exponent of the
        difference between the original and truncated value (the
        "fractional part"). If x is a rational function, the result is the
        integer part (Euclidean quotient of numerator by denominator) and
        if requested the error estimate is 0.

        When truncate is applied to a power series (in X), it transforms it
        into a polynomial or a rational function with denominator a power
        of X, by chopping away the `O(X^k)`. Similarly, when
        applied to a p-adic number, it transforms it into an integer or a
        rational number by chopping away the `O(p^k)`.

        INPUT:


        -  ``x`` - gen

        -  ``estimate`` - (optional) bool, which is False by
           default


        OUTPUT:

        - if estimate is False, return a single gen.

        - if estimate is True, return rounded version of x and error
          estimate in bits, both as gens.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('(x^2+1)/x').round()
        (x^2 + 1)/x
        >>> pari('(x^2+1)/x').truncate()
        x
        >>> pari('1.043').truncate()
        1
        >>> pari('1.043').truncate(True)
        (1, -5)
        >>> pari('1.6').truncate()
        1
        >>> pari('1.6').round()
        2
        >>> pari('1/3 + 2 + 3^2 + O(3^3)').truncate()
        34/3
        >>> pari('sin(x+O(x^10))').truncate()
        1/362880*x^9 - 1/5040*x^7 + 1/120*x^5 - 1/6*x^3 + x
        >>> pari('sin(x+O(x^10))').round()   # each coefficient has abs < 1
        x + O(x^10)
        """
        cdef long e
        cdef Gen y
        sig_on()
        if not estimate:
            return new_gen(gtrunc(x.g))
        y = new_gen(gcvtoi(x.g, &e))
        return y, e

    def _valp(x):
        """
        Return the valuation of x where x is a p-adic number (t_PADIC)
        or a Laurent series (t_SER).  If x is a different type, this
        will give a bogus number.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('1/x^2 + O(x^10)')._valp()
        -2
        >>> pari('O(x^10)')._valp()
        10
        >>> pari('(1145234796 + O(3^10))/771966234')._valp()
        -2
        >>> pari('O(2^10)')._valp()
        10
        """
        # This is a simple macro, so we don't need sig_on()
        return valp(x.g)

    def bernfrac(self):
        r"""
        The Bernoulli number `B_x`, where `B_0 = 1`,
        `B_1 = -1/2`, `B_2 = 1/6,\ldots,` expressed as a
        rational number. The argument `x` should be of type
        integer.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(18).bernfrac()
        43867/798
        >>> [pari(n).bernfrac() for n in range(10)]
        [1, -1/2, 1/6, 0, -1/30, 0, 1/42, 0, -1/30, 0]
        """
        sig_on()
        return new_gen(bernfrac(self))

    def bernreal(self, unsigned long precision=0):
        r"""
        The Bernoulli number `B_x`, as for the function bernfrac,
        but `B_x` is returned as a real number (with the current
        precision).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(18).bernreal()
        54.9711779448622
        """
        sig_on()
        return new_gen(bernreal(self, prec_bits_to_words(precision)))

    def besselk(nu, x, unsigned long precision=0):
        """
        nu.besselk(x): K-Bessel function (modified Bessel function
        of the second kind) of index nu, which can be complex, and argument
        x.

        If `nu` or `x` is an exact argument, it is first
        converted to a real or complex number using the optional parameter
        precision (in bits). If the arguments are inexact (e.g. real), the
        smallest of their precisions is used in the computation, and the
        parameter precision is ignored.

        INPUT:


        -  ``nu`` - a complex number

        -  ``x`` - real number (positive or negative)

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(complex(2, 1)).besselk(3)
        0.0455907718407551 + 0.0289192946582081*I

        >>> pari(complex(2, 1)).besselk(-3)
        -4.34870874986752 - 5.38744882697109*I

        >>> pari(complex(2, 1)).besselk(300)
        3.74224603319728 E-132 + 2.49071062641525 E-134*I
        """
        cdef Gen t0 = objtogen(x)
        sig_on()
        return new_gen(kbessel(nu.g, t0.g, prec_bits_to_words(precision)))

    def eint1(x, long n=0, unsigned long precision=0):
        r"""
        x.eint1(n): exponential integral E1(x):

        .. MATH::

                         \int_{x}^{\infty} \frac{e^{-t}}{t} dt


        If n is present, output the vector [eint1(x), eint1(2\*x), ...,
        eint1(n\*x)]. This is faster than repeatedly calling eint1(i\*x).

        If `x` is an exact argument, it is first converted to a
        real or complex number using the optional parameter precision (in
        bits). If `x` is inexact (e.g. real), its own precision is
        used in the computation, and the parameter precision is ignored.

        REFERENCE:

        - See page 262, Prop 5.6.12, of Cohen's book "A Course in
          Computational Algebraic Number Theory".

        Examples:
        """
        sig_on()
        if n <= 0:
            return new_gen(eint1(x.g, prec_bits_to_words(precision)))
        else:
            return new_gen(veceint1(x.g, stoi(n), prec_bits_to_words(precision)))

    log_gamma = Gen_base.lngamma

    def polylog(x, long m, long flag=0, unsigned long precision=0):
        """
        x.polylog(m,flag=0): m-th polylogarithm of x. flag is optional, and
        can be 0: default, 1: D_m -modified m-th polylog of x, 2:
        D_m-modified m-th polylog of x, 3: P_m-modified m-th polylog of
        x.

        If `x` is an exact argument, it is first converted to a
        real or complex number using the optional parameter precision (in
        bits). If `x` is inexact (e.g. real), its own precision is
        used in the computation, and the parameter precision is ignored.

        TODO: Add more explanation, copied from the PARI manual.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(10).polylog(3)
        5.64181141475134 - 8.32820207698027*I
        >>> pari(10).polylog(3,0)
        5.64181141475134 - 8.32820207698027*I
        >>> pari(10).polylog(3,1)
        0.523778453502411
        >>> pari(10).polylog(3,2)
        -0.400459056163451
        """
        sig_on()
        return new_gen(polylog0(m, x.g, flag, prec_bits_to_words(precision)))

    def sqrtn(x, n, unsigned long precision=0):
        r"""
        x.sqrtn(n): return the principal branch of the n-th root of x,
        i.e., the one such that
        `\arg(\sqrt(x)) \in ]-\pi/n, \pi/n]`. Also returns a second
        argument which is a suitable root of unity allowing one to recover
        all the other roots. If it was not possible to find such a number,
        then this second return value is 0. If the argument is present and
        no square root exists, return 0 instead of raising an error.

        If `x` is an exact argument, it is first converted to a
        real or complex number using the optional parameter precision (in
        bits). If `x` is inexact (e.g. real), its own precision is
        used in the computation, and the parameter precision is ignored.

        .. NOTE::

           intmods (modulo a prime) and `p`-adic numbers are
           allowed as arguments.

        INPUT:


        -  ``x`` - gen

        -  ``n`` - integer


        OUTPUT:


        -  ``gen`` - principal n-th root of x

        -  ``gen`` - root of unity z that gives the other
           roots


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> s, z = pari(2).sqrtn(5)
        >>> z
        0.309016994374947 + 0.951056516295154*I
        >>> s
        1.14869835499704
        >>> s**5
        2.00000000000000
        >>> (s*z)**5
        2.00000000000000 + 0.E-19*I


        >>> import sys
        >>> bitness = '64' if sys.maxsize > (1 << 32) else '32'
        >>> s = str(z**5)
        >>> s == ('1.00000000000000 - 2.710505431 E-20*I' if bitness == '32' else '1.00000000000000 - 2.71050543121376 E-20*I')
        True
        """
        cdef GEN ans, zetan
        cdef Gen t0 = objtogen(n)
        sig_on()
        ans = gsqrtn(x.g, t0.g, &zetan, prec_bits_to_words(precision))
        return new_gens2(ans, zetan)

    def ffprimroot(self):
        r"""
        Return a primitive root of the multiplicative group of the
        definition field of the given finite field element.

        INPUT:

        - ``self`` -- a PARI finite field element (``FFELT``)

        OUTPUT:

        - A generator of the multiplicative group of the finite field
          generated by ``self``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> b = pari(9).ffgen().ffprimroot()
        >>> b.fforder()
        8
        """
        sig_on()
        return new_gen(ffprimroot(self.g, NULL))

    def fibonacci(self):
        r"""
        Return the Fibonacci number of index x.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(18).fibonacci()
        2584
        >>> [pari(n).fibonacci() for n in range(10)]
        [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
        """
        sig_on()
        return new_gen(fibo(self))

    def issquare(x, find_root=False):
        """
        issquare(x,n): ``True`` if x is a square, ``False`` if not. If
        ``find_root`` is given, also returns the exact square root.
        """
        cdef GEN G
        cdef long t
        cdef Gen g
        sig_on()
        if find_root:
            t = itos(gissquareall(x.g, &G))
            if t:
                return True, new_gen(G)
            else:
                clear_stack()
                return False, None
        else:
            t = itos(gissquare(x.g))
            clear_stack()
            return t != 0

    def issquarefree(self):
        """
        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(10).issquarefree()
        True
        >>> pari(20).issquarefree()
        False
        """
        sig_on()
        cdef long t = issquarefree(self.g)
        sig_off()
        return t != 0

    def sumdiv(n):
        """
        Return the sum of the divisors of `n`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(10).sumdiv()
        18
        """
        sig_on()
        return new_gen(sumdiv(n.g))

    def sumdivk(n, long k):
        """
        Return the sum of the k-th powers of the divisors of n.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(10).sumdivk(2)
        130
        """
        sig_on()
        return new_gen(sumdivk(n.g, k))

    def Zn_issquare(self, n):
        """
        Return ``True`` if ``self`` is a square modulo `n`, ``False``
        if not.

        INPUT:

        - ``self`` -- integer

        - ``n`` -- integer or factorisation matrix

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(3).Zn_issquare(4)
        False
        >>> pari(4).Zn_issquare(pari(30).factor())
        True

        """
        cdef Gen t0 = objtogen(n)
        sig_on()
        cdef long t = Zn_issquare(self.g, t0.g)
        clear_stack()
        return t != 0

    def Zn_sqrt(self, n):
        """
        Return a square root of ``self`` modulo `n`, if such a square
        root exists; otherwise, raise a ``ValueError``.

        INPUT:

        - ``self`` -- integer

        - ``n`` -- integer or factorisation matrix

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(3).Zn_sqrt(4)
        Traceback (most recent call last):
        ...
        ValueError: 3 is not a square modulo 4
        >>> pari(4).Zn_sqrt(pari(30).factor())
        22

        """
        cdef Gen t0 = objtogen(n)
        cdef GEN s
        sig_on()
        s = Zn_sqrt(self.g, t0.g)
        if s == NULL:
            clear_stack()
            raise ValueError("%s is not a square modulo %s" % (self, n))
        return new_gen(s)

    def ellan(self, long n, python_ints=False):
        """
        Return the first `n` Fourier coefficients of the modular
        form attached to this elliptic curve. See ellak for more details.

        INPUT:


        -  ``n`` - a long integer

        -  ``python_ints`` - bool (default is False); if True,
           return a list of Python ints instead of a PARI Gen wrapper.


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([0, -1, 1, -10, -20]).ellinit()
        >>> e.ellan(3)
        [1, -2, -1]
        >>> e.ellan(20)
        [1, -2, -1, 2, 1, 2, -2, 0, -2, -2, 1, -2, 4, 4, -1, -4, -2, 4, 0, 2]
        >>> e.ellan(-1)
        []
        >>> v = e.ellan(10, python_ints=True); v
        [1, -2, -1, 2, 1, 2, -2, 0, -2, -2]
        >>> type(v)
        <... 'list'>
        >>> type(v[0])
        <... 'int'>
        """
        sig_on()
        cdef Gen g = new_gen(ellan(self.g, n))
        if not python_ints:
            return g
        return [gtolong(gel(g.g, i+1)) for i in range(glength(g.g))]

    def ellaplist(self, long n, python_ints=False):
        r"""
        e.ellaplist(n): Returns a PARI list of all the prime-indexed
        coefficients `a_p` (up to n) of the `L`-function
        of the elliptic curve `e`, i.e. the Fourier coefficients of
        the newform attached to `e`.

        INPUT:

        - ``self`` -- an elliptic curve

        - ``n`` -- a long integer

        - ``python_ints`` -- bool (default is False); if True,
          return a list of Python ints instead of a PARI Gen wrapper.

        .. WARNING::

            The curve e must be a medium or long vector of the type given by
            ellinit. For this function to work for every n and not just those
            prime to the conductor, e must be a minimal Weierstrass equation.
            If this is not the case, use the function ellminimalmodel first
            before using ellaplist (or you will get INCORRECT RESULTS!)

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([0, -1, 1, -10, -20]).ellinit()
        >>> v = e.ellaplist(10); v
        [-2, -1, 1, -2]
        >>> type(v)
        <... 'cypari2.gen.Gen'>
        >>> v.type()
        't_VEC'
        >>> e.ellan(10)
        [1, -2, -1, 2, 1, 2, -2, 0, -2, -2]
        >>> v = e.ellaplist(10, python_ints=True); v
        [-2, -1, 1, -2]
        >>> type(v)
        <... 'list'>
        >>> type(v[0])
        <... 'int'>

        Tests:

        >>> v = e.ellaplist(1)
        >>> v, type(v)
        ([], <... 'cypari2.gen.Gen'>)
        >>> v = e.ellaplist(1, python_ints=True)
        >>> v, type(v)
        ([], <... 'list'>)
        """
        if python_ints:
            return [int(x) for x in self.ellaplist(n)]

        sig_on()
        if n < 2:
            return new_gen(zerovec(0))

        # Make a table of primes up to n: this returns a t_VECSMALL
        # that we artificially change to a t_VEC
        cdef GEN g = primes_upto_zv(n)
        settyp(g, t_VEC)

        # Replace each prime in the table by ellap of it
        cdef long i
        cdef GEN curve = self.g
        for i in range(1, lg(g)):
            set_gel(g, i, ellap(curve, utoi(g[i])))
        return new_gen(g)

    def ellisoncurve(self, x):
        """
        e.ellisoncurve(x): return True if the point x is on the elliptic
        curve e, False otherwise.

        If the point or the curve have inexact coefficients, an attempt is
        made to take this into account.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([0,1,1,-2,0]).ellinit()
        >>> e.ellisoncurve([1,0])
        True
        >>> e.ellisoncurve([1,1])
        False
        >>> e.ellisoncurve([1,0.00000000000000001])
        False
        >>> e.ellisoncurve([1,0.000000000000000001])
        True
        >>> e.ellisoncurve([0])
        True
        """
        cdef Gen t0 = objtogen(x)
        sig_on()
        cdef int t = oncurve(self.g, t0.g)
        sig_off()
        return t != 0

    def ellminimalmodel(self):
        """
        ellminimalmodel(e): return the standard minimal integral model of
        the rational elliptic curve e and the corresponding change of
        variables. INPUT:


        -  ``e`` - Gen (that defines an elliptic curve)


        OUTPUT:


        -  ``gen`` - minimal model

        -  ``gen`` - change of coordinates


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([1,2,3,4,5]).ellinit()
        >>> F, ch = e.ellminimalmodel()
        >>> F[:5]
        [1, -1, 0, 4, 3]
        >>> ch
        [1, -1, 0, -1]
        >>> e.ellchangecurve(ch)[:5]
        [1, -1, 0, 4, 3]
        """
        cdef GEN x, y
        sig_on()
        x = ellminimalmodel(self.g, &y)
        return new_gens2(x, y)

    def elltors(self):
        r"""
        Return information about the torsion subgroup of the given
        elliptic curve.

        INPUT:

        -  ``e`` - elliptic curve over `\QQ`

        OUTPUT:


        -  ``gen`` - the order of the torsion subgroup, a.k.a.
           the number of points of finite order

        -  ``gen`` - vector giving the structure of the torsion
           subgroup as a product of cyclic groups, sorted in non-increasing
           order

        -  ``gen`` - vector giving points on e generating these
           cyclic groups


        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([1,0,1,-19,26]).ellinit()
        >>> e.elltors()
        [12, [6, 2], [[1, 2], [3, -2]]]
        """
        sig_on()
        return new_gen(elltors(self.g))

    def omega(self):
        """
        Return the basis for the period lattice of this elliptic curve.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([0, -1, 1, -10, -20]).ellinit()
        >>> e.omega()
        [1.26920930427955, 0.634604652139777 - 1.45881661693850*I]

        The precision is determined by the ``ellinit`` call:

        >>> e = pari([0, -1, 1, -10, -20]).ellinit(precision=256)
        >>> e.omega().bitprecision()
        256

        This also works over quadratic imaginary number fields:

        >>> e = pari.ellinit([0, -1, 1, -10, -20], "nfinit(y^2 - 2)")
        >>> if pari.version() >= (2, 10, 1):
        ...     w = e.omega()
        """
        sig_on()
        return new_gen(member_omega(self.g))

    def disc(self):
        """
        Return the discriminant of this object.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([0, -1, 1, -10, -20]).ellinit()
        >>> e.disc()
        -161051
        >>> _.factor()
        [-1, 1; 11, 5]
        """
        sig_on()
        return clone_gen(member_disc(self.g))

    def j(self):
        """
        Return the j-invariant of this object.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> e = pari([0, -1, 1, -10, -20]).ellinit()
        >>> e.j()
        -122023936/161051
        >>> _.factor()
        [-1, 1; 2, 12; 11, -5; 31, 3]
        """
        sig_on()
        return clone_gen(member_j(self.g))

    def _eltabstorel(self, x):
        """
        Return the relative number field element corresponding to `x`.

        The result is a ``t_POLMOD`` with ``t_POLMOD`` coefficients.

        .. WARNING::

            This is a low-level version of :meth:`rnfeltabstorel` that
            only needs the output of :meth:`_nf_rnfeq`, not a full
            PARI ``rnf`` structure.  This method may raise errors or
            return undefined results if called with invalid arguments.

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari('y^2 + 1').nfinit()
        >>> rnfeq = K._nf_rnfeq('x^2 + 2')
        >>> f_abs = rnfeq[0]; f_abs
        x^4 + 6*x^2 + 1
        >>> x_rel = rnfeq._eltabstorel('x'); x_rel
        Mod(x + Mod(-y, y^2 + 1), x^2 + 2)
        >>> f_abs(x_rel)
        Mod(0, x^2 + 2)
        """
        cdef Gen t0 = objtogen(x)
        sig_on()
        return new_gen(eltabstorel(self.g, t0.g))

    def _eltabstorel_lift(self, x):
        """
        Return the relative number field element corresponding to `x`.

        The result is a ``t_POL`` with ``t_POLMOD`` coefficients.

        .. WARNING::

            This is a low-level version of :meth:`rnfeltabstorel` that
            only needs the output of :meth:`_nf_rnfeq`, not a full
            PARI ``rnf`` structure.  This method may raise errors or
            return undefined results if called with invalid arguments.

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari('y^2 + 1').nfinit()
        >>> rnfeq = K._nf_rnfeq('x^2 + 2')
        >>> rnfeq._eltabstorel_lift('x')
        x + Mod(-y, y^2 + 1)
        """
        cdef Gen t0 = objtogen(x)
        sig_on()
        return new_gen(eltabstorel_lift(self.g, t0.g))

    def _eltreltoabs(self, x):
        """
        Return the absolute number field element corresponding to `x`.

        The result is a ``t_POL``.

        .. WARNING::

            This is a low-level version of :meth:`rnfeltreltoabs` that
            only needs the output of :meth:`_nf_rnfeq`, not a full
            PARI ``rnf`` structure.  This method may raise errors or
            return undefined results if called with invalid arguments.

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari('y^2 + 1').nfinit()
        >>> rnfeq = K._nf_rnfeq('x^2 + 2')
        >>> rnfeq._eltreltoabs('x')
        1/2*x^3 + 7/2*x
        >>> rnfeq._eltreltoabs('y')
        1/2*x^3 + 5/2*x
        """
        cdef Gen t0 = objtogen(x)
        sig_on()
        return new_gen(eltreltoabs(self.g, t0.g))

    def galoissubfields(self, long flag=0, v=None):
        """
        List all subfields of the Galois group ``self``.

        This wraps the `galoissubfields`_ function from PARI.

        This method is essentially the same as applying
        :meth:`galoisfixedfield` to each group returned by
        :meth:`galoissubgroups`.

        INPUT:

        - ``self`` -- A Galois group as generated by :meth:`galoisinit`.

        - ``flag`` -- Has the same meaning as in :meth:`galoisfixedfield`.

        - ``v`` -- Has the same meaning as in :meth:`galoisfixedfield`.

        OUTPUT:

        A vector of all subfields of this group.  Each entry is as
        described in the :meth:`galoisfixedfield` method.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> G = pari('x^6 + 108').galoisinit()
        >>> G.galoissubfields(flag=1)
        [x, x^2 + 972, x^3 + 54, x^3 + 864, x^3 - 54, x^6 + 108]
        >>> G = pari('x^4 + 1').galoisinit()
        >>> G.galoissubfields(flag=2, v='z')[3]
        [...^2 + 2, Mod(x^3 + x, x^4 + 1), [x^2 - z*x - 1, x^2 + z*x - 1]]

        .. _galoissubfields: http://pari.math.u-bordeaux.fr/dochtml/html.stable/Functions_related_to_general_number_fields.html#galoissubfields
        """
        sig_on()
        return new_gen(galoissubfields(self.g, flag, get_var(v)))

    def nfeltval(self, x, p):
        """
        Return the valuation of the number field element `x` at the prime `p`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> nf = pari('x^2 + 1').nfinit()
        >>> p = nf.idealprimedec(5)[0]
        >>> nf.nfeltval('50 - 25*x', p)
        3
        """
        cdef Gen t0 = objtogen(x)
        cdef Gen t1 = objtogen(p)
        sig_on()
        v = nfval(self.g, t0.g, t1.g)
        sig_off()
        return v

    def nfbasis(self, long flag=0, fa=None):
        r"""
        Integral basis of the field `\QQ[a]`, where ``a`` is a root of
        the polynomial x.

        INPUT:

        - ``flag``: if set to 1 and ``fa`` is not given: assume that no
          square of a prime > 500000 divides the discriminant of ``x``.

        - ``fa``: If present, encodes a subset of primes at which to
          check for maximality. This must be one of the three following
          things:

            - an integer: check all primes up to ``fa`` using trial
              division.

            - a vector: a list of primes to check.

            - a matrix: a partial factorization of the discriminant
              of ``x``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('x^3 - 17').nfbasis()
        [1, x, 1/3*x^2 - 1/3*x + 1/3]

        We test ``flag`` = 1, noting it gives a wrong result when the
        discriminant (-4 * `p`^2 * `q` in the example below) has a big square
        factor:

        >>> p = pari(10**10).nextprime(); q = (p+1).nextprime()
        >>> x = pari('x'); f = x**2 + p**2*q
        >>> pari(f).nfbasis(1)   # Wrong result
        [1, x]
        >>> pari(f).nfbasis()    # Correct result
        [1, 1/10000000019*x]
        >>> pari(f).nfbasis(fa=10**6)   # Check primes up to 10^6: wrong result
        [1, x]
        >>> pari(f).nfbasis(fa="[2,2; %s,2]"%p)    # Correct result and faster
        [1, 1/10000000019*x]
        >>> pari(f).nfbasis(fa=[2,p])              # Equivalent with the above
        [1, 1/10000000019*x]

        The following alternative syntax closer to PARI/GP can be used

        >>> pari.nfbasis([f, 1])
        [1, x]
        >>> pari.nfbasis(f)
        [1, 1/10000000019*x]
        >>> pari.nfbasis([f, 10**6])
        [1, x]
        >>> pari.nfbasis([f, "[2,2; %s,2]"%p])
        [1, 1/10000000019*x]
        >>> pari.nfbasis([f, [2,p]])
        [1, 1/10000000019*x]
        """
        cdef Gen t0
        cdef GEN g0
        if fa is not None:
            t0 = objtogen(fa)
            g0 = t0.g
        elif flag:
            g0 = utoi(500000)
        else:
            g0 = NULL
        sig_on()
        return new_gen(old_nfbasis(self.g, NULL, g0))

    def nfbasis_d(self, long flag=0, fa=None):
        """
        Like :meth:`nfbasis`, but return a tuple ``(B, D)`` where `B`
        is the integral basis and `D` the discriminant.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> F = pari('x^3 - 2').nfinit()
        >>> F[0].nfbasis_d()
        ([1, x, x^2], -108)

        >>> G = pari('x^5 - 11').nfinit()
        >>> G[0].nfbasis_d()
        ([1, x, x^2, x^3, x^4], 45753125)

        >>> pari([-2,0,0,1]).Polrev().nfbasis_d()
        ([1, x, x^2], -108)
        """
        cdef Gen t0
        cdef GEN g0
        cdef GEN ans, disc
        if fa is not None:
            t0 = objtogen(fa)
            g0 = t0.g
        elif flag & 1:
            g0 = utoi(500000)
        else:
            g0 = NULL
        sig_on()
        ans = old_nfbasis(self.g, &disc, g0)
        return new_gens2(ans, disc)

    def nfbasistoalg_lift(nf, x):
        r"""
        Transforms the column vector ``x`` on the integral basis into a
        polynomial representing the algebraic number.

        INPUT:

         - ``nf`` -- a number field
         - ``x`` -- a column of rational numbers of length equal to the
           degree of ``nf`` or a single rational number

        OUTPUT:

         - ``nf.nfbasistoalg(x).lift()``

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari('x^3 - 17').nfinit()
        >>> K.nf_get_zk()
        [1, 1/3*x^2 - 1/3*x + 1/3, x]
        >>> K.nfbasistoalg_lift(42)
        42
        >>> K.nfbasistoalg_lift("[3/2, -5, 0]~")
        -5/3*x^2 + 5/3*x - 1/6
        >>> K.nf_get_zk() * pari("[3/2, -5, 0]~")
        -5/3*x^2 + 5/3*x - 1/6
        """
        cdef Gen t0 = objtogen(x)
        sig_on()
        return new_gen(gel(basistoalg(nf.g, t0.g), 2))

    def nfgenerator(self):
        f = self[0]
        x = f.variable()
        return x.Mod(f)

    def _nf_rnfeq(self, relpol):
        """
        Return data for converting number field elements between
        absolute and relative representation.

        .. NOTE::

            The output of this method is suitable for the methods
            :meth:`_eltabstorel`, :meth:`_eltabstorel_lift` and
            :meth:`_eltreltoabs`.

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari('y^2 + 1').nfinit()
        >>> K._nf_rnfeq('x^2 + 2')
        [x^4 + 6*x^2 + 1, 1/2*x^3 + 5/2*x, -1, y^2 + 1, x^2 + 2]
        """
        cdef Gen t0 = objtogen(relpol)
        sig_on()
        return new_gen(nf_rnfeq(self.g, t0.g))

    def _nf_nfzk(self, rnfeq):
        """
        Return data for constructing relative number field elements
        from elements of the base field.

        INPUT:

        - ``rnfeq`` -- relative number field data as returned by
          :meth:`_nf_rnfeq`

        .. NOTE::

            The output of this method is suitable for the method
            :meth:`_nfeltup`.
        """
        cdef Gen t0 = objtogen(rnfeq)
        sig_on()
        return new_gen(new_nf_nfzk(self.g, t0.g))

    def _nfeltup(self, x, nfzk):
        """
        Construct a relative number field element from an element of
        the base field.

        INPUT:

        - ``x`` -- element of the base field

        - ``nfzk`` -- relative number field data as returned by
          :meth:`_nf_nfzk`

        .. WARNING::

            This is a low-level version of :meth:`rnfeltup` that only
            needs the output of :meth:`_nf_nfzk`, not a full PARI
            ``rnf`` structure.  This method may raise errors or return
            undefined results if called with invalid arguments.

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> nf = pari('nfinit(y^2 - 2)')
        >>> nfzk = nf._nf_nfzk(nf._nf_rnfeq('x^2 - 3'))
        >>> nf._nfeltup('y', nfzk)
        -1/2*x^3 + 9/2*x
        """
        cdef Gen t0 = objtogen(x)
        cdef Gen t1 = objtogen(nfzk)
        sig_on()
        return clone_gen(new_nfeltup(self.g, t0.g, t1.g))

    def eval(self, *args, **kwds):
        """
        Evaluate ``self`` with the given arguments.

        This is currently implemented in 3 cases:

        - univariate polynomials, rational functions, power series and
          Laurent series (using a single unnamed argument or keyword
          arguments),
        - any PARI object supporting the PARI function :pari:`substvec`
          (in particular, multivariate polynomials) using keyword
          arguments,
        - objects of type ``t_CLOSURE`` (functions in GP bytecode form)
          using unnamed arguments.

        In no case is mixing unnamed and keyword arguments allowed.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> f = pari('x^2 + 1')
        >>> f.type()
        't_POL'
        >>> f.eval(pari('I'))
        0
        >>> f.eval(x=2)
        5
        >>> (1/f).eval(x=1)
        1/2

        The notation ``f(x)`` is an alternative for ``f.eval(x)``:

        >>> f(3) == f.eval(3)
        True

        >>> f = pari('Mod(x^2 + x + 1, 3)')
        >>> f(2)
        Mod(1, 3)

        Evaluating a power series:

        >>> f = pari('1 + x + x^3 + O(x^7)')
        >>> f(2*pari('y')**2)
        1 + 2*y^2 + 8*y^6 + O(y^14)

        Substituting zero is sometimes possible, and trying to do so
        in illegal cases can raise various errors:

        >>> pari('1 + O(x^3)').eval(0)
        1
        >>> pari('1/x').eval(0)
        Traceback (most recent call last):
        ...
        PariError: impossible inverse in gdiv: 0
        >>> pari('1/x + O(x^2)').eval(0)
        Traceback (most recent call last):
        ...
        PariError: impossible inverse in gsubst: 0
        >>> pari('1/x + O(x^2)').eval(pari('O(x^3)'))
        Traceback (most recent call last):
        ...
        PariError: impossible inverse in ...
        >>> pari('O(x^0)').eval(0)
        Traceback (most recent call last):
        ...
        PariError: forbidden substitution t_SER , t_INT

        Evaluating multivariate polynomials:

        >>> f = pari('y^2 + x^3')
        >>> f(1)    # Dangerous, depends on PARI variable ordering
        y^2 + 1
        >>> f(x=1)  # Safe
        y^2 + 1
        >>> f(y=1)
        x^3 + 1
        >>> f(1, 2)
        Traceback (most recent call last):
        ...
        TypeError: evaluating PARI t_POL takes exactly 1 argument (2 given)
        >>> f(y='x', x='2*y')
        x^2 + 8*y^3
        >>> f()
        x^3 + y^2

        It's not an error to substitute variables which do not appear:

        >>> f.eval(z=37)
        x^3 + y^2
        >>> pari(42).eval(t=0)
        42

        We can define and evaluate closures as follows:

        >>> T = pari('n -> n + 2')
        >>> T.type()
        't_CLOSURE'
        >>> T.eval(3)
        5

        >>> T = pari('() -> 42')
        >>> T()
        42

        >>> pr = pari('s -> print(s)')
        >>> pr.eval('"hello world"')
        hello world

        >>> f = pari('myfunc(x,y) = x*y')
        >>> f.eval(5, 6)
        30

        Default arguments work, missing arguments are treated as zero
        (like in GP):

        >>> f = pari("(x, y, z=1.0) -> [x, y, z]")
        >>> f(1, 2, 3)
        [1, 2, 3]
        >>> f(1, 2)
        [1, 2, 1.00000000000000]
        >>> f(1)
        [1, 0, 1.00000000000000]
        >>> f()
        [0, 0, 1.00000000000000]

        Variadic closures are supported as well (:trac:`18623`):

        >>> f = pari("(v[..])->length(v)")
        >>> f('a', f)
        2
        >>> g = pari("(x,y,z[..])->[x,y,z]")
        >>> g(), g(1), g(1,2), g(1,2,3), g(1,2,3,4)
        ([0, 0, []], [1, 0, []], [1, 2, []], [1, 2, [3]], [1, 2, [3, 4]])

        Using keyword arguments, we can substitute in more complicated
        objects, for example a number field:

        >>> nf = pari('x^2 + 1').nfinit()
        >>> nf
        [x^2 + 1, [0, 1], -4, 1, [Mat([1, 0.E-38 + 1.00000000000000*I]), [1, 1.00000000000000; 1, -1.00000000000000], ..., [2, 0; 0, -2], [2, 0; 0, 2], [1, 0; 0, -1], [1, [0, -1; 1, 0]], [2]], [0.E-38 + 1.00000000000000*I], [1, x], [1, 0; 0, 1], [1, 0, 0, -1; 0, 1, 1, 0]]
        >>> nf(x='y')
        [y^2 + 1, [0, 1], -4, 1, [Mat([1, 0.E-38 + 1.00000000000000*I]), [1, 1.00000000000000; 1, -1.00000000000000], ..., [2, 0; 0, -2], [2, 0; 0, 2], [1, 0; 0, -1], [1, [0, -1; 1, 0]], [2]], [0.E-38 + 1.00000000000000*I], [1, y], [1, 0; 0, 1], [1, 0, 0, -1; 0, 1, 1, 0]]

        Tests:

        >>> T = pari('n -> 1/n')
        >>> T.type()
        't_CLOSURE'
        >>> T(0)
        Traceback (most recent call last):
        ...
        PariError: _/_: impossible inverse in gdiv: 0
        >>> pari('() -> 42')(1,2,3)
        Traceback (most recent call last):
        ...
        PariError: too many parameters in user-defined function call
        >>> pari('n -> n')(n=2)
        Traceback (most recent call last):
        ...
        TypeError: cannot evaluate a PARI closure using keyword arguments
        >>> pari('x + y')(4, y=1)
        Traceback (most recent call last):
        ...
        TypeError: mixing unnamed and keyword arguments not allowed when evaluating a PARI object
        >>> pari("12345")(4)
        Traceback (most recent call last):
        ...
        TypeError: cannot evaluate PARI t_INT using unnamed arguments
        """
        return self(*args, **kwds)

    def __call__(self, *args, **kwds):
        """
        Evaluate ``self`` with the given arguments. See ``eval``.
        """
        cdef long t = typ(self.g)
        cdef Gen t0
        cdef GEN result
        cdef long arity
        cdef long nargs = len(args)
        cdef long nkwds = len(kwds)

        # Closure must be evaluated using *args
        if t == t_CLOSURE:
            if nkwds:
                raise TypeError("cannot evaluate a PARI closure using keyword arguments")
            if closure_is_variadic(self.g):
                arity = closure_arity(self.g) - 1
                args = list(args[:arity]) + [0]*(arity-nargs) + [args[arity:]]
            t0 = objtogen(args)
            sig_on()
            result = closure_callgenvec(self.g, t0.g)
            if result is gnil:
                clear_stack()
                return None
            return new_gen(result)

        # Evaluate univariate polynomials, rational functions and
        # series using *args
        if nargs:
            if nkwds:
                raise TypeError("mixing unnamed and keyword arguments not allowed when evaluating a PARI object")
            if not (t == t_POL or t == t_RFRAC or t == t_SER):
                raise TypeError("cannot evaluate PARI %s using unnamed arguments" % self.type())
            if nargs != 1:
                raise TypeError("evaluating PARI %s takes exactly 1 argument (%d given)"
                                % (self.type(), nargs))

            t0 = objtogen(args[0])
            sig_on()
            if t == t_POL or t == t_RFRAC:
                return new_gen(poleval(self.g, t0.g))
            else:  # t == t_SER
                return new_gen(gsubst(self.g, varn(self.g), t0.g))

        # Call substvec() using **kwds
        cdef list V = [to_bytes(k) for k in kwds]  # Variables as Python byte strings
        t0 = objtogen(kwds.values())               # Replacements

        sig_on()
        cdef GEN v = cgetg(nkwds+1, t_VEC)  # Variables as PARI polynomials
        cdef long i
        for i in range(nkwds):
            varname = <bytes>V[i]
            set_gel(v, i+1, pol_x(fetch_user_var(varname)))
        return new_gen(gsubstvec(self.g, v, t0.g))

    def arity(self):
        """
        Return the number of arguments of this ``t_CLOSURE``.

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari("() -> 42").arity()
        0
        >>> pari("(x) -> x").arity()
        1
        >>> pari("(x,y,z) -> x+y+z").arity()
        3
        """
        if typ(self.g) != t_CLOSURE:
            raise TypeError("arity() requires a t_CLOSURE")
        return closure_arity(self.g)

    def factorpadic(self, p, long r=20):
        """
        p-adic factorization of the polynomial ``pol`` to precision ``r``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pol = pari('x^2 - 1')**2
        >>> pari(pol).factorpadic(5)
        [(1 + O(5^20))*x + (1 + O(5^20)), 2; (1 + O(5^20))*x + (4 + 4*5 + 4*5^2 + 4*5^3 + 4*5^4 + 4*5^5 + 4*5^6 + 4*5^7 + 4*5^8 + 4*5^9 + 4*5^10 + 4*5^11 + 4*5^12 + 4*5^13 + 4*5^14 + 4*5^15 + 4*5^16 + 4*5^17 + 4*5^18 + 4*5^19 + O(5^20)), 2]
        >>> pari(pol).factorpadic(5,3)
        [(1 + O(5^3))*x + (1 + O(5^3)), 2; (1 + O(5^3))*x + (4 + 4*5 + 4*5^2 + O(5^3)), 2]
        """
        cdef Gen t0 = objtogen(p)
        sig_on()
        return new_gen(factorpadic(self.g, t0.g, r))

    def ncols(self):
        """
        Return the number of columns of self.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('matrix(19,8)').ncols()
        8
        """
        cdef long n
        sig_on()
        n = glength(self.g)
        sig_off()
        return n

    def nrows(self):
        """
        Return the number of rows of self.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('matrix(19,8)').nrows()
        19
        """
        cdef long n
        sig_on()
        # if this matrix has no columns
        # then it has no rows.
        if self.ncols() == 0:
            sig_off()
            return 0
        n = glength(gel(self.g, 1))
        sig_off()
        return n

    def mattranspose(self):
        """
        Transpose of the matrix self.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('[1,2,3; 4,5,6; 7,8,9]').mattranspose()
        [1, 4, 7; 2, 5, 8; 3, 6, 9]

        Unlike PARI, this always returns a matrix:

        >>> pari('[1,2,3]').mattranspose()
        [1; 2; 3]
        >>> pari('[1,2,3]~').mattranspose()
        Mat([1, 2, 3])
        """
        sig_on()
        return new_gen(gtrans(self.g)).Mat()

    def lllgram(self):
        return self.qflllgram(0)

    def lllgramint(self):
        return self.qflllgram(1)

    def qfrep(self, B, long flag=0):
        """
        Vector of (half) the number of vectors of norms from 1 to `B`
        for the integral and definite quadratic form ``self``.
        Binary digits of flag mean 1: count vectors of even norm from
        1 to `2B`, 2: return a ``t_VECSMALL`` instead of a ``t_VEC``
        (which is faster).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> M = pari("[5,1,1;1,3,1;1,1,1]")
        >>> M.qfrep(20)
        [1, 1, 2, 2, 2, 4, 4, 3, 3, 4, 2, 4, 6, 0, 4, 6, 4, 5, 6, 4]
        >>> M.qfrep(20, flag=1)
        [1, 2, 4, 3, 4, 4, 0, 6, 5, 4, 12, 4, 4, 8, 0, 3, 8, 6, 12, 12]
        >>> M.qfrep(20, flag=2)
        Vecsmall([1, 1, 2, 2, 2, 4, 4, 3, 3, 4, 2, 4, 6, 0, 4, 6, 4, 5, 6, 4])
        """
        # PARI 2.7 always returns a t_VECSMALL, but for backwards
        # compatibility, we keep returning a t_VEC (unless flag & 2)
        cdef Gen t0 = objtogen(B)
        cdef GEN r
        sig_on()
        r = qfrep0(self.g, t0.g, flag & 1)
        if (flag & 2) == 0:
            r = vecsmall_to_vec(r)
        return new_gen(r)

    def matkerint(self, long flag=0):
        """
        Return the integer kernel of a matrix.

        This is the LLL-reduced Z-basis of the kernel of the matrix x with
        integral entries.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('[2,1;2,1]').matkerint()
        [1; -2]
        >>> import warnings
        >>> with warnings.catch_warnings(record=True) as w:
        ...     warnings.simplefilter('always')
        ...     pari('[2,1;2,1]').matkerint(1)
        ...     assert len(w) == 1
        ...     assert issubclass(w[0].category, DeprecationWarning)
        [1; -2]
        """
        if flag:
            # Keep this deprecation warning as long as PARI supports
            # this deprecated flag
            from warnings import warn
            warn("the 'flag' argument of the PARI/GP function matkerint is obsolete", DeprecationWarning)
        sig_on()
        return new_gen(matkerint0(self.g, flag))

    def factor(self, long limit=-1, proof=None):
        """
        Return the factorization of x.

        INPUT:

        -  ``limit`` -- (default: -1) is optional and can be set
           whenever x is of (possibly recursive) rational type. If limit is
           set, return partial factorization, using primes up to limit.

        - ``proof`` -- optional flag. If ``False`` (not the default),
          returned factors larger than `2^{64}` may only be pseudoprimes.
          If ``True``, always check primality. If not given, use the
          global PARI default ``factor_proven`` which is ``True`` by
          default in cypari.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('x^10-1').factor()
        [x - 1, 1; x + 1, 1; x^4 - x^3 + x^2 - x + 1, 1; x^4 + x^3 + x^2 + x + 1, 1]
        >>> pari(2**100-1).factor()
        [3, 1; 5, 3; 11, 1; 31, 1; 41, 1; 101, 1; 251, 1; 601, 1; 1801, 1; 4051, 1; 8101, 1; 268501, 1]
        >>> pari(2**100-1).factor(proof=True)
        [3, 1; 5, 3; 11, 1; 31, 1; 41, 1; 101, 1; 251, 1; 601, 1; 1801, 1; 4051, 1; 8101, 1; 268501, 1]
        >>> pari(2**100-1).factor(proof=False)
        [3, 1; 5, 3; 11, 1; 31, 1; 41, 1; 101, 1; 251, 1; 601, 1; 1801, 1; 4051, 1; 8101, 1; 268501, 1]

        We illustrate setting a limit:

        >>> pari(pari(10**50).nextprime()*pari(10**60).nextprime()*pari(10**4).nextprime()).factor(10**5)
        [10007, 1; 100000000000000000000000000000000000000000000000151000000000700000000000000000000000000000000000000000000001057, 1]

        Setting a limit is invalid when factoring polynomials:

        >>> pari('x^11 + 1').factor(limit=17)
        Traceback (most recent call last):
        ...
        PariError: incorrect type in boundfact (t_POL)
        """
        cdef GEN g
        global factor_proven
        cdef int saved_factor_proven = factor_proven

        try:
            if proof is not None:
                factor_proven = 1 if proof else 0
            sig_on()
            if limit >= 0:
                g = boundfact(self.g, limit)
            else:
                g = factor(self.g)
            return new_gen(g)
        finally:
            factor_proven = saved_factor_proven

    # Standard name for SageMath
    multiplicative_order = Gen_base.znorder

    def __abs__(self):
        return self.abs()

    def nextprime(self, bint add_one=False):
        """
        nextprime(x): smallest pseudoprime greater than or equal to `x`.
        If ``add_one`` is non-zero, return the smallest pseudoprime
        strictly greater than `x`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(1).nextprime()
        2
        >>> pari(2).nextprime()
        2
        >>> pari(2).nextprime(add_one = 1)
        3
        >>> pari(2**100).nextprime()
        1267650600228229401496703205653
        """
        sig_on()
        if add_one:
            return new_gen(nextprime(gaddsg(1, self.g)))
        return new_gen(nextprime(self.g))

    def change_variable_name(self, var):
        """
        In ``self``, which must be a ``t_POL`` or ``t_SER``, set the
        variable to ``var``.  If the variable of ``self`` is already
        ``var``, then return ``self``.

        .. WARNING::

            You should be careful with variable priorities when
            applying this on a polynomial or series of which the
            coefficients have polynomial components.  To be safe, only
            use this function on polynomials with integer or rational
            coefficients.  For a safer alternative, use :meth:`subst`.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> f = pari('x^3 + 17*x + 3')
        >>> f.change_variable_name("y")
        y^3 + 17*y + 3
        >>> f = pari('1 + 2*y + O(y^10)')
        >>> f.change_variable_name("q")
        1 + 2*q + O(q^10)
        >>> f.change_variable_name("y") is f
        True

        In PARI, ``I`` refers to the square root of -1, so it cannot be
        used as variable name.  Note the difference with :meth:`subst`:

        >>> f = pari('x^2 + 1')
        >>> f.change_variable_name("I")
        Traceback (most recent call last):
        ...
        PariError: I already exists with incompatible valence
        >>> f.subst("x", "I")
        0
        """
        cdef long n = get_var(var)
        if varn(self.g) == n:
            return self
        if typ(self.g) != t_POL and typ(self.g) != t_SER:
            raise TypeError("set_variable() only works for polynomials or power series")
        # Copy self and then change the variable in place
        sig_on()
        newg = clone_gen(self.g)
        setvarn(newg.g, n)
        return newg

    def nf_subst(self, z):
        """
        Given a PARI number field ``self``, return the same PARI
        number field but in the variable ``z``.

        INPUT:

        - ``self`` -- A PARI number field being the output of ``nfinit()``,
                      ``bnfinit()`` or ``bnrinit()``.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> K = pari('y^2 + 5').nfinit()

        We can substitute in a PARI ``nf`` structure:

        >>> K.nf_get_pol()
        y^2 + 5
        >>> L = K.nf_subst('a')
        >>> L.nf_get_pol()
        a^2 + 5

        We can also substitute in a PARI ``bnf`` structure:

        >>> K = pari('y^2 + 5').bnfinit()
        >>> K.nf_get_pol()
        y^2 + 5
        >>> K.bnf_get_cyc()  # Structure of class group
        [2]
        >>> L = K.nf_subst('a')
        >>> L.nf_get_pol()
        a^2 + 5
        >>> L.bnf_get_cyc()  # We still have a bnf after substituting
        [2]
        """
        cdef Gen t0 = objtogen(z)
        sig_on()
        return new_gen(gsubst(self.g, gvar(self.g), t0.g))

    def type(self):
        """
        Return the PARI type of self as a string.

        .. NOTE::

           In Cython, it is much faster to simply use typ(self.g) for
           checking PARI types.

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari(7).type()
        't_INT'
        >>> pari('x').type()
        't_POL'
        >>> pari('oo').type()
        't_INFINITY'
        """
        sig_on()
        s = type_name(typ(self.g))
        sig_off()
        return to_string(s)

    def polinterpolate(self, ya, x):
        """
        self.polinterpolate(ya,x,e): polynomial interpolation at x
        according to data vectors self, ya (i.e. return P such that
        P(self[i]) = ya[i] for all i). Also return an error estimate on the
        returned value.
        """
        cdef Gen t0 = objtogen(ya)
        cdef Gen t1 = objtogen(x)
        cdef GEN dy, g
        sig_on()
        g = polint(self.g, t0.g, t1.g, &dy)
        return new_gens2(g, dy)

    def ellwp(self, z='z', long n=20, long flag=0, unsigned long precision=0):
        """
        Return the value or the series expansion of the Weierstrass
        `P`-function at `z` on the lattice `self` (or the lattice
        defined by the elliptic curve `self`).

        INPUT:

        -  ``self`` -- an elliptic curve created using ``ellinit`` or a
           list ``[om1, om2]`` representing generators for a lattice.

        -  ``z`` -- (default: 'z') a complex number or a variable name
           (as string or PARI variable).

        -  ``n`` -- (default: 20) if 'z' is a variable, compute the
           series expansion up to at least `O(z^n)`.

        -  ``flag`` -- (default = 0): If ``flag`` is 0, compute only
           `P(z)`.  If ``flag`` is 1, compute `[P(z), P'(z)]`.

        OUTPUT:

        - `P(z)` (if ``flag`` is 0) or `[P(z), P'(z)]` (if ``flag`` is 1).
           numbers

        Examples:

        We first define the elliptic curve X_0(11):

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> E = pari([0,-1,1,-10,-20]).ellinit()

        Compute P(1):

        >>> E.ellwp(1)
        13.9658695257485

        Compute P(1+i), where i = sqrt(-1):

        >>> E.ellwp(pari(complex(1, 1)))
        -1.11510682565555 + 2.33419052307470*I
        >>> E.ellwp(complex(1, 1))
        -1.11510682565555 + 2.33419052307470*I

        The series expansion, to the default `O(z^20)` precision:

        >>> E.ellwp()
        z^-2 + 31/15*z^2 + 2501/756*z^4 + 961/675*z^6 + 77531/41580*z^8 + 1202285717/928746000*z^10 + 2403461/2806650*z^12 + 30211462703/43418875500*z^14 + 3539374016033/7723451736000*z^16 + 413306031683977/1289540602350000*z^18 + O(z^20)

        Compute the series for wp to lower precision:

        >>> E.ellwp(n=4)
        z^-2 + 31/15*z^2 + O(z^4)

        Next we use the version where the input is generators for a
        lattice:

        >>> pari([1.2692, complex(0.63, 1.45)]).ellwp(1)
        13.9656146936689 + 0.000644829272810...*I

        With flag=1, compute the pair P(z) and P'(z):

        >>> E.ellwp(1, flag=1)
        [13.9658695257485, 101.123860176015]
        """
        cdef Gen t0 = objtogen(z)
        cdef GEN g0 = t0.g

        sig_on()
        # Polynomial or rational function as input:
        # emulate toser_i() but with given precision
        if typ(g0) == t_POL:
            g0 = RgX_to_ser(g0, n+4)
        elif typ(g0) == t_RFRAC:
            g0 = rfrac_to_ser(g0, n+4)

        cdef GEN r = ellwp0(self.g, g0, flag, prec_bits_to_words(precision))
        if flag == 1 and have_ellwp_flag1_bug():
            # Work around ellwp() bug: double the second element
            set_gel(r, 2, gmulgs(gel(r, 2), 2))
        return new_gen(r)

    def debug(self, long depth=-1):
        r"""
        Show the internal structure of self (like the ``\x`` command in gp).

        Examples:

        >>> from cypari2 import Pari
        >>> pari = Pari()

        >>> pari('[1/2, 1 + 1.0*I]').debug()
        [&=...] VEC(lg=3):...
          1st component = [&=...] FRAC(lg=3):...
            num = [&=...] INT(lg=3):... (+,lgefint=3):...
            den = [&=...] INT(lg=3):... (+,lgefint=3):...
          2nd component = [&=...] COMPLEX(lg=3):...
            real = [&=...] INT(lg=3):... (+,lgefint=3):...
            imag = [&=...] REAL(lg=...):... (+,expo=0):...
        """
        sig_on()
        dbgGEN(self.g, depth)
        clear_stack()
        return

    def allocatemem(self, *args):
        """
        Do not use this. Use ``pari.allocatemem()`` instead.

        Tests:

        >>> from cypari2 import Pari
        >>> pari = Pari()
        >>> pari(2**10).allocatemem(2**20)
        Traceback (most recent call last):
        ...
        NotImplementedError: the method allocatemem() should not be used; use pari.allocatemem() instead
        """
        raise NotImplementedError("the method allocatemem() should not be used; use pari.allocatemem() instead")


cdef int Gen_clear(self) except -1:
    """
    Implementation of tp_clear() for Gen. We need to override Cython's
    default since we do not want self.next to be cleared: it is crucial
    that the next Gen stays alive until remove_from_pari_stack(self) is
    called by __dealloc__.
    """
    # Only itemcache needs to be cleared
    (<Gen>self).itemcache = None


(<PyTypeObject*>Gen).tp_clear = Gen_clear


@cython.boundscheck(False)
@cython.wraparound(False)
cdef Gen list_of_Gens_to_Gen(list s):
    """
    Convert a Python list whole elements are all :class:`Gen` objects
    (this is not checked!) to a single PARI :class:`Gen` of type ``t_VEC``.

    This is called from :func:`objtogen` to convert iterables to PARI.

    Tests:

    >>> from cypari2.gen import objtogen
    >>> from cypari2 import Pari
    >>> pari = Pari()

    >>> objtogen(range(10))
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    >>> objtogen(i**2 for i in range(5))
    [0, 1, 4, 9, 16]
    >>> objtogen([pari("Mod(x, x^2+1)")])
    [Mod(x, x^2 + 1)]
    >>> objtogen([])
    []
    """
    cdef Py_ssize_t length = len(s)

    sig_on()
    cdef GEN g = cgetg(length+1, t_VEC)

    cdef Py_ssize_t i
    for i in range(length):
        set_gel(g, i+1, (<Gen>s[i]).g)
    return clone_gen(g)


cpdef Gen objtogen(s):
    """
    Convert any SageMath/Python object to a PARI :class:`Gen`.

    For SageMath types, this uses the ``__pari__()`` method on the
    object. Basic Python types like ``int`` are converted directly.
    For other types, the string representation is used.

    Examples:

    >>> from cypari2 import Pari
    >>> pari = Pari()

    >>> pari(0)
    0
    >>> pari([2,3,5])
    [2, 3, 5]

    >>> a = pari(1)
    >>> a, a.type()
    (1, 't_INT')

    >>> from fractions import Fraction
    >>> a = pari(Fraction('1/2'))
    >>> a, a.type()
    (1/2, 't_FRAC')

    Conversion from reals uses the real's own precision:

    >>> a = pari(1.2); a, a.type(), a.bitprecision()
    (1.20000000000000, 't_REAL', 64)

    Conversion from strings uses the current PARI real precision.
    By default, this is 64 bits:

    >>> a = pari('1.2'); a, a.type(), a.bitprecision()
    (1.20000000000000, 't_REAL', 64)

    Unicode and bytes work fine:

    >>> pari(b"zeta(3)")
    1.20205690315959
    >>> pari(u"zeta(3)")
    1.20205690315959

    But we can change this precision:

    >>> pari.set_real_precision(35)  # precision in decimal digits
    15
    >>> a = pari('Pi'); a, a.type(), a.bitprecision()
    (3.1415926535897932384626433832795029, 't_REAL', 128)
    >>> a = pari('1.2'); a, a.type(), a.bitprecision()
    (1.2000000000000000000000000000000000, 't_REAL', 128)

    Set the precision to 15 digits for the remaining tests:

    >>> pari.set_real_precision(15)
    35

    Conversion from basic Python types:

    >>> pari(int(-5))
    -5
    >>> pari(2**150)
    1427247692705959881058285969449495136382746624
    >>> import math
    >>> pari(math.pi)
    3.14159265358979
    >>> one = pari(complex(1,0)); one, one.type()
    (1.00000000000000, 't_COMPLEX')
    >>> pari(complex(0, 1))
    1.00000000000000*I
    >>> pari(complex(0.3, 1.7))
    0.300000000000000 + 1.70000000000000*I

    >>> pari(False)
    0
    >>> pari(True)
    1

    The following looks strange, but it is what PARI does:

    >>> pari(["print(x)"])
    x
    [0]
    >>> pari("[print(x)]")
    x
    [0]

    Tests:

    >>> pari(None)
    Traceback (most recent call last):
    ...
    ValueError: Cannot convert None to pari

    """
    if isinstance(s, Gen):
        return s

    try:
        m = s.__pari__
    except AttributeError:
        pass
    else:
        return m()

    cdef GEN g = PyObject_AsGEN(s)
    if g is not NULL:
        res = new_gen_noclear(g)
        reset_avma()
        return res

    # Check for iterables. Handle the common cases of lists and tuples
    # separately as an optimization
    cdef list L
    if isinstance(s, list):
        L = [objtogen(x) for x in <list>s]
        return list_of_Gens_to_Gen(L)
    if isinstance(s, tuple):
        L = [objtogen(x) for x in <tuple>s]
        return list_of_Gens_to_Gen(L)
    # Check for iterable object s
    try:
        L = [objtogen(x) for x in s]
    except TypeError:
        pass
    else:
        return list_of_Gens_to_Gen(L)

    if callable(s):
        return objtoclosure(s)

    if s is None:
        raise ValueError("Cannot convert None to pari")

    # Simply use the string representation
    return objtogen(str(s))
