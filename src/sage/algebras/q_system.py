# sage_setup: distribution = sagemath-combinat
# sage.doctest: needs sage.combinat sage.graphs sage.modules
r"""
Q-Systems

AUTHORS:

- Travis Scrimshaw (2013-10-08): Initial version
- Travis Scrimshaw (2017-12-08): Added twisted Q-systems
"""

#*****************************************************************************
#       Copyright (C) 2013,2017 Travis Scrimshaw <tcscrims at gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

import itertools
from sage.misc.cachefunc import cached_method
from sage.misc.misc_c import prod

from sage.categories.algebras import Algebras
from sage.rings.integer_ring import ZZ
from sage.rings.infinity import infinity
from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
from sage.sets.family import Family
from sage.combinat.free_module import CombinatorialFreeModule
from sage.monoids.indexed_free_monoid import IndexedFreeAbelianMonoid
from sage.combinat.root_system.cartan_type import CartanType


class QSystem(CombinatorialFreeModule):
    r"""
    A Q-system.

    Let `\mathfrak{g}` be a tamely-laced symmetrizable Kac-Moody algebra
    with index set `I` and Cartan matrix `(C_{ab})_{a,b \in I}` over a
    field `k`. Follow the presentation given in [HKOTY1999]_, an
    unrestricted Q-system is a `k`-algebra in infinitely many variables
    `Q^{(a)}_m`, where `a \in I` and `m \in \ZZ_{>0}`, that satisfies
    the relations

    .. MATH::

        \left(Q^{(a)}_m\right)^2 = Q^{(a)}_{m+1} Q^{(a)}_{m-1} +
        \prod_{b \sim a} \prod_{k=0}^{-C_{ab} - 1}
        Q^{(b)}_{\left\lfloor \frac{m C_{ba} - k}{C_{ab}} \right\rfloor},

    with `Q^{(a)}_0 := 1`. Q-systems can be considered as T-systems where
    we forget the spectral parameter `u` and for `\mathfrak{g}` of finite
    type, have a solution given by the characters of Kirillov-Reshetikhin
    modules (again without the spectral parameter) for an affine Kac-Moody
    algebra `\widehat{\mathfrak{g}}` with `\mathfrak{g}` as its classical
    subalgebra. See [KNS2011]_ for more information.

    Q-systems have a natural bases given by polynomials of the
    fundamental representations `Q^{(a)}_1`, for `a \in I`. As such, we
    consider the Q-system as generated by `\{ Q^{(a)}_1 \}_{a \in I}`.

    There is also a level `\ell` restricted Q-system (with unit boundary
    condition) given by setting `Q_{d_a \ell}^{(a)} = 1`, where `d_a`
    are the entries of the symmetrizing matrix for the dual type of
    `\mathfrak{g}`.

    Similarly, for twisted affine types (we omit type `A_{2n}^{(2)}`),
    we can define the *twisted Q-system* by using the relation:

    .. MATH::

        (Q^{(a)}_{m})^2 = Q^{(a)}_{m+1} Q^{(a)}_{m-1}
         + \prod_{b \neq a} (Q^{(b)}_{m})^{-C_{ba}}.

    See [Wil2013]_ for more information.

    EXAMPLES:

    We begin by constructing a Q-system and doing some basic computations
    in type `A_4`::

        sage: Q = QSystem(QQ, ['A', 4])
        sage: Q.Q(3,1)
        Q^(3)[1]
        sage: Q.Q(1,2)
        Q^(1)[1]^2 - Q^(2)[1]
        sage: Q.Q(3,3)
        -Q^(1)[1]*Q^(3)[1] + Q^(1)[1]*Q^(4)[1]^2 + Q^(2)[1]^2
         - 2*Q^(2)[1]*Q^(3)[1]*Q^(4)[1] + Q^(3)[1]^3
        sage: x = Q.Q(1,1) + Q.Q(2,1); x
        Q^(1)[1] + Q^(2)[1]
        sage: x * x
        Q^(1)[1]^2 + 2*Q^(1)[1]*Q^(2)[1] + Q^(2)[1]^2

    Next we do some basic computations in type `C_4`::

        sage: Q = QSystem(QQ, ['C', 4])
        sage: Q.Q(4,1)
        Q^(4)[1]
        sage: Q.Q(1,2)
        Q^(1)[1]^2 - Q^(2)[1]
        sage: Q.Q(2,3)
        Q^(1)[1]^2*Q^(4)[1] - 2*Q^(1)[1]*Q^(2)[1]*Q^(3)[1]
         + Q^(2)[1]^3 - Q^(2)[1]*Q^(4)[1] + Q^(3)[1]^2
        sage: Q.Q(3,3)
        Q^(1)[1]*Q^(4)[1]^2 - 2*Q^(2)[1]*Q^(3)[1]*Q^(4)[1] + Q^(3)[1]^3

    We compare that with the twisted Q-system of type `A_7^{(2)}`::

        sage: Q = QSystem(QQ, ['A',7,2], twisted=True)
        sage: Q.Q(4,1)
        Q^(4)[1]
        sage: Q.Q(1,2)
        Q^(1)[1]^2 - Q^(2)[1]
        sage: Q.Q(2,3)
        Q^(1)[1]^2*Q^(4)[1] - 2*Q^(1)[1]*Q^(2)[1]*Q^(3)[1]
         + Q^(2)[1]^3 - Q^(2)[1]*Q^(4)[1] + Q^(3)[1]^2
        sage: Q.Q(3,3)
        -Q^(1)[1]*Q^(3)[1]^2 + Q^(1)[1]*Q^(4)[1]^2 + Q^(2)[1]^2*Q^(3)[1]
         - 2*Q^(2)[1]*Q^(3)[1]*Q^(4)[1] + Q^(3)[1]^3

    REFERENCES:

    - [HKOTY1999]_
    - [KNS2011]_
    """
    @staticmethod
    def __classcall__(cls, base_ring, cartan_type, level=None, twisted=False):
        """
        Normalize arguments to ensure a unique representation.

        EXAMPLES::

            sage: Q1 = QSystem(QQ, ['A',4])
            sage: Q2 = QSystem(QQ, 'A4')
            sage: Q1 is Q2
            True

        Twisted Q-systems are different from untwisted Q-systems::

            sage: Q1 = QSystem(QQ, ['E',6,2], twisted=True)
            sage: Q2 = QSystem(QQ, ['E',6,2])
            sage: Q1 is Q2
            False
        """
        cartan_type = CartanType(cartan_type)
        if not is_tamely_laced(cartan_type):
            raise ValueError("the Cartan type is not tamely-laced")
        if twisted and not cartan_type.is_affine() and not cartan_type.is_untwisted_affine():
            raise ValueError("the Cartan type must be of twisted type")
        return super().__classcall__(cls, base_ring, cartan_type, level, twisted)

    def __init__(self, base_ring, cartan_type, level, twisted):
        """
        Initialize ``self``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',2])
            sage: TestSuite(Q).run()

            sage: Q = QSystem(QQ, ['E',6,2], twisted=True)
            sage: TestSuite(Q).run()
        """
        self._cartan_type = cartan_type
        self._level = level
        self._twisted = twisted
        indices = tuple(itertools.product(cartan_type.index_set(), [1]))
        basis = IndexedFreeAbelianMonoid(indices, prefix='Q', bracket=False)
        # This is used to do the reductions
        if self._twisted:
            self._cm = cartan_type.classical().cartan_matrix()
        else:
            self._cm = cartan_type.cartan_matrix()
        self._Irev = {ind: pos for pos,ind in enumerate(self._cm.index_set())}
        self._poly = PolynomialRing(ZZ, ['q'+str(i) for i in self._cm.index_set()])

        category = Algebras(base_ring).Commutative().WithBasis()
        CombinatorialFreeModule.__init__(self, base_ring, basis,
                                         prefix='Q', category=category)

    def _repr_(self):
        r"""
        Return a string representation of ``self``.

        EXAMPLES::

            sage: QSystem(QQ, ['A',4])
            Q-system of type ['A', 4] over Rational Field

            sage: QSystem(QQ, ['A',7,2], twisted=True)
            Twisted Q-system of type ['B', 4, 1]^* over Rational Field
        """
        if self._level is not None:
            res = "Restricted level {} ".format(self._level)
        else:
            res = ''
        if self._twisted:
            res += "Twisted "
        return "{}Q-system of type {} over {}".format(res, self._cartan_type, self.base_ring())

    def _repr_term(self, t):
        """
        Return a string representation of the basis element indexed by ``t``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: I = Q._indices
            sage: Q._repr_term( I.gen((1,1)) * I.gen((4,1)) )
            'Q^(1)[1]*Q^(4)[1]'
        """
        if len(t) == 0:
            return '1'

        def repr_gen(x):
            ret = 'Q^({})[{}]'.format(*(x[0]))
            if x[1] > 1:
                ret += '^{}'.format(x[1])
            return ret
        return '*'.join(repr_gen(x) for x in t._sorted_items())

    def _latex_term(self, t):
        r"""
        Return a `\LaTeX` representation of the basis element indexed
        by ``t``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: I = Q._indices
            sage: Q._latex_term( I.gen((3,1)) * I.gen((4,1)) )
            'Q^{(3)}_{1} Q^{(4)}_{1}'
        """
        if len(t) == 0:
            return '1'

        def repr_gen(x):
            ret = 'Q^{{({})}}_{{{}}}'.format(*(x[0]))
            if x[1] > 1:
                ret = '\\bigl(' + ret + '\\bigr)^{{{}}}'.format(x[1])
            return ret
        return ' '.join(repr_gen(x) for x in t._sorted_items())

    def _ascii_art_term(self, t):
        """
        Return an ascii art representation of the term indexed by ``t``.

        TESTS::

            sage: Q = QSystem(QQ, ['A',4])
            sage: ascii_art(Q.an_element())
                               2       2       3
                   (1)   ( (1))  ( (2))  ( (3))       (2)
            1 + 2*Q1   + (Q1  ) *(Q1  ) *(Q1  )  + 3*Q1
        """
        from sage.typeset.ascii_art import AsciiArt
        if t == self.one_basis():
            return AsciiArt(["1"])
        ret = AsciiArt("")
        first = True
        for k, exp in t._sorted_items():
            if not first:
                ret += AsciiArt(['*'], baseline=0)
            else:
                first = False
            a, m = k
            var = AsciiArt([" ({})".format(a),
                            "Q{}".format(m)],
                           baseline=0)
            if exp > 1:
                var = (AsciiArt(['(', '('], baseline=0) + var
                       + AsciiArt([')', ')'], baseline=0))
                var = AsciiArt([" " * len(var) + str(exp)], baseline=-1) * var
            ret += var
        return ret

    def _unicode_art_term(self, t):
        r"""
        Return a unicode art representation of the term indexed by ``t``.

        TESTS::

            sage: Q = QSystem(QQ, ['A',4])
            sage: unicode_art(Q.an_element())
            1 + 2*Q₁⁽¹⁾ + (Q₁⁽¹⁾)²(Q₁⁽²⁾)²(Q₁⁽³⁾)³ + 3*Q₁⁽²⁾
        """
        from sage.typeset.unicode_art import UnicodeArt, unicode_subscript, unicode_superscript
        if t == self.one_basis():
            return UnicodeArt(["1"])

        ret = UnicodeArt("")
        for k, exp in t._sorted_items():
            a,m = k
            var = UnicodeArt(["Q" + unicode_subscript(m) + '⁽' + unicode_superscript(a) + '⁾'], baseline=0)
            if exp > 1:
                var = (UnicodeArt(['('], baseline=0) + var
                       + UnicodeArt([')' + unicode_superscript(exp)], baseline=0))
            ret += var
        return ret

    def cartan_type(self):
        """
        Return the Cartan type of ``self``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: Q.cartan_type()
            ['A', 4]

            sage: Q = QSystem(QQ, ['D',4,3], twisted=True)
            sage: Q.cartan_type()
            ['G', 2, 1]^* relabelled by {0: 0, 1: 2, 2: 1}
        """
        return self._cartan_type

    def index_set(self):
        """
        Return the index set of ``self``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: Q.index_set()
            (1, 2, 3, 4)

            sage: Q = QSystem(QQ, ['D',4,3], twisted=True)
            sage: Q.index_set()
            (1, 2)
        """
        return self._cm.index_set()

    def level(self):
        """
        Return the restriction level of ``self`` or ``None`` if
        the system is unrestricted.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: Q.level()

            sage: Q = QSystem(QQ, ['A',4], 5)
            sage: Q.level()
            5
        """
        return self._level

    @cached_method
    def one_basis(self):
        """
        Return the basis element indexing `1`.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: Q.one_basis()
            1
            sage: Q.one_basis().parent() is Q._indices
            True
        """
        return self._indices.one()

    @cached_method
    def algebra_generators(self):
        """
        Return the algebra generators of ``self``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: Q.algebra_generators()
            Finite family {1: Q^(1)[1], 2: Q^(2)[1], 3: Q^(3)[1], 4: Q^(4)[1]}

            sage: Q = QSystem(QQ, ['D',4,3], twisted=True)
            sage: Q.algebra_generators()
            Finite family {1: Q^(1)[1], 2: Q^(2)[1]}
        """
        I = self._cm.index_set()
        d = {a: self.Q(a, 1) for a in I}
        return Family(I, d.__getitem__)

    def gens(self) -> tuple:
        """
        Return the generators of ``self``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',4])
            sage: Q.gens()
            (Q^(1)[1], Q^(2)[1], Q^(3)[1], Q^(4)[1])
        """
        return tuple(self.algebra_generators())

    def dimension(self):
        r"""
        Return the dimension of ``self``, which is `\infty`.

        EXAMPLES::

            sage: F = QSystem(QQ, ['A',4])
            sage: F.dimension()
            +Infinity
        """
        return infinity

    def Q(self, a, m):
        r"""
        Return the generator `Q^{(a)}_m` of ``self``.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A', 8])
            sage: Q.Q(2, 1)
            Q^(2)[1]
            sage: Q.Q(6, 2)
            -Q^(5)[1]*Q^(7)[1] + Q^(6)[1]^2
            sage: Q.Q(7, 3)
            -Q^(5)[1]*Q^(7)[1] + Q^(5)[1]*Q^(8)[1]^2 + Q^(6)[1]^2
             - 2*Q^(6)[1]*Q^(7)[1]*Q^(8)[1] + Q^(7)[1]^3
            sage: Q.Q(1, 0)
            1

        Twisted Q-system::

            sage: Q = QSystem(QQ, ['D',4,3], twisted=True)
            sage: Q.Q(1,2)
            Q^(1)[1]^2 - Q^(2)[1]
            sage: Q.Q(2,2)
            -Q^(1)[1]^3 + Q^(2)[1]^2
            sage: Q.Q(2,3)
            3*Q^(1)[1]^4 - 2*Q^(1)[1]^3*Q^(2)[1] - 3*Q^(1)[1]^2*Q^(2)[1]
             + Q^(2)[1]^2 + Q^(2)[1]^3
            sage: Q.Q(1,4)
            -2*Q^(1)[1]^2 + 2*Q^(1)[1]^3 + Q^(1)[1]^4
             - 3*Q^(1)[1]^2*Q^(2)[1] + Q^(2)[1] + Q^(2)[1]^2
        """
        if a not in self._cartan_type.index_set():
            raise ValueError("a is not in the index set")
        if m == 0:
            return self.one()
        if self._level:
            t = self._cartan_type.dual().cartan_matrix().symmetrizer()
            if m == t[a] * self._level:
                return self.one()
        if m == 1:
            return self.monomial(self._indices.gen((a,1)))
        #if self._cartan_type.type() == 'A' and self._level is None:
        #    return self._jacobi_trudy(a, m)
        I = self._cm.index_set()
        p = self._Q_poly(a, m)
        return p.subs({g: self.Q(I[i], 1) for i,g in enumerate(self._poly.gens())})

    @cached_method
    def _Q_poly(self, a, m):
        r"""
        Return the element `Q^{(a)}_m` as a polynomial.

        We start with the relation

        .. MATH::

            (Q^{(a)}_{m-1})^2 = Q^{(a)}_m Q^{(a)}_{m-2} + \mathcal{Q}_{a,m-1},

        which implies

        .. MATH::

            Q^{(a)}_m = \frac{Q^{(a)}_{m-1}^2 - \mathcal{Q}_{a,m-1}}{
            Q^{(a)}_{m-2}}.

        This becomes our relation used for reducing the Q-system to the
        fundamental representations.

        For twisted Q-systems, we use

        .. MATH::

            (Q^{(a)}_{m-1})^2 = Q^{(a)}_m Q^{(a)}_{m-2}
             + \prod_{b \neq a} (Q^{(b)}_{m-1})^{-A_{ba}}.

        .. NOTE::

            This helper method is defined in order to use the
            division implemented in polynomial rings.

        EXAMPLES::

            sage: Q = QSystem(QQ, ['A',8])
            sage: Q._Q_poly(1, 2)
            q1^2 - q2
            sage: Q._Q_poly(3, 2)
            q3^2 - q2*q4
            sage: Q._Q_poly(6, 3)
            q6^3 - 2*q5*q6*q7 + q4*q7^2 + q5^2*q8 - q4*q6*q8

        Twisted types::

            sage: Q = QSystem(QQ, ['E',6,2], twisted=True)
            sage: Q._Q_poly(1,2)
            q1^2 - q2
            sage: Q._Q_poly(2,2)
            q2^2 - q1*q3
            sage: Q._Q_poly(3,2)
            -q2^2*q4 + q3^2
            sage: Q._Q_poly(4,2)
            q4^2 - q3
            sage: Q._Q_poly(3,3)
            2*q1*q2^2*q4^2 - q1^2*q3*q4^2 + q2^4 - 2*q1*q2^2*q3
             + q1^2*q3^2 - 2*q2^2*q3*q4 + q3^3

            sage: Q = QSystem(QQ, ['D',4,3], twisted=True)
            sage: Q._Q_poly(1,2)
            q1^2 - q2
            sage: Q._Q_poly(2,2)
            -q1^3 + q2^2
            sage: Q._Q_poly(1,3)
            q1^3 + q1^2 - 2*q1*q2
            sage: Q._Q_poly(2,3)
            3*q1^4 - 2*q1^3*q2 - 3*q1^2*q2 + q2^3 + q2^2
        """
        if m == 0 or m == self._level:
            return self._poly.one()
        if m == 1:
            return self._poly.gen(self._Irev[a])

        cm = self._cm
        m -= 1 # So we don't have to do it everywhere

        cur = self._Q_poly(a, m) ** 2
        if self._twisted:
            ret = prod(self._Q_poly(b, m) ** -cm[self._Irev[b],self._Irev[a]]
                       for b in self._cm.dynkin_diagram().neighbors(a))
        else:
            ret = self._poly.one()
            i = self._Irev[a]
            for b in self._cm.dynkin_diagram().neighbors(a):
                j = self._Irev[b]
                for k in range(-cm[i,j]):
                    ret *= self._Q_poly(b, (m * cm[j,i] - k) // cm[i,j])
        cur -= ret
        if m > 1:
            cur //= self._Q_poly(a, m-1)
        return cur

    class Element(CombinatorialFreeModule.Element):
        """
        An element of a Q-system.
        """
        def _mul_(self, x):
            """
            Return the product of ``self`` and ``x``.

            EXAMPLES::

                sage: Q = QSystem(QQ, ['A',8])
                sage: x = Q.Q(1, 2)
                sage: y = Q.Q(3, 2)
                sage: x * y
                -Q^(1)[1]^2*Q^(2)[1]*Q^(4)[1] + Q^(1)[1]^2*Q^(3)[1]^2
                 + Q^(2)[1]^2*Q^(4)[1] - Q^(2)[1]*Q^(3)[1]^2
            """
            return self.parent().sum_of_terms((tl*tr, cl*cr)
                                              for tl,cl in self for tr,cr in x)


def is_tamely_laced(ct):
    r"""
    Check if the Cartan type ``ct`` is tamely-laced.

    A (symmetrizable) Cartan type with index set `I` is *tamely-laced*
    if `A_{ij} < -1` implies `d_i = -A_{ji} = 1` for all `i,j \in I`,
    where `(d_i)_{i \in I}` is the diagonal matrix symmetrizing the
    Cartan matrix `(A_{ij})_{i,j \in I}`.

    EXAMPLES::

        sage: from sage.algebras.q_system import is_tamely_laced
        sage: all(is_tamely_laced(ct)
        ....:     for ct in CartanType.samples(crystallographic=True, finite=True))
        True
        sage: for ct in CartanType.samples(crystallographic=True, affine=True):
        ....:     if not is_tamely_laced(ct):
        ....:         print(ct)
        ['A', 1, 1]
        ['BC', 1, 2]
        ['BC', 5, 2]
        ['BC', 1, 2]^*
        ['BC', 5, 2]^*
        sage: cm = CartanMatrix([[2,-1,0,0],[-3,2,-2,-2],[0,-1,2,-1],[0,-1,-1,2]])
        sage: is_tamely_laced(cm)
        True
    """
    if ct.is_finite():
        return True

    if ct.is_affine():
        return not (ct is CartanType(['A',1,1]) or
                    (ct.type() == 'BC' or ct.dual().type() == 'BC'))

    cm = ct.cartan_matrix()
    d = cm.symmetrizer()
    I = ct.index_set()
    return all(-cm[j,i] == 1 and d[i] == 1
               for i in I for j in I if cm[i,j] < -1)
