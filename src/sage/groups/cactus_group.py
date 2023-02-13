r"""
Cactus Groups

AUTHORS:

- Travis Scrimshaw (1-2023): initial version
"""

# ****************************************************************************
#       Copyright (C) 2023 Travis Scrimshaw <tcscrims at gmail.com>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from sage.misc.cachefunc import cached_method
from sage.misc.lazy_attribute import lazy_attribute
from sage.structure.element import MultiplicativeGroupElement, parent
from sage.structure.unique_representation import UniqueRepresentation
from sage.structure.richcmp import richcmp
from sage.matrix.constructor import matrix
from sage.categories.groups import Groups
from sage.groups.group import Group
from sage.groups.kernel_subgroup import KernelSubgroup
from sage.combinat.permutation import Permutations
from sage.sets.family import Family
from sage.graphs.graph import Graph
from itertools import combinations


class CactusGroup(UniqueRepresentation, Group):
    r"""
    The cactus group.

    The `n`-fruit cactus group `J_n` is the group generated by `s_{pq}`
    for `1 \leq p < q \leq n` with relations:

    - `s_{pq}^2 = 1`
    - `s_{pq} s_{kl} = s_{kl} s_{pq}` if the intervals `[p, q]` and `[k, l]`
      are disjoint, and
    - `s_{pq} s_{kl} = s_{p+q-l,p+q-k} s_{pq}` if `[k, l] \subseteq [p, q]`.

    INPUT:

    - ``n`` -- an integer

    EXAMPLES:

    We construct the cactus group `J_3` and do some basic computations::

        sage: J3 = groups.misc.Cactus(3)
        sage: s12,s13,s23 = J3.group_generators()
        sage: s12 * s13
        s[1,2]*s[1,3]
        sage: x = s12 * s23; x
        s[1,2]*s[2,3]
        sage: x^4
        s[1,2]*s[2,3]*s[1,2]*s[2,3]*s[1,2]*s[2,3]*s[1,2]*s[2,3]
        sage: s12 * s13 == s13 * s23
        True

    We verify the key equality in Lemma 2.3 in [White2015]_, which shows
    that `J_5` is generated by `s_{1q}`::

        sage: J5 = groups.misc.Cactus(5)
        sage: gens = J5.group_generators()
        sage: all(gens[(p,q)] == gens[(1,q)] * gens[(1,q-p+1)] * gens[(1,q)]
        ....:     for p in range(1, 6) for q in range(p+1, 6))
        True
    """
    def __init__(self, n):
        r"""
        Initialize ``self``.

        TESTS::

            sage: J3 = groups.misc.Cactus(3)
            sage: it = iter(J3)
            sage: elts = [next(it) for _ in range(100)]
            sage: TestSuite(J3).run(elements=elts[::7], skip="_test_enumerated_set_contains")

        We run this test separately because the words grow very long, very
        quickly. This means the code needs to check a lot of normalizations,
        so we limit the number of tests::

            sage: J3._test_enumerated_set_contains(max_runs=500)

        ::

            sage: J4 = groups.misc.Cactus(4)
            sage: it = iter(J4)
            sage: elts = [next(it) for _ in range(100)]
            sage: TestSuite(J4).run(elements=elts[::8])
        """
        self._n = n
        ell = len(str(n))
        names = ['s{}{}'.format('0' * (ell - len(str(i))) + str(i),
                                '0' * (ell - len(str(j))) + str(j))
                 for i in range(1, self._n + 1)
                 for j in range(i + 1, self._n + 1)]
        cat = Groups().FinitelyGeneratedAsMagma()
        if n > 2:
            cat = cat.Infinite()
        else:
            cat = cat.Finite()
        Group.__init__(self, category=cat)
        # Group.__init__ doesn't take a "names" parameter
        self._assign_names(names)

    @lazy_attribute
    def _WG(self):
        r"""
        Get the graph for the right-angled Coxeter group that ``self``
        embeds into (set theoretically) and set the ``_subsets`` and
        ``_subsets_inv`` attributes.

        We do this initialization lazily in order to make the creation of
        the parent quick. However, this is used to normalize the product
        of elements.

        EXAMPLES::

            sage: J4 = groups.misc.Cactus(4)
            sage: J4._WG
            Graph on 11 vertices
            sage: J4._subsets
            [frozenset({1, 2}), frozenset({1, 3}), frozenset({1, 4}), frozenset({2, 3}),
             frozenset({2, 4}), frozenset({3, 4}), frozenset({1, 2, 3}), frozenset({1, 2, 4}),
             frozenset({1, 3, 4}), frozenset({2, 3, 4}), frozenset({1, 2, 3, 4})]
        """
        n = self._n
        I = list(range(1, n+1))
        PS = sum(([frozenset(A) for A in combinations(I, k)] for k in range(2,n+1)), [])
        G = Graph([list(range(len(PS))),
                   [[i,j,-1] for j in range(1, len(PS)) for i in range(j)
                    if PS[i] & PS[j] not in [frozenset(), PS[i], PS[j]]]
                   ], format="vertices_and_edges")
        self._subsets = PS
        self._subsets_inv = {X: i for i,X in enumerate(PS)}
        return G

    def right_angled_coxeter_group(self):
        r"""
        Return the right-angled Coxeter group that ``self``
        (set-theoretically) embeds into.

        This is defined following [Most2019]_, where it was called the
        diagram group. It has generators (of order `2`) indexed by subsets
        of `\{1, \ldots, n\}` that commute if and only if one subset is
        contained in the other or they are disjoint. For the pure cactus
        group, this is also a group homomorphism, otherwise it is a
        group 1-cocycle [BCL2022]_.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.right_angled_coxeter_group()
            Coxeter group over Rational Field with Coxeter matrix:
            [ 1 -1 -1  2]
            [-1  1 -1  2]
            [-1 -1  1  2]
            [ 2  2  2  1]
        """
        from sage.rings.rational_field import QQ
        from sage.combinat.root_system.coxeter_group import CoxeterGroup
        from sage.combinat.root_system.coxeter_matrix import CoxeterMatrix
        return CoxeterGroup(CoxeterMatrix(self._WG), base_ring=QQ)

    def _repr_(self):
        """
        Return a string representation of ``self``.

        EXAMPLES::

            sage: groups.misc.Cactus(3)
            Cactus Group with 3 fruit
        """
        return "Cactus Group with {} fruit".format(self._n)

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: latex(J3)
            J_{3}
        """
        return "J_{{{}}}".format(self._n)

    def n(self):
        """
        Return the value `n`.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.n()
            3
        """
        return self._n

    @cached_method
    def group_generators(self):
        """
        Return the group generators of ``self``.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.group_generators()
            Finite family {(1, 2): s[1,2], (1, 3): s[1,3], (2, 3): s[2,3]}
        """
        l = [(i, j) for i in range(1, self._n + 1)
             for j in range(i + 1, self._n + 1)]
        return Family(l, lambda x: self.element_class(self, [x]))

    @cached_method
    def gens(self):
        """
        Return the generators of ``self`` as a tuple.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.gens()
            (s[1,2], s[1,3], s[2,3])
        """
        return tuple(self.group_generators())

    def gen(self, i, j=None):
        r"""
        Return the `i`-th generator of ``self`` or the generator `s_{ij}`.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.gen(1)
            s[1,3]
            sage: J3.gen(1,2)
            s[1,2]
            sage: J3.gen(0,2)
            Traceback (most recent call last):
            ...
            ValueError: s[0,2] is not a valid generator
            sage: J3.gen(1,4)
            Traceback (most recent call last):
            ...
            ValueError: s[1,4] is not a valid generator
            sage: J3.gen(2,1)
            Traceback (most recent call last):
            ...
            ValueError: s[2,1] is not a valid generator
        """
        if j is None:
            return self.gens()[i]
        if not (1 <= i < j <= self._n):
            raise ValueError(f"s[{i},{j}] is not a valid generator")
        return self.element_class(self, [(i,j)])

    @cached_method
    def one(self):
        r"""
        Return the identity element in ``self``.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.one()
            1
        """
        return self.element_class(self, [])

    def _coerce_map_from_(self, G):
        r"""
        Return if there is a coerce map from ``G``.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J5 = groups.misc.Cactus(5)
            sage: PJ3 = groups.misc.PureCactus(3)
            sage: PJ5 = groups.misc.PureCactus(5)

            sage: J3._coerce_map_from_(J5)
            False
            sage: J5._coerce_map_from_(J3)
            True
            sage: J3._coerce_map_from_(PJ3)
            True
            sage: J3._coerce_map_from_(PJ5)
            False
            sage: J5._coerce_map_from_(PJ3)
            True
            sage: J5._coerce_map_from_(PJ5)
            True
        """
        if isinstance(G, CactusGroup):
            return G._n <= self._n
        elif isinstance(G, PureCactusGroup):
            return G.n() <= self._n
        return super()._coerce_map_from_(G)

    def _element_constructor_(self, x):
        r"""
        Construct an element of ``self`` from ``x``.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J5 = groups.misc.Cactus(5)
            sage: PJ3 = groups.misc.PureCactus(3)

            sage: J5(J3.an_element())
            s[1,2]*s[2,3]*s[1,3]
            sage: J3(J5.an_element())
            s[1,2]*s[2,3]*s[1,3]
            sage: it = iter(PJ3)
            sage: [J3(next(it)) for _ in range(3)]
            [1, s[1,2]*s[2,3]*s[1,2]*s[1,3], s[2,3]*s[1,2]*s[2,3]*s[1,3]]

            sage: J3([[1,2], [1,3], [2,3]])
            s[1,3]
        """
        if parent(x) is self:
            return x
        if isinstance(x, PureCactusGroup.Element):
            x = x.value
        if isinstance(x, CactusGroup.Element):
            if any(d[1] > self._n for d in x._data):
                raise ValueError(f"{x} is not an element of {self}")
            return self.element_class(self, x._data)
        ret = self.element_class(self, x)
        ret._normalize()
        return ret

    def _an_element_(self):
        r"""
        Return an element of ``self``.

        TESTS::

            sage: J1 = groups.misc.Cactus(1)
            sage: J1._an_element_()
            1
            sage: J2 = groups.misc.Cactus(2)
            sage: J2._an_element_()
            s[1,2]
            sage: J3 = groups.misc.Cactus(3)
            sage: x = J3._an_element_(); x
            s[1,2]*s[2,3]*s[1,3]

            sage: x._normalize()
            sage: x
            s[1,2]*s[2,3]*s[1,3]
        """
        if self._n <= 1:
            return self.one()
        if self._n == 2:
            return self.element_class(self, [(1, 2)])
        return self.element_class(self, [(1, 2), (2, 3), (1, 3)])

    def random_element(self, max_length=10):
        r"""
        Return a random element of ``self`` of length at most ``max_length``.

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: J3.random_element()  # random
            s[1,2]*s[2,3]*s[1,2]*s[1,3]
        """
        from sage.misc.prandom import randint
        l = randint(0, max_length)
        gens = list(self.group_generators())
        ret = self.one()
        for _ in range(l):
            ret *= gens[randint(0, len(gens) - 1)]
        return ret

    def bilinear_form(self, t=None):
        r"""
        Return the ``t``-bilinear form of ``self``.

        We define a bilinear form `B` on the group algebra by

        .. MATH::

            B(s_{ij}, s_{pq}) = \begin{cases}
            1 & \text{if } i = p, j = q, \\
            -t & \text{if } [i, j] \not\subseteq [p, q] \text{ and }
            [p, q] \not\subseteq [i, j], \\
            0 & \text{otherwise}.
            \end{cases}

        In other words, it is `1` if `s_{ij} = s_{pq}`, `-t` if `s_{ij}`
        and `s_{pq}` generate a free group, and `0` otherwise (they commute
        or almost commute).

        INPUT:

        - ``t`` -- (default: `t` in `\ZZ[t]`) the variable `t`

        EXAMPLES::

            sage: J = groups.misc.Cactus(4)
            sage: B = J.bilinear_form()
            sage: B
            [ 1  0  0 -t -t  0]
            [ 0  1  0  0 -t -t]
            [ 0  0  1  0  0  0]
            [-t  0  0  1  0 -t]
            [-t -t  0  0  1  0]
            [ 0 -t  0 -t  0  1]

        We reorder the generators so the bilinear form is more
        "Coxeter-like". In particular, when we remove the generator
        `s_{1,4}`, we recover the bilinear form in Example 6.2.5
        of [DJS2003]_::

            sage: J.gens()
            (s[1,2], s[1,3], s[1,4], s[2,3], s[2,4], s[3,4])
            sage: S = SymmetricGroup(6)
            sage: g = S([1,4,6,2,5,3])
            sage: B.permute_rows_and_columns(g, g)
            sage: B
            [ 1 -t  0  0 -t  0]
            [-t  1 -t  0  0  0]
            [ 0 -t  1 -t  0  0]
            [ 0  0 -t  1 -t  0]
            [-t  0  0 -t  1  0]
            [ 0  0  0  0  0  1]
        """
        if t is None:
            from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
            from sage.rings.integer_ring import ZZ
            t = PolynomialRing(ZZ, 't').gen()
        R = t.parent()
        ret = []
        K = self.group_generators().keys()
        for x in K:
            for y in K:
                if x is y:
                    ret.append(R.one())
                elif (x[1] < y[0] or x[0] > y[1] or  # Disjoint
                      (x[0] <= y[0] and y[1] <= x[1]) or  # y <= x
                      (y[0] <= x[0] and x[1] <= y[1])):  # x <= y
                    ret.append(R.zero())
                else:
                    ret.append(-t)
        return matrix(R, len(K), len(K), ret)

    def geometric_representation_generators(self, t=None):
        r"""
        Return the matrices corresponding to the generators of ``self``.

        We construct a representation over `R = \ZZ[t]` of `J_n` as follows.
        Let `E` be the vector space over `R` spanned by `\{\epsilon_v\}_v`,
        where `v` is a generator of `J_n`. Fix some generator `v`, and
        let `E_v` denote the span of `\epsilon_u - \epsilon_{u'}`,
        where `u'` is the reflected interval of `u` in `v`, over all
        `u` such that `u \subset v`. Let `F_v` denote the orthogonal
        complement of `R \epsilon_v \oplus E_v` with respect to the
        :meth:`bilinear form <bilinear_form>` `B`. We define the action
        of `v` on `E` by

        .. MATH::

            \rho(v) = -I |_{R\epsilon_v \oplus E_v} \oplus I |_{F_v}.

        By Theorem 6.2.3 of [DJS2003]_, this defines a representation of `J_n`.
        It is expected that this is a faithful representation (see
        Remark 6.2.4 of [DJS2003]_). As this arises from a blow-up and an
        analog of the geometric representation of the corresponding
        Coxeter group (the symmetric group), we call this the
        *geometric representation*.

        INPUT:

        - ``t`` -- (default: `t` in `\ZZ[t]`) the variable `t`

        EXAMPLES::

            sage: J3 = groups.misc.Cactus(3)
            sage: list(J3.geometric_representation_generators())
            [
            [ -1   0 2*t]  [ 0  0  1]  [  1   0   0]
            [  0   1   0]  [ 0 -1  0]  [  0   1   0]
            [  0   0   1], [ 1  0  0], [2*t   0  -1]
            ]

        We ran the following code with ``max_tests = 15000`` and did
        not find a counterexample to the faithfulness of this representation::

            sage: visited = set([J3.one()])
            sage: cur = set([(J3.one(), J3.one().to_matrix())])
            sage: mats = set([J3.one().to_matrix()])
            sage: RG = list(J3.geometric_representation_generators())
            sage: count = 0
            sage: max_tests = 1000
            sage: while cur:
            ....:     count += 1
            ....:     if count >= max_tests:
            ....:         break
            ....:     elt, mat = cur.pop()
            ....:     for g,r in zip(J3, RG):
            ....:         val = elt * g
            ....:         if val in visited:
            ....:             continue
            ....:         visited.add(val)
            ....:         matp = mat * r
            ....:         matp.set_immutable()
            ....:         assert matp not in mats, f"not injective {val} \n{matp}"
            ....:         mats.add(matp)
            ....:         cur.add((val, matp))
        """
        B = self.bilinear_form(t)
        F = B.base_ring().fraction_field()
        K = self.group_generators().keys()
        from sage.modules.free_module import FreeModule
        V = FreeModule(F, len(K))
        basis = V.basis()
        ret = {}
        for ik, k in enumerate(K):
            E = [basis[ik]]
            ME = matrix(E)
            # The only non-trivial elements are those reflected by the interval k
            for low in range(k[0], k[1] + 1):
                for high in range(low + 1, k[1] + 1):
                    v = (low, high)
                    vp = (k[0] + k[1] - high, k[0] + k[1] - low)
                    if v == vp:
                        continue
                    elt = basis[K.index(v)] - basis[K.index(vp)]
                    if elt not in ME.row_space():
                        E.append(elt)
                        ME = ME.stack(elt)
            # Get the orthogonal complement wrt to the bilinear form B
            Fv = (ME * B).right_kernel().basis_matrix()
            T = ME.stack(Fv).transpose()
            rho = matrix.diagonal(F, [-1] * len(E) + [1] * (len(K) - len(E)))
            ret[k] = T * rho * ~T
        return Family(K, lambda k: ret[k])

    class Element(MultiplicativeGroupElement):
        """
        An element of a cactus group.
        """
        def __init__(self, parent, data):
            """
            Initialize ``self``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: elt = J3.an_element()
                sage: TestSuite(elt).run()
            """
            self._data = tuple(data)
            MultiplicativeGroupElement.__init__(self, parent)

        def _repr_(self):
            """
            Return a string representation of ``self``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: J3.one()
                1
                sage: J3.an_element()
                s[1,2]*s[2,3]*s[1,3]
            """
            if not self._data:
                return '1'
            return '*'.join(f"s[{i},{j}]" for i,j in self._data)

        def _latex_(self):
            """
            Return a latex representation of ``self``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: latex(J3.one())
                1
                sage: latex(J3.an_element())
                s_{1,2} s_{2,3} s_{1,3}
            """
            if not self._data:
                return '1'
            return " ".join(f"s_{{{i},{j}}}" for i,j in self._data)

        def _unicode_art_(self):
            """
            Return unicode art of ``self``.

            EXAMPLES::

                sage: J4 = groups.misc.Cactus(4)
                sage: s12,s13,s14,s23,s24,s34 = J4.gens()
                sage: unicode_art(s12 * s23 * s13)
                s₁₂ s₂₃ s₁₃
                sage: unicode_art(J4.one())
                1
                sage: J12 = groups.misc.Cactus(12)
                sage: unicode_art(J12.gen(1,3))
                s₁,₃
                sage: unicode_art(J12.gen(3,11))
                s₃,₁₁
            """
            from sage.typeset.unicode_art import unicode_subscript, unicode_art
            if not self._data:
                return unicode_art('1')
            if self.parent()._n < 10:
                return unicode_art(' '.join('s{}{}'.format(unicode_subscript(p), unicode_subscript(q)) for p,q in self._data))
            return unicode_art(' '.join('s{},{}'.format(unicode_subscript(p), unicode_subscript(q)) for p,q in self._data))

        def __hash__(self):
            r"""
            Return the hash of ``self``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: elt = J3.gen(1,2) * J3.gen(2,3) * J3.gen(1,3)
                sage: hash(elt) == hash((((1,2), (2,3), (1,3))))
                True
            """
            return hash(self._data)

        def _richcmp_(self, other, op):
            r"""
            Compare ``self`` and ``other``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: elt = J3.an_element()
                sage: elt == J3.one()
                False
                sage: elt != J3.one()
                True
                sage: s12,s13,s23 = J3.gens()
                sage: elt == s12*s23*s13
                True
            """
            return richcmp(self._data, other._data, op)

        def _mul_(self, other):
            r"""
            Return the product of ``self`` and ``other``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: s12,s13,s23 = J3.gens()
                sage: s12*s23
                s[1,2]*s[2,3]
                sage: s12*s13
                s[1,2]*s[1,3]
                sage: s13*s12
                s[2,3]*s[1,3]
                sage: J3.one() * (s13*s12*s13*s12*s23*s13)
                s[2,3]*s[1,2]*s[2,3]*s[1,3]
            """
            ret = type(self)(self.parent(), self._data + other._data)
            ret._normalize()
            return ret

        def __invert__(self):
            r"""
            Return the inverse of ``self``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: s12,s13,s23 = J3.gens()
                sage: elt = s12*s23*s13
                sage: ~elt
                s[1,2]*s[2,3]*s[1,3]
                sage: elt * elt
                1
            """
            ret = type(self)(self.parent(), reversed(self._data))
            ret._normalize()
            return ret

        def to_permutation(self):
            r"""
            Return the image of ``self`` under the canonical projection
            to the permutation group.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: s12,s13,s23 = J3.gens()
                sage: s12.to_permutation()
                [2, 1, 3]
                sage: s23.to_permutation()
                [1, 3, 2]
                sage: s13.to_permutation()
                [3, 2, 1]
                sage: elt = s12*s23*s13
                sage: elt.to_permutation()
                [1, 3, 2]

                sage: J7 = groups.misc.Cactus(7)
                sage: J7.group_generators()[3,6].to_permutation()
                [1, 2, 6, 5, 4, 3, 7]

            We check that this respects the multiplication order
            of permutations::

                sage: P3 = Permutations(3)
                sage: elt = s12*s23
                sage: elt.to_permutation() == P3(s12) * P3(s23)
                True
                sage: Permutations.options.mult='r2l'
                sage: elt.to_permutation() == P3(s12) * P3(s23)
                True
                sage: Permutations.options.mult='l2r'
            """
            n = self.parent().n()
            P = Permutations(n)
            ret = P.one()
            for x in self._data:
                lst = list(range(1, n + 1))
                lst[x[0] - 1:x[1]] = list(reversed(lst[x[0] - 1:x[1]]))
                ret *= P(lst)
            return ret

        def _matrix_(self):
            r"""
            Return ``self`` as a matrix.

            The resulting matrix is the :meth:`geometric representation
            <sage.groups.cactus_group.CactusGroup.geometric_representation_generators>`
            of ``self``.

            EXAMPLES::

                sage: J3 = groups.misc.Cactus(3)
                sage: s12,s13,s23 = J3.gens()
                sage: s12.to_matrix()
                [ -1   0 2*t]
                [  0   1   0]
                [  0   0   1]
                sage: (s12*s13).to_matrix()
                [2*t   0  -1]
                [  0  -1   0]
                [  1   0   0]
                sage: (s13*s23).to_matrix()
                [2*t   0  -1]
                [  0  -1   0]
                [  1   0   0]
                sage: (s13*s12).to_matrix()
                [  0   0   1]
                [  0  -1   0]
                [ -1   0 2*t]
                sage: all(x.to_matrix() * y.to_matrix() == (x*y).to_matrix()
                ....:     for x in J3.gens() for y in J3.gens())
                True
            """
            G = self.parent().geometric_representation_generators()
            ret = G[(1,2)].parent().one()
            for x in self._data:
                ret *= G[x]
            ret.set_immutable()
            return ret

        to_matrix = _matrix_

        def _normalize(self):
            r"""
            Return the word for ``self`` in normalized form.

            ALGORITHM:

            We perform the normalization by using the lexicographically
            minimum reduced word for the corresponding right-angled Coxeter
            group (RACG) element under the (set-theoretic) embedding
            introduced by [Most2019]_. This embedding is a group 1-cocycle
            and also realizes the cactus group as a subgroup of `W \rtimes S_n`,
            where `W` is the RACG (see also [Yu2022]_). See Section 2
            of [BCL2022]_ for precise statements.

            TESTS::

                sage: J6 = groups.misc.Cactus(6)
                sage: s26 = J6.gen(2,6)
                sage: s45 = J6.gen(4,5)
                sage: s13 = J6.gen(1,3)
                sage: s26 * s45 * s13 == s26 * s45 * s13  # indirect doctest
                True

                sage: J4 = groups.misc.Cactus(4)
                sage: s12,s13,s14,s23,s24,s34 = J4.gens()
                sage: s12 * (s12 * s23)
                s[2,3]
                sage: (s12 * s23) * s23
                s[1,2]
                sage: s23 * s13 * s34
                s[2,3]*s[1,3]*s[3,4]
            """
            P = self.parent()
            n = P._n
            G = P._WG  # The defining graph

            # Convert to an element in the right-angled Coxeter group
            perm = list(range(1,n+1))
            word = []
            for p,q in self._data:
                word.append(P._subsets_inv[frozenset(perm[p-1:q])])
                perm[p-1:q] = reversed(perm[p-1:q])

            # Normalize the word
            # This code works for any right-angled Coxeter group
            pos = 0
            supp = sorted(set(word))
            while pos < len(word) - 1:
                cur = word[pos]
                for i in supp:
                    if i > cur:
                        break
                    if G.has_edge(cur, i):
                        continue
                    did_swap = False
                    for j in range(pos+1, len(word)):
                        if word[j] == i:
                            word.pop(j)
                            if cur == i:  # canceling s_i s_i = 1
                                word.pop(pos)
                                pos = -1  # start again at the beginning
                                break
                            word.insert(pos, i)
                            did_swap = True
                            break
                        if G.has_edge(i, word[j]):
                            break
                    if did_swap:
                        break
                pos += 1

            # Convert back
            ret = []
            perm = list(range(1,n+1))
            for i in word:
                X = P._subsets[i]
                pos = [j for j,val in enumerate(perm) if val in X]
                for j in range(len(pos)//2):
                    perm[pos[j]], perm[pos[-j-1]] = perm[pos[-j-1]], perm[pos[j]]
                pos.sort()
                assert all(pos[k] + 1 == pos[k+1] for k in range(len(pos)-1))
                ret.append((pos[0]+1, pos[-1]+1))

            self._data = tuple(ret)


class PureCactusGroup(KernelSubgroup):
    r"""
    The pure cactus group.

    The *pure cactus group* `PJ_n` is the kernel of the natural
    surjection of the cactus group `J_n` onto the symmetric group
    `S_n`. In particular, we have the following (non-split) exact sequence:

    .. MATH::

        1 \longrightarrow PJ_n \longrightarrow J_n \longrightarrow S_n
        \longrightarrow 1.
    """
    def __init__(self, n):
        r"""
        Initialize ``self``.

        EXAMPLES::

            sage: PJ3 = groups.misc.PureCactus(3)
            sage: it = iter(PJ3)
            sage: elts = [next(it) for _ in range(10)]
            sage: TestSuite(PJ3).run(elements=elts)
        """
        J = CactusGroup(n)
        from sage.groups.perm_gps.permgroup_named import SymmetricGroup
        S = SymmetricGroup(n)
        KernelSubgroup.__init__(self, S.coerce_map_from(J))

    def _repr_(self):
        """
        Return a string representation of ``self``.

        EXAMPLES::

            sage: groups.misc.PureCactus(3)
            Pure Cactus Group with 3 fruit
        """
        return "Pure Cactus Group with {} fruit".format(self.n())

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: PJ3 = groups.misc.PureCactus(3)
            sage: latex(PJ3)
            PJ_{3}
        """
        return "PJ_{{{}}}".format(self.n())

    @cached_method
    def n(self):
        """
        Return the value `n`.

        EXAMPLES::

            sage: PJ3 = groups.misc.PureCactus(3)
            sage: PJ3.n()
            3
        """
        return self.ambient().n()

    def gen(self, i):
        r"""
        Return the ``i``-th generator of ``self``.

        EXAMPLES::

            sage: PJ3 = groups.misc.PureCactus(3)
            sage: PJ3.gen(0)
            s[2,3]*s[1,2]*s[2,3]*s[1,3]
            sage: PJ3.gen(1)
            s[1,2]*s[2,3]*s[1,2]*s[1,3]
            sage: PJ3.gen(5)
            Traceback (most recent call last):
            ...
            IndexError: tuple index out of range
        """
        return self.gens()[i]

    @cached_method
    def gens(self):
        r"""
        Return the generators of ``self``.

        ALGORITHM:

        We use :wikipedia:`Schreier's_lemma` and compute the traversal
        using the lex minimum elements (defined by the order of the
        generators of the ambient cactus group).

        EXAMPLES:

        We verify Corollary A.2 of [BCL2022]_::

            sage: PJ3 = groups.misc.PureCactus(3)
            sage: PJ3.gens()
            (s[2,3]*s[1,2]*s[2,3]*s[1,3], s[1,2]*s[2,3]*s[1,2]*s[1,3])
            sage: a, b = PJ3.gens()
            sage: a * b  # they are inverses of each other
            1

            sage: J3 = groups.misc.Cactus(3)
            sage: gen = (J3.gen(1,2)*J3.gen(1,3))^3
            sage: gen
            s[1,2]*s[2,3]*s[1,2]*s[1,3]
            sage: gen == b
            True
        """
        from sage.functions.other import factorial
        J = self.ambient()
        G = J.gens()
        one = J.one()
        n = self.n()
        nfac = factorial(n)
        reprs = {one.to_permutation(): one}
        next_level = [one]
        while len(reprs) < nfac:
            cur = next_level
            next_level = []
            for val in cur:
                for g in G:
                    temp = val * g
                    p = temp.to_permutation()
                    if p in reprs:
                        continue
                    reprs[p] = temp
                    next_level.append(temp)
        gens = []
        for s in reprs.values():
            for g in G:
                val = s * g * ~(reprs[(s*g).to_permutation()])
                if val == one or val in gens:
                    continue
                gens.append(val)
        return tuple([self(g) for g in gens])

