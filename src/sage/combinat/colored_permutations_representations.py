# sage_setup: distribution = sagemath-combinat
# sage.doctest: needs sage.groups sage.modules
r"""
Colored permutations: conjugacy classes, representation theory
"""

from sage.combinat.free_module import CombinatorialFreeModule
from sage.combinat.partition_tuple import PartitionTuples
from sage.combinat.specht_module import SpechtModule as SymGroupSpechtModule
from sage.groups.conjugacy_classes import ConjugacyClass
from sage.matrix.constructor import matrix, diagonal_matrix
from sage.misc.cachefunc import cached_method
from sage.misc.lazy_attribute import lazy_attribute
from sage.modules.with_basis.subquotient import SubmoduleWithBasis, QuotientModuleWithBasis
from sage.modules.with_basis.representation import Representation_abstract
from sage.structure.element import parent


# ===================================================================
# Conjucacy classes


class SignedPermutationGroupConjugacyClass(ConjugacyClass):
    r"""
    A conjugacy class of the signed permutations of `n`.

    INPUT:

    - ``group`` -- the signed permutations of `n`
    - ``shape`` -- a pair of partitions or an element of ``group``
    """
    def __init__(self, group, shape):
        """
        Initialize ``self``.

        EXAMPLES::

            sage: G = SignedPermutations(4)
            sage: C = G.conjugacy_class([[1], [2,1]])
            sage: TestSuite(C).run()
        """
        if parent(shape) is group:
            shape = shape.cycle_type()
        self._group = group
        P = PartitionTuples(2, group._n)
        self._shape = P(shape)
        self._set = None
        rep = self._group.conjugacy_class_representative(self._shape)
        ConjugacyClass.__init__(self, group, rep)

    def _repr_(self):
        r"""
        Return a string representation of ``self``.

        EXAMPLES::

            sage: G = SignedPermutations(4)
            sage: G.conjugacy_class([[3], [1]])
            Conjugacy class of cycle type ([3], [1]) in Signed permutations of 4
        """
        return "Conjugacy class of cycle type %s in %s" % (self._shape, self._group)

    def __eq__(self, other):
        r"""
        Comparison of conjugacy classes is done by comparing the
        defining cycle types.

        EXAMPLES::

            sage: G = SignedPermutations(4)
            sage: C = G.conjugacy_class([[3], [1]])
            sage: Cp = G.conjugacy_class(G([2,4,-3,1]))
            sage: C == Cp
            True
        """
        if not isinstance(other, SignedPermutationGroupConjugacyClass):
            return False
        return self._shape == other._shape

    def shape(self):
        r"""
        Return the shape of ``self``.

        EXAMPLES::

            sage: G = SignedPermutations(4)
            sage: C = G.conjugacy_class(G([-3,2,-4,1]))
            sage: C.shape()
            ([3, 1], [])
        """
        return self._shape


# ===================================================================
# Representation theory


