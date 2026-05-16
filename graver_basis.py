# sage_setup: distribution = sagemath-flint
r"""
Graver bases of integer matrices

This module provides Sage parents for exact Graver bases computed by 4ti2
and for finite filtered subsets of those bases.

The elements remain vectors in the ambient free module, so these parents are
implemented as facade finite enumerated sets. The subset/query objects are
deliberately lazy: constructing a filtered subset has constant cost, and the
actual filtering work is deferred until iteration or another operation that
needs the elements.

The current backend is 4ti2. The mathematical object is the Graver basis
itself; the backend is only one way of computing it.

EXAMPLES::

    sage: # optional - 4ti2
    sage: from sage.matrix.graver_basis import GraverBasis
    sage: A = matrix(ZZ, [[1, 2, 3]])
    sage: G = GraverBasis(A)
    sage: G.category()
    Category of facade finite enumerated sets
    sage: G.ambient() == A.row_ambient_module()
    True
    sage: sorted(tuple(v) for v in G)
    [(0, 3, -2), (1, -2, 1), (1, 1, -1), (2, -1, 0), (3, 0, -1)]
"""

from sage.categories.finite_enumerated_sets import FiniteEnumeratedSets
from sage.categories.sets_cat import EmptySetError
from sage.misc.cachefunc import cached_method
from sage.rings.integer import Integer
from sage.rings.integer_ring import ZZ
from sage.structure.parent import Parent
from sage.structure.unique_representation import UniqueRepresentation

_NO_ELEMENT = object()


def _graver_basis_matrix_via_4ti2(A):
    """
    Compute the Graver basis matrix of ``A`` using the 4ti2 interface.

    This helper keeps the backend-specific import out of the parent classes.

    TESTS::

        sage: from sage.matrix.graver_basis import _graver_basis_matrix_via_4ti2
        sage: A = matrix(ZZ, [[1, 2, 3]])
        sage: _graver_basis_matrix_via_4ti2(A)  # optional - 4ti2
        [ 0  3 -2]
        [ 1 -2  1]
        [ 1  1 -1]
        [ 2 -1  0]
        [ 3  0 -1]
    """
    try:
        from sage.interfaces.four_ti_2 import four_ti_2
    except ImportError as exc:
        raise ImportError(
            "graver_basis requires the optional 4ti2 interface "
            "'sage.interfaces.four_ti_2'"
        ) from exc
    return four_ti_2.graver(mat=A)


# TODO:
# A future backend abstraction should live behind small query-oriented hooks,
# not behind the parent classes themselves. Besides exact basis computation,
# likely hooks include existence queries, finding one bounded element, and
# candidate-superset constructors for augmentation-oriented workflows.


class _FiniteVectorCollection(Parent):
    """
    Base class for finite facade parents of vectors in a fixed ambient module.

    Subclasses provide iteration through ``_element_iterator``. Full
    materialization is cached only when a method needs all elements at once.
    """
    def __init__(self, ambient):
        self._ambient = ambient
        Parent.__init__(self, facade=ambient, category=FiniteEnumeratedSets())

    def ambient(self):
        """
        Return the ambient free module containing the elements.
        """
        return self._ambient

    def _element_iterator(self):
        """
        Return an iterator over the elements of ``self``.
        """
        raise NotImplementedError

    def __iter__(self):
        """
        Iterate over the vectors in ``self``.

        This stays lazy.
        """
        return self._element_iterator()

    @cached_method
    def _elements_tuple(self):
        """
        Return the elements of ``self`` as a cached tuple.

        This forces full realization of the finite enumeration.
        """
        return tuple(self._element_iterator())

    @cached_method
    def _first_or_no_element(self):
        """
        Return the first enumerated element, or a sentinel if ``self`` is empty.

        This scans lazily and stops as soon as one element is found.
        """
        for x in self:
            return x
        return _NO_ELEMENT

    def __bool__(self) -> bool:
        """
        Return whether ``self`` is nonempty.
        """
        return not self.is_empty()

    def __len__(self):
        """
        Return the number of vectors in ``self``.

        This forces full realization of the finite enumeration.
        """
        return len(self._elements_tuple())

    def _contains_element(self, x):
        """
        Return whether the ambient element ``x`` is in ``self``.
        """
        return x in self._elements_tuple()

    def __contains__(self, x):
        """
        Return whether ``x`` is an element of ``self``.
        """
        try:
            x = self._ambient(x)
        except (TypeError, ValueError):
            return False
        return self._contains_element(x)

    is_parent_of = __contains__

    def cardinality(self):
        """
        Return the cardinality of ``self``.

        This forces full realization of the finite enumeration.
        """
        return Integer(len(self._elements_tuple()))

    def list(self):
        """
        Return the elements of ``self`` as a list.

        This forces full realization of the finite enumeration.
        """
        return list(self._elements_tuple())

    def is_empty(self):
        """
        Return whether ``self`` has no elements.

        This scans lazily and stops as soon as one element is found.
        """
        return self._first_or_no_element() is _NO_ELEMENT

    def _an_element_(self):
        """
        Return an element of ``self``.
        """
        x = self._first_or_no_element()
        if x is _NO_ELEMENT:
            raise EmptySetError
        return x

    def first(self):
        """
        Return the first element of ``self``.

        This scans lazily and stops as soon as one element is found.
        """
        x = self._first_or_no_element()
        if x is _NO_ELEMENT:
            raise EmptySetError
        return x

    def has_nonzero_element(self):
        """
        Return whether ``self`` contains a nonzero ambient vector.

        This scans lazily and stops as soon as one such element is found.
        """
        zero = self._ambient.zero()
        for x in self:
            if x != zero:
                return True
        return False

    def random_element(self):
        """
        Return a random element of ``self``.

        This scans the finite enumeration without storing all elements.
        """
        from sage.misc.prandom import randint
        chosen = _NO_ELEMENT
        for i, x in enumerate(self, start=1):
            if randint(1, i) == 1:
                chosen = x
        if chosen is _NO_ELEMENT:
            raise EmptySetError
        return chosen

    def _element_constructor_(self, x):
        """
        Coerce ``x`` into the ambient module and verify membership.
        """
        x = self._ambient(x)
        if x not in self:
            raise ValueError(f"{x} not in {self}")
        return x


