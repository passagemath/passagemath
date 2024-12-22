# sage_setup: distribution = sagemath-polyhedra
r"""
Formal modules generated by polyhedra
"""
from sage.combinat.free_module import CombinatorialFreeModule
from sage.categories.graded_modules_with_basis import GradedModulesWithBasis


class FormalPolyhedraModule(CombinatorialFreeModule):
    r"""
    Class for formal modules generated by polyhedra.

    It is formal because it is free -- it does not know
    about linear relations of polyhedra.

    A formal polyhedral module is graded by dimension.

    INPUT:

    - ``base_ring`` -- base ring of the module; unrelated to the
      base ring of the polyhedra

    - ``dimension`` -- the ambient dimension of the polyhedra

    - ``basis`` -- the basis

    EXAMPLES::

        sage: from sage.geometry.polyhedron.modules.formal_polyhedra_module import FormalPolyhedraModule
        sage: def closed_interval(a, b): return Polyhedron(vertices=[[a], [b]])

    A three-dimensional vector space of polyhedra::

        sage: I01 = closed_interval(0, 1); I01.rename('conv([0], [1])')
        sage: I11 = closed_interval(1, 1); I11.rename('{[1]}')
        sage: I12 = closed_interval(1, 2); I12.rename('conv([1], [2])')
        sage: basis = [I01, I11, I12]
        sage: M = FormalPolyhedraModule(QQ, 1, basis=basis); M
        Free module generated by {conv([0], [1]), {[1]}, conv([1], [2])} over Rational Field
        sage: M.get_order()
        [conv([0], [1]), {[1]}, conv([1], [2])]

    A one-dimensional subspace; bases of subspaces just use the indexing
    set `0, \dots, d-1`, where `d` is the dimension::

        sage: M_lower = M.submodule([M(I11)]); M_lower
        Free module generated by {0} over Rational Field
        sage: M_lower.print_options(prefix='S')
        sage: M_lower.is_submodule(M)
        True
        sage: x = M(I01) - 2*M(I11) + M(I12)
        sage: M_lower.reduce(x)
        [conv([0], [1])] + [conv([1], [2])]
        sage: M_lower.retract.domain() is M
        True
        sage: y = M_lower.retract(M(I11)); y
        S[0]
        sage: M_lower.lift(y)
        [{[1]}]

    Quotient space; bases of quotient space are families indexed by
    elements of the ambient space::

        sage: M_mod_lower = M.quotient_module(M_lower); M_mod_lower
        Free module generated by {conv([0], [1]), conv([1], [2])} over Rational Field
        sage: M_mod_lower.print_options(prefix='Q')
        sage: M_mod_lower.retract(x)
        Q[conv([0], [1])] + Q[conv([1], [2])]
        sage: M_mod_lower.retract(M(I01) - 2*M(I11) + M(I12)) ==  M_mod_lower.retract(M(I01) + M(I12))
        True
    """

    @staticmethod
    def __classcall__(cls, base_ring, dimension, basis, category=None):
        r"""
        Normalize the arguments for caching.

        TESTS::

            sage: from sage.geometry.polyhedron.modules.formal_polyhedra_module import FormalPolyhedraModule
            sage: FormalPolyhedraModule(QQ, 1, ()) is FormalPolyhedraModule(QQ, 1, [])
            True
        """
        if isinstance(basis, list):
            basis = tuple(basis)
        if isinstance(basis, tuple):  # To make sure it only checks for finite input
            from sage.geometry.polyhedron.base import Polyhedron_base
            for P in basis:
                if not isinstance(P, Polyhedron_base):
                    raise TypeError(f"{P} is not a polyhedron")
                if P.ambient_space().dimension() != dimension:
                    raise TypeError(f"{P} does not belong to the ambient space")
        if category is None:
            category = GradedModulesWithBasis(base_ring)
        return super().__classcall__(cls,
                                     base_ring=base_ring,
                                     dimension=dimension,
                                     basis=basis,
                                     category=category)

    def __init__(self, base_ring, dimension, basis, category):
        """
        Construct a free module generated by the polyhedra in ``basis``.

        TESTS::

            sage: from sage.geometry.polyhedron.modules.formal_polyhedra_module import FormalPolyhedraModule
            sage: def closed_interval(a, b): return Polyhedron(vertices=[[a], [b]])
            sage: I01 = closed_interval(0, 1); I01.rename('conv([0], [1])')
            sage: I11 = closed_interval(1, 1); I11.rename('{[1]}')
            sage: I12 = closed_interval(1, 2); I12.rename('conv([1], [2])')
            sage: I02 = closed_interval(0, 2); I02.rename('conv([0], [2])')
            sage: M = FormalPolyhedraModule(QQ, 1, basis=[I01, I11, I12, I02])
            sage: TestSuite(M).run()
        """
        super().__init__(base_ring, basis, prefix='', category=category)

    def degree_on_basis(self, m):
        r"""
        The degree of an element of the basis is defined as the dimension of the polyhedron.

        INPUT:

        - ``m`` -- an element of the basis (a polyhedron)

        EXAMPLES::

            sage: from sage.geometry.polyhedron.modules.formal_polyhedra_module import FormalPolyhedraModule
            sage: def closed_interval(a, b): return Polyhedron(vertices=[[a], [b]])
            sage: I01 = closed_interval(0, 1); I01.rename('conv([0], [1])')
            sage: I11 = closed_interval(1, 1); I11.rename('{[1]}')
            sage: I12 = closed_interval(1, 2); I12.rename('conv([1], [2])')
            sage: I02 = closed_interval(0, 2); I02.rename('conv([0], [2])')
            sage: M = FormalPolyhedraModule(QQ, 1, basis=[I01, I11, I12, I02])

        We can extract homogeneous components::

            sage: O = M(I01) + M(I11) + M(I12)
            sage: O.homogeneous_component(0)
            [{[1]}]
            sage: O.homogeneous_component(1)
            [conv([0], [1])] + [conv([1], [2])]

        We note that modulo the linear relations of polyhedra, this would only be a filtration,
        not a grading, as the following example shows::

            sage: X = M(I01) + M(I12) - M(I02)
            sage: X.degree()
            1

            sage: Y = M(I11)
            sage: Y.degree()
            0
        """
        return m.dimension()