class TabloidModule(Representation_abstract, CombinatorialFreeModule):
    r"""
    The vector space of all tabloids of a fixed shape with the natural
    signed permutation group action.

    A *tabloid* of size `n` is a pair of sequences sets `(S, T)` such that:

    - For all `X, Y \in S \cup T`, we have `X \cap Y = \emptyset`
      (all sets are pairwise disjoint).
    - `\sum_{X \in S \cup T} |X| = n`.
    - `\bigsqcup_{X\subseteq S \cup T} X \sqcup \overline{X} = \{1, \ldots,
      n, \overline{1} \ldots, \overline{n}\}`.

    The signed permutation group acts naturally on the entries of each set.
    Hence, this is a representation of the signed permutation group
    defined over any field.

    EXAMPLES::

        sage: B4 = SignedPermutations(4)
        sage: la = [1]
        sage: mu = [2, 1]

        sage: TM = B4.tabloid_module([la, mu], QQ)
        sage: TM.dimension()
        24
        sage: chi = TM.character(); chi
        (0, 0, 0, 4, 24, 0, 2, 18, 0, 0, 4, 12, 0, 2, 6, 0, 0, 0, 0, 0)

    We show how to compute the decomposition into irreducibles (it takes some
    time to generate the character table this way though)::

        sage: chartab = matrix([B4.specht_module(la, QQ).character()  # not tested
        ....:                   for la in PartitionTuples(2,4)])
        sage: chi * ~chartab  # not tested
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 2, 1, 1, 0)

    We now do some computations for the modular representation theory::

        sage: TM = B4.tabloid_module([la, mu], GF(3))
        sage: TM.brauer_character()
        (0, 0, 4, 24, 2, 18, 0, 0, 4, 12, 2, 6, 0, 0, 0, 0)
        sage: IM = TM.invariant_module()
        sage: IM.dimension()  # long time
        1
        sage: IM.basis()[0].lift() == sum(TM.basis())
        True

    We verify the dimension is `2^{|\lambda|} \frac{n!}{
    \lambda_1! \cdots \lambda_{\ell}! \mu_1! \cdots \mu_m!}`::

        sage: TM.dimension() == (2^sum(la) * factorial(4)
        ....:                    / prod(factorial(lai) for lai in la)
        ....:                    / prod(factorial(mui) for mui in mu))
        True

    We can see that the tabloid module is not symmetric with swapping
    `\lambda \leftrightarrow \mu`::

        sage: TMp = B4.tabloid_module([mu, la], GF(3))
        sage: TMp.dimension()
        96
        sage: TMp.dimension() == (2^sum(mu) * factorial(4)
        ....:                    / prod(factorial(mui) for mui in mu)
        ....:                    / prod(factorial(lai) for lai in la))
        True

    REFERENCES:

    - [Morris1981]_
    """
    @staticmethod
    def __classcall_private__(cls, G, base_ring, diagram):
        r"""
        Normalize input to ensure a unique representation.

        EXAMPLES::

            sage: from sage.combinat.colored_permutations_representations import TabloidModule
            sage: B4 = SignedPermutations(4)
            sage: TM1 = TabloidModule(B4, QQ, [[], [2,2]])
            sage: TM2 = TabloidModule(B4, QQ, PartitionTuple([[], [2, 2]]))
            sage: TM1 is TM2
            True

            sage: TabloidModule(B4, QQ, [[], [2,1]])
            Traceback (most recent call last):
            ...
            ValueError: [[], [2, 1]] is not a Partition tuples of level 2 and size 4
        """
        diagram = PartitionTuples(2, G._n)(diagram)
        return super().__classcall__(cls, G, base_ring, diagram)

    def __init__(self, G, base_ring, diagram):
        r"""
        Initialize ``self``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[1],[2,2]], GF(5))
            sage: TestSuite(TM).run()
        """
        self._diagram = diagram
        from sage.categories.modules_with_basis import ModulesWithBasis
        cat = ModulesWithBasis(base_ring).FiniteDimensional()

        # Build the tabloids
        from sage.sets.disjoint_union_enumerated_sets import DisjointUnionEnumeratedSets
        from sage.combinat.set_partition_ordered import OrderedSetPartitions
        from sage.categories.sets_cat import cartesian_product
        from itertools import product
        la, mu = self._diagram
        data = [cartesian_product([OrderedSetPartitions([val * x for x, val in zip(sorted(X), signs)], la),
                                   OrderedSetPartitions(sorted(Y), mu)])
                for (X, Y) in OrderedSetPartitions(G._n, [sum(la), sum(mu)])
                for signs in product([1,-1], repeat=sum(la))]
        tabloids = DisjointUnionEnumeratedSets(data)
        tabloids.rename(f"Tabloids of shape {self._diagram}")

        CombinatorialFreeModule.__init__(self, base_ring, tabloids,
                                         category=cat, prefix='T', bracket='')
        Representation_abstract.__init__(self, G, "left")

    def _repr_(self):
        r"""
        Return a string representation of ``self``.

        EXAMPLES::

            sage: B7 = SignedPermutations(7)
            sage: B7.tabloid_module([[3,1],[2,1]], GF(3))
            Tabloid module of ([3, 1], [2, 1]) over Finite Field of size 3
        """
        return f"Tabloid module of {self._diagram} over {self.base_ring()}"

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: TM = B4.tabloid_module([[2,1],[1]], GF(3))
            sage: latex(TM)
            T^{{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{\phantom{x}}&\lr{\phantom{x}}\\\cline{1-2}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            },{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            }}
        """
        from sage.misc.latex import latex
        return "T^{" + ",".join(latex(la) for la in self._diagram) + "}"

    def _ascii_art_term(self, TP):
        r"""
        Return an ascii art representation of the term indexed by ``T``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[2,1], [1,1]], QQ)
            sage: ascii_art(TM.an_element())  # indirect doctest
            2*T            + 2*T            + 3*T
               {1, 2}  {4}      {1, 2}  {5}      {1, 3}  {4}
               {3}   , {5}      {3}   , {4}      {2}   , {5}
        """
        # This is basically copied from CombinatorialFreeModule._ascii_art_term
        from sage.typeset.ascii_art import AsciiArt, ascii_art
        pref = AsciiArt([self.prefix()])
        data = []
        for T in TP:
            tab = "\n".join("{" + ", ".join(str(val) for val in sorted(row)) + "}" for row in T)
            if not tab:
                tab = '-'
            data.append(tab)
        r = pref * (AsciiArt([" " * len(pref)]) + ascii_art(data[0]) + ascii_art(', ') + ascii_art(data[1]))
        r._baseline = r._h - 1
        return r

    def _unicode_art_term(self, T):
        r"""
        Return a unicode art representation of the term indexed by ``T``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[2,1], [1,1]], QQ)
            sage: unicode_art(TM.an_element())  # indirect doctest
            2*T            + 2*T            + 3*T
               {1, 2}  {4}      {1, 2}  {5}      {1, 3}  {4}
               {3}   , {5}      {3}   , {4}      {2}   , {5}
        """
        from sage.typeset.unicode_art import unicode_art
        r = unicode_art(repr(self._ascii_art_term(T)))
        r._baseline = r._h - 1
        return r

    def _latex_term(self, TP):
        r"""
        Return a latex representation of the term indexed by ``T``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[2,1], [1,1]], QQ)
            sage: latex(TM.an_element())  # indirect doctest
            2 T_{{\def\lr#1{\multicolumn{1}{@{\hspace{.6ex}}c@{\hspace{.6ex}}}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{1}&\lr{2}\\\cline{1-2}
            \lr{3}\\\cline{1-1}
            \end{array}$}
            }, {\def\lr#1{\multicolumn{1}{@{\hspace{.6ex}}c@{\hspace{.6ex}}}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{4}\\\cline{1-1}
            \lr{5}\\\cline{1-1}
            \end{array}$}
            }} + 2 T_{{\def\lr#1{\multicolumn{1}{@{\hspace{.6ex}}c@{\hspace{.6ex}}}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{1}&\lr{2}\\\cline{1-2}
            \lr{3}\\\cline{1-1}
            \end{array}$}
            }, {\def\lr#1{\multicolumn{1}{@{\hspace{.6ex}}c@{\hspace{.6ex}}}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{5}\\\cline{1-1}
            \lr{4}\\\cline{1-1}
            \end{array}$}
            }} + 3 T_{{\def\lr#1{\multicolumn{1}{@{\hspace{.6ex}}c@{\hspace{.6ex}}}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{1}&\lr{3}\\\cline{1-2}
            \lr{2}\\\cline{1-1}
            \end{array}$}
            }, {\def\lr#1{\multicolumn{1}{@{\hspace{.6ex}}c@{\hspace{.6ex}}}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{4}\\\cline{1-1}
            \lr{5}\\\cline{1-1}
            \end{array}$}
            }}
        """
        data = []
        import re
        for T in TP:
            if not T:
                tab = "\\emptyset"
            else:
                from sage.combinat.output import tex_from_array
                A = list(map(sorted, T))
                tab = str(tex_from_array(A))
                tab = tab.replace("|", "")
                # Replace -i with \overline{i} in boxes
                tab = re.sub(r"\\lr{-([0-9]+)}", r"\\lr{\\overline{\1}}", tab)
            data.append(tab)
        return f"{self.prefix()}_{{{data[0]}, {data[1]}}}"

    def _semigroup_basis_action(self, g, T):
        """
        Return the action of the symmetric group element ``g`` on the
        tabloid ``T``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[2,1], [1,1]], QQ)
            sage: tab = TM._indices([[[1,4],[3]], [[5],[2]]])
            sage: g = B5.an_element(); g
            [-5, 1, 2, 3, 4]
            sage: TM._semigroup_basis_action(g, tab)
            ([{-5, 3}, {2}], [{4}, {1}])
        """
        P = self._indices
        U = [[g(val) for val in row] for row in T[0]]
        V = [[abs(g(val)) for val in row] for row in T[1]]
        return P([U, V])

    def _semigroup_action(self, g, vec, vec_on_left):
        r"""
        Return the action of the symmetric group element ``g`` on the
        vector ``vec``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[2,1], [1,1]], QQ)
            sage: vec = TM.an_element(); vec
            2*T([{1, 2}, {3}], [{4}, {5}]) + 2*T([{1, 2}, {3}], [{5}, {4}])
             + 3*T([{1, 3}, {2}], [{4}, {5}])
            sage: g = prod(B5.gens()); g
            [-5, 1, 2, 3, 4]
            sage: TM._semigroup_action(g, vec, True)
            2*T([{2, 3}, {4}], [{5}, {1}]) + 2*T([{2, 3}, {4}], [{1}, {5}])
             + 3*T([{2, 4}, {3}], [{5}, {1}])
            sage: TM._semigroup_action(g, vec, False)
            2*T([{-5, 1}, {2}], [{3}, {4}]) + 2*T([{-5, 1}, {2}], [{4}, {3}])
             + 3*T([{-5, 2}, {1}], [{3}, {4}])
        """
        if self._left_repr == vec_on_left:
            g = ~g
        return self.sum_of_terms((self._semigroup_basis_action(g, T), c)
                                 for T, c in vec._monomial_coefficients.items())

    def specht_module(self):
        r"""
        Return the Specht submodule of ``self``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: TM = B5.tabloid_module([[2], [2,1]], QQ)
            sage: TM.specht_module() is B5.specht_module([[2], [2,1]], QQ)
            True
        """
        return SpechtModule(self)

    def bilinear_form(self, u, v):
        r"""
        Return the natural bilinear form of ``self`` applied to ``u`` and ``v``.

        The natural bilinear form is given by defining the tabloid basis
        to be orthonormal.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: TM = B4.tabloid_module([[2], [1,1]], QQ)
            sage: u = TM.an_element(); u
            2*T([{1, 2}], [{3}, {4}]) + 2*T([{1, 2}], [{4}, {3}])
             + 3*T([{-2, 1}], [{3}, {4}])
            sage: v = sum(TM.basis())
            sage: TM.bilinear_form(u, v)
            7
            sage: TM.bilinear_form(u, TM.zero())
            0
        """
        if len(v) < len(u):
            u, v = v, u
        R = self.base_ring()
        return R.sum(c * v[T] for T, c in u)


class SpechtModule(Representation_abstract, SubmoduleWithBasis):
    r"""
    A Specht module of a type `B_n` Coxeter group in the classical standard
    tableau pair basis.

    This is constructed as a `B_n`-submodule of the :class:`TabloidModule`
    (also referred to as the standard module) using the polytabloid elements
    associated to the standard tableaux of shape `(\lambda, \mu)`.

    We verify the set of 2-regular partitions for `n = 4`::

        sage: B4 = SignedPermutations(4)
        sage: for la in PartitionTuples(2, 4):  # long time
        ....:     SM = B4.specht_module(la, GF(3))
        ....:     if SM.gram_matrix():
        ....:         print(la)
        ([4], [])
        ([3, 1], [])
        ([2, 2], [])
        ([2, 1, 1], [])
        ([3], [1])
        ([2, 1], [1])
        ([2], [2])
        ([2], [1, 1])
        ([1, 1], [2])
        ([1, 1], [1, 1])
        ([1], [3])
        ([1], [2, 1])
        ([], [4])
        ([], [3, 1])
        ([], [2, 2])
        ([], [2, 1, 1])
        sage: for la in PartitionTuples(2, 4):  # long time
        ....:     SM = B4.specht_module(la, GF(2))
        ....:     if SM.gram_matrix():
        ....:         print(la)
        ([], [4])
        ([], [3, 1])

    REFERENCES:

    - [Morris1981]_
    """
    def __init__(self, ambient):
        r"""
        Initialize ``self``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: SM = B5.specht_module([[1,1], [2,1]], GF(3))
            sage: TestSuite(SM).run()
            sage: SM = B5.specht_module([[2], [2,1]], QQ)
            sage: TestSuite(SM).run()
        """
        Representation_abstract.__init__(self, ambient._semigroup, ambient._side,
                                         algebra=ambient._semigroup_algebra)
        self._diagram = ambient._diagram

        ambient_basis = ambient.basis()
        tabloids = ambient_basis.keys()
        support_order = list(tabloids)
        from itertools import product

        def elt(T):
            tab = tabloids(list(T))

            def group_elements(sigma):
                mu_vals = set(sum((row for row in T[1]), ()))
                n = T.size()
                for sigma in T.column_stabilizer():
                    sigma = sigma.tuple()
                    for signs in product(*[[1,-1] if i not in mu_vals else [1]
                                           for i in range(1,n+1)]):
                        yield self._semigroup([s * val for s, val in zip(signs, sigma)])

            return ambient.sum_of_terms((ambient._semigroup_basis_action(elt, tab),
                                         1 - 2*(elt.length() % 2))  # == (-1)**elt.length()
                                        for elt in group_elements(T))

        from sage.sets.family import Family
        basis = Family({T: elt(T)
                        for T in self._diagram.standard_tableaux()})
        cat = ambient.category().Subobjects()
        SubmoduleWithBasis.__init__(self, basis, support_order, ambient=ambient,
                                    unitriangular=False, category=cat,
                                    prefix='S', bracket='')

    def _repr_(self):
        """
        Return a string representation of ``self``.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: B5.specht_module([[1,1], [2,1]], GF(3))
            Specht module of shape ([1, 1], [2, 1]) over Finite Field of size 3
        """
        return "Specht module of shape {} over {}".format(self._diagram, self.base_ring())

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: latex(B4.specht_module([[2,1],[1]], GF(3)))
            S^{{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{\phantom{x}}&\lr{\phantom{x}}\\\cline{1-2}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            },{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            }}
        """
        from sage.misc.latex import latex
        return "S^{" + ",".join(latex(la) for la in self._diagram) + "}"

    @lazy_attribute
    def lift(self):
        r"""
        The lift (embedding) map from ``self`` to the ambient space.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: SM = B4.specht_module([[1], [2,1]], QQ)
            sage: SM.lift
            Generic morphism:
              From: Specht module of shape ([1], [2, 1]) over Rational Field
              To:   Tabloid module of ([1], [2, 1]) over Rational Field
        """
        return self.module_morphism(self.lift_on_basis, codomain=self.ambient())

    @lazy_attribute
    def retract(self):
        r"""
        The retract map from the ambient space.

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: X = B5.tabloid_module([[2,1], [2]], QQ)
            sage: Y = X.specht_module()
            sage: Y.retract
            Generic morphism:
              From: Tabloid module of ([2, 1], [2]) over Rational Field
              To:   Specht module of shape ([2, 1], [2]) over Rational Field
            sage: all(Y.retract(u.lift()) == u for u in Y.basis())
            True

            sage: Y.retract(X.zero())
            0
            sage: Y.retract(sum(X.basis()))
            Traceback (most recent call last):
            ...
            ValueError: ... is not in the image
        """
        B = self.basis()
        COB = matrix([b.lift().to_vector() for b in B]).T
        P, L, U = COB.LU()
        # Since U is upper triangular, the nonzero entriesm must be in the
        #   upper square portiion of the matrix
        n = len(B)

        Uinv = U.matrix_from_rows(range(n)).inverse()
        # This is a slight abuse as the codomain should be a module with a different
        #    S_n action, but we only use it internally, so there isn't any problems
        PLinv = (P*L).inverse()

        def retraction(elt):
            vec = PLinv * elt.to_vector(order=self._support_order)
            if not vec:
                return self.zero()
            # vec is now in the image of self under U, which is
            if max(vec.support()) >= n:
                raise ValueError(f"{elt} is not in the image")
            return self._from_dict(dict(zip(B.keys(), Uinv * vec[:n])))

        return self._ambient.module_morphism(function=retraction, codomain=self)

    def bilinear_form(self, u, v):
        r"""
        Return the natural bilinear form of ``self`` applied to ``u`` and ``v``.

        The natural bilinear form is given by the pullback of the natural
        bilinear form on the tabloid module (where the tabloid basis is an
        orthonormal basis).

        EXAMPLES::

            sage: B5 = SignedPermutations(5)
            sage: SM = B5.specht_module([[1], [2,2]], QQ)
            sage: u = SM.an_element(); u
            2*S([[1]], [[2, 3], [4, 5]]) + 2*S([[2]], [[1, 3], [4, 5]])
             + 3*S([[3]], [[1, 2], [4, 5]])
            sage: v = sum(SM.basis())
            sage: SM.bilinear_form(u, v)
            84
        """
        TM = self._ambient
        return TM.bilinear_form(u.lift(), v.lift())

    @cached_method
    def gram_matrix(self):
        r"""
        Return the Gram matrix of the natural bilinear form of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: SM = B4.specht_module([[2,1], [1]], QQ)
            sage: M = SM.gram_matrix(); M
            [16  8  0  0  0  0  0  0]
            [ 8 16  0  0  0  0  0  0]
            [ 0  0 16  0  0  8  0  0]
            [ 0  0  0 16  0  0  8  0]
            [ 0  0  0  0 16  0  0  8]
            [ 0  0  8  0  0 16  0  0]
            [ 0  0  0  8  0  0 16  0]
            [ 0  0  0  0  8  0  0 16]
            sage: M.det() != 0
            True
        """
        B = self.basis()
        M = matrix([[self.bilinear_form(b, bp) for bp in B] for b in B])
        M.set_immutable()
        return M

    def maximal_submodule(self):
        """
        Return the maximal submodule of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: SM = B4.specht_module([[1], [2,1]], GF(3))
            sage: SM.dimension()
            8
            sage: U = SM.maximal_submodule()
            sage: U.dimension()
            4
        """
        return MaximalSpechtSubmodule(self)

    def simple_module(self):
        r"""
        Return the simple (or irreducible) `S_n`-submodule of ``self``.

        .. SEEALSO::

            :class:`~sage.combinat.specht_module.SimpleModule`

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: SM = B4.specht_module([[2,1], [1]], GF(3))
            sage: L = SM.simple_module()
            sage: L.dimension()
            4

            sage: SM = B4.specht_module([[2,1], [1]], QQ)
            sage: SM.simple_module() is SM
            True
        """
        if self.base_ring().characteristic() == 0:
            return self
        return SimpleModule(self)

    Element = SymGroupSpechtModule.Element