class GraverBasis(UniqueRepresentation, _FiniteVectorCollection):
    r"""
    The exact Graver basis of an integer matrix, computed by 4ti2.

    EXAMPLES::

        sage: # optional - 4ti2
        sage: from sage.misc.sage_unittest import TestSuite
        sage: A = matrix(ZZ, [[1, 2, 3]])
        sage: G = A.graver_basis()
        sage: G.category()
        Category of facade finite enumerated sets
        sage: G.matrix() == A
        True
        sage: G.is_empty()
        False
        sage: tuple(G.first())
        (0, 3, -2)
        sage: G.has_nonzero_element()
        True
        sage: sorted(tuple(v) for v in G)
        [(0, 3, -2), (1, -2, 1), (1, 1, -1), (2, -1, 0), (3, 0, -1)]
        sage: TestSuite(G).run()
    """
    @staticmethod
    def __classcall_private__(cls, A):
        """
        Normalize the defining matrix for unique representation.
        """
        if A.base_ring() is not ZZ:
            raise TypeError("A must be a matrix over ZZ")
        A = A.__copy__()
        A.set_immutable()
        return super().__classcall__(cls, A)

    def __init__(self, A):
        """
        INPUT:

        - ``A`` -- a matrix over ``ZZ``
        """
        self._matrix = A
        self._backend = "4ti2"
        self._basis_matrix = _graver_basis_matrix_via_4ti2(self._matrix)

        super().__init__(self._basis_matrix.row_ambient_module())

    def _element_iterator(self):
        """
        Iterate over the Graver vectors.
        """
        return iter(self._basis_matrix.rows())

    def _contains_element(self, x):
        """
        Return whether the ambient element ``x`` is one of the Graver vectors.
        """
        return any(g == x for g in self._basis_matrix.rows())

    def _repr_(self):
        """
        Return a string representation of ``self``.
        """
        return f"Graver basis of {self._matrix}"

    def __eq__(self, other):
        """
        Return whether ``self`` and ``other`` represent the same Graver basis.
        """
        return (isinstance(other, GraverBasis)
                and self._backend == other._backend
                and self._matrix == other._matrix)

    def __hash__(self):
        """
        Return a hash of ``self``.
        """
        return hash((self._backend, self._matrix))

    def matrix(self):
        """
        Return the defining matrix.
        """
        return self._matrix

    def backend(self):
        """
        Return the backend used to compute ``self``.
        """
        return self._backend

    def basis_matrix(self):
        """
        Return the matrix whose rows are the Graver vectors.
        """
        return self._basis_matrix

    def cardinality(self):
        """
        Return the number of Graver vectors.

        This is cheap once the backend has produced the basis matrix.
        """
        return Integer(self._basis_matrix.nrows())

    def list(self):
        """
        Return the Graver vectors as a list.
        """
        return list(self._basis_matrix.rows())

    def is_empty(self):
        """
        Return whether the Graver basis is empty.
        """
        return self._basis_matrix.nrows() == 0

    def _an_element_(self):
        """
        Return a Graver vector.
        """
        if self.is_empty():
            raise EmptySetError
        return self._basis_matrix.row(0)

    def has_nonzero_element(self):
        """
        Return whether this exact Graver basis contains a nonzero vector.
        """
        return not self.is_empty()

    def orthogonal_range_search(self, l, u):
        r"""
        Return the subset of vectors satisfying the coordinate-wise bounds.

        The result is the finite subset

        .. MATH::

            \{ g \in G(A) : l \leq g \leq u \}

        in the ambient free module.

        The returned parent is lazy: constructing it does not enumerate the
        Graver basis. Query-style methods such as :meth:`first` and
        :meth:`is_empty` stop as soon as possible, while :meth:`list` and
        :meth:`cardinality` force full realization of the finite subset.

        EXAMPLES::

            sage: # optional - 4ti2
            sage: from sage.misc.sage_unittest import TestSuite
            sage: A = matrix(ZZ, [[1, 2, 3]])
            sage: G = A.graver_basis()
            sage: S = G.orthogonal_range_search((0, -2, -1), (2, 2, 1))
            sage: S.category()
            Category of facade finite enumerated sets
            sage: S.graver_basis() is G
            True
            sage: S.is_empty()
            False
            sage: tuple(S.first())
            (1, -2, 1)
            sage: S.has_nonzero_element()
            True
            sage: all(v.parent() == A.row_ambient_module() for v in S)
            True
            sage: sorted(tuple(v) for v in S)
            [(1, -2, 1), (1, 1, -1), (2, -1, 0)]
            sage: TestSuite(S).run()
        """
        return GraverBasisSubset(self, l, u)


