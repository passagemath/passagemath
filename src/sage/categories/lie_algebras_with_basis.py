r"""
Lie Algebras With Basis

AUTHORS:

- Travis Scrimshaw (07-15-2013): Initial implementation
"""

#*****************************************************************************
#       Copyright (C) 2013-2017 Travis Scrimshaw <tcscrims at gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

from sage.misc.abstract_method import abstract_method
from sage.misc.lazy_import import LazyImport
from sage.categories.category_with_axiom import CategoryWithAxiom_over_base_ring
from sage.categories.lie_algebras import LieAlgebras

class LieAlgebrasWithBasis(CategoryWithAxiom_over_base_ring):
    """
    Category of Lie algebras with a basis.
    """
    _base_category_class_and_axiom = (LieAlgebras, "WithBasis")

    def example(self, gens=None):
        """
        Return an example of a Lie algebra as per
        :meth:`Category.example <sage.categories.category.Category.example>`.

        EXAMPLES::

            sage: LieAlgebras(QQ).WithBasis().example()                         # optional - sage.combinat
            An example of a Lie algebra: the abelian Lie algebra on the
             generators indexed by Partitions over Rational Field

        Another set of generators can be specified as an optional argument::

            sage: LieAlgebras(QQ).WithBasis().example(Compositions())           # optional - sage.combinat
            An example of a Lie algebra: the abelian Lie algebra on the
             generators indexed by Compositions of non-negative integers
             over Rational Field
        """
        if gens is None:
            from sage.combinat.partition import Partitions
            gens = Partitions()
        from sage.categories.examples.lie_algebras_with_basis import Example
        return Example(self.base_ring(), gens)

    Graded = LazyImport('sage.categories.graded_lie_algebras_with_basis',
                        'GradedLieAlgebrasWithBasis',
                        as_name='Graded')

    class ParentMethods:
        def _basis_key(self, x):
            """
            Return the key used to compare two basis element indices.

            The default is to call the element itself.

            TESTS::

                sage: L = LieAlgebras(QQ).WithBasis().example()                         # optional - sage.combinat
                sage: L._basis_key(Partition([3,1]))                                    # optional - sage.combinat
                [3, 1]
            """
            return x

        @abstract_method(optional=True)
        def bracket_on_basis(self, x, y):
            """
            Return the bracket of basis elements indexed by ``x`` and ``y``
            where ``x < y``. If this is not implemented, then the method
            ``_bracket_()`` for the elements must be overwritten.

            EXAMPLES::

                sage: L = LieAlgebras(QQ).WithBasis().example()                         # optional - sage.combinat
                sage: L.bracket_on_basis(Partition([3,1]), Partition([2,2,1,1]))        # optional - sage.combinat
                0
            """

        def module(self):
            """
            Return an `R`-module which is isomorphic to the
            underlying `R`-module of ``self``.

            See
            :meth:`sage.categories.lie_algebras.LieAlgebras.module` for
            an explanation.

            EXAMPLES::

                sage: L = LieAlgebras(QQ).WithBasis().example()                         # optional - sage.combinat
                sage: L.module()                                                        # optional - sage.combinat
                Free module generated by Partitions over Rational Field
            """
            from sage.combinat.free_module import CombinatorialFreeModule
            try:
                # Try to see if it has an indexing set
                return CombinatorialFreeModule(self.base_ring(), self.basis().keys())
            except AttributeError:
                # Otherwise just index by the basis of ``self`` as a fallback
                return CombinatorialFreeModule(self.base_ring(), self.basis())

        def from_vector(self, v, order=None, coerce=False):
            """
            Return the element of ``self`` corresponding to the
            vector ``v`` in ``self.module()``.

            Implement this if you implement :meth:`module`; see the
            documentation of
            :meth:`sage.categories.lie_algebras.LieAlgebras.module`
            for how this is to be done.

            EXAMPLES::

                sage: L = LieAlgebras(QQ).FiniteDimensional().WithBasis().example()     # optional - sage.combinat
                sage: u = L.from_vector(vector(QQ, (1, 0, 0))); u                       # optional - sage.combinat
                (1, 0, 0)
                sage: parent(u) is L                                                    # optional - sage.combinat
                True
            """
            B = self.basis()
            return self.sum(v[i] * B[i] for i in v.support())

        # Remove once #22629 is merged
        def dimension(self):
            """
            Return the dimension of ``self``.

            EXAMPLES::

                sage: L = LieAlgebras(QQ).FiniteDimensional().WithBasis().example()     # optional - sage.combinat
                sage: L.dimension()                                                     # optional - sage.combinat
                3

            ::

                sage: L = LieAlgebra(QQ, 'x,y', {('x','y'): {'x':1}})
                sage: L.dimension()
                2
            """
            return self.basis().cardinality()

        def pbw_basis(self, basis_key=None, **kwds):
            """
            Return the Poincare-Birkhoff-Witt basis of the universal
            enveloping algebra corresponding to ``self``.

            EXAMPLES::

                sage: L = lie_algebras.sl(QQ, 2)
                sage: PBW = L.pbw_basis()
            """
            from sage.algebras.lie_algebras.poincare_birkhoff_witt \
                import PoincareBirkhoffWittBasis
            return PoincareBirkhoffWittBasis(self, basis_key, **kwds)

        poincare_birkhoff_witt_basis = pbw_basis

        _construct_UEA = pbw_basis

    class ElementMethods:
        def _bracket_(self, y):
            """
            Return the Lie bracket ``[self, y]``, where ``y`` is an
            element of the same Lie algebra as ``self``.

            EXAMPLES::

                sage: L = LieAlgebras(QQ).WithBasis().example()                         # optional - sage.combinat
                sage: G = L.lie_algebra_generators()                                    # optional - sage.combinat
                sage: x = G[Partition([4,3,3,1])]                                       # optional - sage.combinat
                sage: y = G[Partition([6,1])]                                           # optional - sage.combinat
                sage: x.bracket(y)                                                      # optional - sage.combinat
                0
            """
            P = self.parent()

            def term(ml, mr):
                key_ml = P._basis_key(ml)
                key_mr = P._basis_key(mr)
                if key_ml == key_mr:
                    return P.zero()
                if key_ml < key_mr:
                    return P.bracket_on_basis(ml, mr)
                return -P.bracket_on_basis(mr, ml)

            return P.sum(cl * cr * term(ml, mr)
                         for ml, cl in self for mr, cr in y)

        def to_vector(self, order=None):
            """
            Return the vector in ``g.module()`` corresponding to the
            element ``self`` of ``g`` (where ``g`` is the parent of
            ``self``).

            Implement this if you implement ``g.module()``.
            See :meth:`sage.categories.lie_algebras.LieAlgebras.module`
            for how this is to be done.

            EXAMPLES::

                sage: L = LieAlgebras(QQ).FiniteDimensional().WithBasis().example()
                sage: L.an_element().to_vector()
                (0, 0, 0)

            .. TODO::

                Doctest this implementation on an example not overshadowed.
            """
            M = self.parent().module()
            B = M.basis()
            return M.sum(self[i] * B[i] for i in self.support())

        def lift(self):
            """
            Lift ``self`` to the universal enveloping algebra.

            EXAMPLES::

                sage: S = SymmetricGroup(3).algebra(QQ)                                 # optional - sage.groups
                sage: L = LieAlgebra(associative=S)                                     # optional - sage.groups
                sage: x = L.gen(3)                                                      # optional - sage.groups
                sage: y = L.gen(1)                                                      # optional - sage.groups
                sage: x.lift()                                                          # optional - sage.groups
                b3
                sage: y.lift()                                                          # optional - sage.groups
                b1
                sage: x * y                                                             # optional - sage.groups
                b1*b3 + b4 - b5
            """
            P = self.parent()
            UEA = P.universal_enveloping_algebra()
            try:
                gen_dict = UEA.algebra_generators()
            except (TypeError, AttributeError):
                gen_dict = UEA.gens_dict()
            s = UEA.zero()
            if not self:
                return s
            # Special hook for when the index set of the parent of ``self``
            #   does not match the generators index set of the UEA.
            if hasattr(P, '_UEA_names_map'):
                names_map = P._UEA_names_map
                for t, c in self.monomial_coefficients(copy=False).items():
                    s += c * gen_dict[names_map[t]]
            else:
                for t, c in self.monomial_coefficients(copy=False).items():
                    s += c * gen_dict[t]
            return s