class MaximalSpechtSubmodule(Representation_abstract, SubmoduleWithBasis):
    r"""
    The maximal submodule `U^{\lambda, \mu}` of the type `B_n` Specht
    module `S^{\lambda, \mu}`.

    ALGORITHM:

    We construct `U^{(\lambda,\mu)}` as the intersection `S \cap S^{\perp}`,
    where `S^{\perp}` is the orthogonal complement of the Specht module `S`
    inside of the tabloid module `T` (with respect to the natural
    bilinear form on `T`).

    EXAMPLES::

        sage: B4 = SignedPermutations(4)
        sage: SM = B4.specht_module([[1], [2,1]], GF(3))
        sage: U = SM.maximal_submodule()
        sage: u = U.an_element(); u
        2*U[0] + 2*U[1]
        sage: [p * u for p in list(B4)[:4]]
        [2*U[0] + 2*U[1], 2*U[0] + 2*U[1], 2*U[0] + 2*U[1], 2*U[0] + 2*U[1]]
        sage: sum(U.semigroup_algebra().basis()) * u  # long time
        0
    """
    def __init__(self, specht_module):
        r"""
        Initialize ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: SM = B4.specht_module([[1], [2,1]], GF(3))
            sage: U = SM.maximal_submodule()
            sage: TestSuite(U).run()

            sage: SM = B4.specht_module([[1,1,1], [1]], GF(3))
            sage: U = SM.maximal_submodule()
            sage: TestSuite(U).run()

            sage: SM = B4.specht_module([[1], [2,1]], QQ)
            sage: U = SM.maximal_submodule()
            sage: TestSuite(U).run()
            sage: U.dimension()
            0
        """
        Representation_abstract.__init__(self, specht_module._semigroup, specht_module._side,
                                         algebra=specht_module._semigroup_algebra)
        self._diagram = specht_module._diagram

        from sage.sets.family import Family
        p = specht_module.base_ring().characteristic()
        if p == 0:
            basis = Family([])
        else:
            TM = specht_module._ambient
            if not all(la.is_regular(p) for la in TM._diagram) or (p == 2 and TM._diagram[0]):
                basis = specht_module.basis()
            else:
                TV = TM._dense_free_module()
                SV = TV.submodule(specht_module.lift.matrix().columns())
                basis = (SV & SV.complement()).basis()
                basis = [specht_module.retract(TM.from_vector(b)) for b in basis]
                basis = Family(specht_module.echelon_form(basis))

        unitriangular = all(b.leading_support() == 1 for b in basis)
        support_order = list(specht_module.basis().keys())
        cat = specht_module.category().Subobjects()
        SubmoduleWithBasis.__init__(self, basis, support_order, ambient=specht_module,
                                    unitriangular=unitriangular, category=cat,
                                    prefix='U')

    def _repr_(self):
        r"""
        Return a string representation of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: SM = B4.specht_module([[1], [2,1]], GF(3))
            sage: SM.maximal_submodule()
            Maximal submodule of Specht module of shape ([1], [2, 1])
             over Finite Field of size 3
        """
        return f"Maximal submodule of {self._ambient}"

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: latex(B4.specht_module([[2,1], [1]], GF(3)).maximal_submodule())
            U^{{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{\phantom{x}}&\lr{\phantom{x}}\\\cline{1-2}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            },{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            }}
        """
        from sage.misc.latex import latex
        return "U^{" + ",".join(latex(la) for la in self._diagram) + "}"

    Element = SymGroupSpechtModule.Element


class SimpleModule(Representation_abstract, QuotientModuleWithBasis):
    r"""
    The simple `B_n`-module associated with a partition pair `(\lambda, \mu)`.

    The simple module `D^{\lambda, \mu}` is the quotient of the
    Specht module `S^{\lambda, \mu}` by its
    :class:`maximal submodule <MaximalSpechtSubmodule>` `U^{\lambda, \mu}`.

    For `p \neq 2`, a partition pair `(\lambda, \mu)` is `p`-*regular*
    if `\lambda` and `\mu` are `p`-regular partitions. It is `2`-regular
    if `\lambda = \emptyset` and `\mu` is `2`-regular.

    EXAMPLES::

        sage: B5 = SignedPermutations(5)
        sage: SM = B5.specht_module([[1,1], [2,1]], GF(3))
        sage: D = SM.simple_module()
        sage: v = D.an_element(); v
        2*D([[1], [2]], [[3, 5], [4]]) + 2*D([[1], [3]], [[2, 5], [4]])
        sage: B5.an_element() * v
        2*D([[1], [5]], [[2, 4], [3]]) + 2*D([[2], [5]], [[1, 4], [3]])

    An example of a simple module for `n = 4` coming from the tabloid module::

        sage: B4 = SignedPermutations(4)
        sage: TM = B4.tabloid_module([[1], [2,1]], GF(3))
        sage: SM = TM.specht_module()
        sage: SM.dimension()
        8
        sage: SM.maximal_submodule().dimension()
        4
        sage: D = SM.simple_module()
        sage: D
        Simple module of ([1], [2, 1]) over Finite Field of size 3
        sage: D.dimension()
        4

    We give an example on how to construct the decomposition matrix
    (the Specht modules are a complete set of irreducible projective
    modules) and the Cartan matrix of a symmetric group algebra::

        sage: B3 = SignedPermutations(3)
        sage: BM = matrix(B3.simple_module(la, GF(3)).brauer_character()
        ....:             for la in PartitionTuples(2, 3, regular=3))
        sage: SBT = matrix(B3.specht_module(la, GF(3)).brauer_character()
        ....:              for la in PartitionTuples(2, 3))
        sage: D = SBT * ~BM; D
        [1 0 0 0 0 0 0 0]
        [1 1 0 0 0 0 0 0]
        [0 1 0 0 0 0 0 0]
        [0 0 1 0 0 0 0 0]
        [0 0 0 1 0 0 0 0]
        [0 0 0 0 1 0 0 0]
        [0 0 0 0 0 1 0 0]
        [0 0 0 0 0 0 1 0]
        [0 0 0 0 0 0 1 1]
        [0 0 0 0 0 0 0 1]
        sage: D.transpose() * D
        [2 1 0 0 0 0 0 0]
        [1 2 0 0 0 0 0 0]
        [0 0 1 0 0 0 0 0]
        [0 0 0 1 0 0 0 0]
        [0 0 0 0 1 0 0 0]
        [0 0 0 0 0 1 0 0]
        [0 0 0 0 0 0 2 1]
        [0 0 0 0 0 0 1 2]

    We verify this against the direct computation (up to reindexing the
    rows and columns)::

        sage: B3A = B3.algebra(GF(3))
        sage: B3A.cartan_invariants_matrix()  # not tested (~2 min)
        [2 1 0 0 0 0 0 0]
        [1 2 0 0 0 0 0 0]
        [0 0 2 1 0 0 0 0]
        [0 0 1 2 0 0 0 0]
        [0 0 0 0 1 0 0 0]
        [0 0 0 0 0 1 0 0]
        [0 0 0 0 0 0 1 0]
        [0 0 0 0 0 0 0 1]
    """
    def __init__(self, specht_module):
        r"""
        Initialize ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: D = B4.simple_module([[2,1], [1]], GF(3))
            sage: TestSuite(D).run()
        """
        self._diagram = specht_module._diagram
        p = specht_module.base_ring().characteristic()
        if (not all(la.is_regular(p) for la in specht_module._diagram)
            or (p == 2 and specht_module._diagram[0])):
            raise ValueError(f"the partition must be {p}-regular")
        Representation_abstract.__init__(self, specht_module._semigroup, specht_module._side,
                                         algebra=specht_module._semigroup_algebra)
        cat = specht_module.category()
        QuotientModuleWithBasis.__init__(self, specht_module.maximal_submodule(),
                                         cat, prefix='D', bracket='')

    def _repr_(self):
        r"""
        Return a string representation of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: B4.simple_module([[1], [3]], GF(3))
            Simple module of ([1], [3]) over Finite Field of size 3
        """
        return f"Simple module of {self._diagram} over {self.base_ring()}"

    def _latex_(self):
        r"""
        Return a latex representation of ``self``.

        EXAMPLES::

            sage: B4 = SignedPermutations(4)
            sage: latex(B4.simple_module([[2,1],[1]], GF(3)))
            D^{{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{2}c}\cline{1-2}
            \lr{\phantom{x}}&\lr{\phantom{x}}\\\cline{1-2}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            },{\def\lr#1{\multicolumn{1}{|@{\hspace{.6ex}}c@{\hspace{.6ex}}|}{\raisebox{-.3ex}{$#1$}}}
            \raisebox{-.6ex}{$\begin{array}[b]{*{1}c}\cline{1-1}
            \lr{\phantom{x}}\\\cline{1-1}
            \end{array}$}
            }}
        """
        from sage.misc.latex import latex
        return "D^{" + ",".join(latex(la) for la in self._diagram) + "}"

    Element = SymGroupSpechtModule.Element