class GraverBasisSubset(UniqueRepresentation, _FiniteVectorCollection):
    r"""
    A finite filtered subset of a :class:`GraverBasis`.

    The bounds are stored eagerly, but the actual filtering is deferred until
    the subset is iterated or otherwise queried for its elements.

    Query-oriented methods such as :meth:`first`, :meth:`is_empty`, and
    :meth:`has_nonzero_element` scan lazily. Methods such as :meth:`list` and
    :meth:`cardinality` force full realization and cache the result.

    .. TODO::

        A future backend abstraction may want to represent more general
        query objects, including verified supersets of a Graver basis,
        without changing the public parent-style interface. That same design
        point is where augmentation-oriented queries should plug in.
    """
    @staticmethod
    def __classcall_private__(cls, graver_basis, l, u):
        """
        Normalize the bounds for unique representation.
        """
        ambient = graver_basis.ambient()
        l = tuple(cls._coerce_bound(ambient, l, "l"))
        u = tuple(cls._coerce_bound(ambient, u, "u"))
        return super().__classcall__(cls, graver_basis, l, u)

    def __init__(self, graver_basis, l, u):
        """
        INPUT:

        - ``graver_basis`` -- a :class:`GraverBasis`
        - ``l`` -- lower bound vector in the ambient module
        - ``u`` -- upper bound vector in the ambient module
        """
        self._graver_basis = graver_basis
        ambient = graver_basis.ambient()
        self._lower = self._coerce_bound(ambient, l, "l")
        self._upper = self._coerce_bound(ambient, u, "u")
        self._ncols = graver_basis.matrix().ncols()

        super().__init__(ambient)

    @staticmethod
    def _coerce_bound(ambient, value, name):
        """
        Coerce a bound into the ambient module.
        """
        try:
            bound = ambient(value)
        except (TypeError, ValueError) as exc:
            raise ValueError(
                f"{name} must coerce to an element of {ambient}"
            ) from exc
        return bound

    def _matches_bounds(self, g):
        """
        Return whether ``g`` satisfies the stored coordinate-wise bounds.
        """
        return all(self._lower[i] <= g[i] <= self._upper[i]
                   for i in range(self._ncols))

    def _element_iterator(self):
        """
        Iterate over the vectors of the ambient Graver basis matching the
        stored bounds.
        """
        for g in self._graver_basis:
            if self._matches_bounds(g):
                yield g

    def _contains_element(self, x):
        """
        Return whether the ambient element ``x`` belongs to this subset.
        """
        return self._matches_bounds(x) and x in self._graver_basis

    def _repr_(self):
        """
        Return a string representation of ``self``.
        """
        return (f"Subset of {self._graver_basis} with bounds "
                f"{self._lower} <= g <= {self._upper}")

    def __eq__(self, other):
        """
        Return whether ``self`` and ``other`` represent the same filtered
        subset.
        """
        return (isinstance(other, GraverBasisSubset)
                and self._graver_basis == other._graver_basis
                and self._lower == other._lower
                and self._upper == other._upper)

    def __hash__(self):
        """
        Return a hash of ``self``.
        """
        return hash((self._graver_basis, self._lower, self._upper))

    def graver_basis(self):
        """
        Return the ambient :class:`GraverBasis`.
        """
        return self._graver_basis

    def matrix(self):
        """
        Return the defining matrix of the ambient Graver basis.
        """
        return self._graver_basis.matrix()

    def bounds(self):
        """
        Return the lower and upper bound vectors.
        """
        return self._lower, self._upper
