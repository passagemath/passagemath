# sage_setup: distribution = sagemath-cmr
# sage.doctest: optional - sage.libs.cmr
r"""
Sparse Matrices from the Combinatorial Matrix Recognition Library

This module is provided by the distribution :ref:`sagemath-cmr <spkg_sagemath_cmr>`.
"""

# ****************************************************************************
#       Copyright (C) 2023      Javier Santillan
#                     2023-2024 Matthias Koeppe
#                     2023-2024 Luze Xu
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from libc.stdint cimport SIZE_MAX

from cysignals.memory cimport sig_malloc, sig_free
from cysignals.signals cimport sig_on, sig_off

from sage.libs.cmr.cmr cimport *
from sage.rings.integer cimport Integer
from sage.rings.integer_ring import ZZ
from sage.structure.element cimport Matrix

from .args cimport MatrixArgs_init
from .constructor import matrix
from .matrix_space import MatrixSpace
from .seymour_decomposition cimport create_DecompositionNode, GraphicNode


cdef class Matrix_cmr_sparse(Matrix_sparse):
    r"""
    Base class for sparse matrices implemented in CMR

    EXAMPLES::

        sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_sparse, Matrix_cmr_chr_sparse
        sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
        ....:                           [[1, 2, 3], [4, 0, 6]])
        sage: isinstance(M, Matrix_cmr_sparse)
        True
    """
    pass


cdef class Matrix_cmr_chr_sparse(Matrix_cmr_sparse):
    r"""
    Sparse matrices with 8-bit integer entries implemented in CMR

    EXAMPLES::

        sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
        sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
        ....:                           [[1, 2, 3], [4, 0, 6]]); M
        [1 2 3]
        [4 0 6]
        sage: M.dict()
        {(0, 0): 1, (0, 1): 2, (0, 2): 3, (1, 0): 4, (1, 2): 6}

    Matrices of this class are always immutable::

        sage: M.is_immutable()
        True
        sage: copy(M) is M
        True
        sage: deepcopy(M) is M
        True

    This matrix class can only store very small integers::

        sage: Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 1, 3, sparse=True), [-128, 0, 127])
        [-128    0  127]
        sage: Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 1, 3, sparse=True), [126, 127, 128])
        Traceback (most recent call last):
        ...
        OverflowError: value too large to convert to char

    Arithmetic does not preserve the implementation class (even if the numbers would fit)::

        sage: M2 = M + M; M2
        [ 2  4  6]
        [ 8  0 12]
        sage: type(M2)
        <class 'sage.matrix.matrix_integer_sparse.Matrix_integer_sparse'>
        sage: M * 100
        [100 200 300]
        [400   0 600]
    """
    def __init__(self, parent, entries=None, copy=None, bint coerce=True, immutable=True):
        r"""
        Create a sparse matrix with 8-bit integer entries implemented in CMR.

        INPUT:

        - ``parent`` -- a matrix space

        - ``entries`` -- see :func:`matrix`

        - ``copy`` -- ignored (for backwards compatibility)

        - ``coerce`` -- if False, assume without checking that the
          entries lie in the base ring

        - ``immutable`` -- ignored (for backwards compatibility)?

        TESTS::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 2, 3], [4, 0, 6]]); M
            [1 2 3]
            [4 0 6]
            sage: TestSuite(M).run()
        """
        cdef dict d
        ma = MatrixArgs_init(parent, entries)
        d = ma.dict(coerce)
        self._init_from_dict(d, ma.nrows, ma.ncols, immutable=True)

    cdef _init_from_dict(self, dict d, int nrows, int ncols, bint immutable=True):
        r"""
        Create ``self._mat`` (a ``CMR_CHRMAT``) from a dictionary via CMR functions.

        INPUT:

        - ``dict`` -- a dictionary of all nonzero elements.

        - ``nrows`` -- the number of rows.

        - ``ncols`` -- the number of columns.

        - ``immutable`` -- (boolean) make the matrix immutable. By default,
            the output matrix is mutable.
        """
        if cmr == NULL:
            CMRcreateEnvironment(&cmr)
        CMR_CALL(CMRchrmatCreate(cmr, &self._mat, nrows, ncols, len(d)))
        for row in range(nrows):
            self._mat.rowSlice[row] = 0
        for (row, col), coeff in d.items():
            if coeff:
                self._mat.rowSlice[row + 1] += 1
        for row in range(nrows):
            self._mat.rowSlice[row + 1] += self._mat.rowSlice[row]
        for (row, col), coeff in d.items():
            if coeff:
                index = self._mat.rowSlice[row]
                self._mat.entryColumns[index] = col
                self._mat.entryValues[index] = coeff
                self._mat.rowSlice[row] = index + 1
        for row in reversed(range(nrows)):
            self._mat.rowSlice[row + 1] = self._mat.rowSlice[row]
        self._mat.rowSlice[0] = 0
        CMR_CALL(CMRchrmatSortNonzeros(cmr, self._mat))
        if immutable:
            self.set_immutable()

    def matrix_from_rows_and_columns(self, rows, columns):
        """
        Return the matrix constructed from ``self`` from the given rows and
        columns.

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = MatrixSpace(Integers(8),3,3)
            sage: A = Matrix_cmr_chr_sparse(M, range(9)); A
            [0 1 2]
            [3 4 5]
            [6 7 0]
            sage: A.matrix_from_rows_and_columns([1], [0,2])
            [3 5]
            sage: A.matrix_from_rows_and_columns([1,2], [1,2])
            [4 5]
            [7 0]

        Note that row and column indices can be reordered::

            sage: A.matrix_from_rows_and_columns([2,1], [2,1])
            [0 7]
            [5 4]

        But the column indices can not be repeated::

            sage: A.matrix_from_rows_and_columns([1,1,1],[2,0])
            [5 3]
            [5 3]
            [5 3]
            sage: A.matrix_from_rows_and_columns([1,1,1],[2,0,0])
            Traceback (most recent call last):
            ...
            ValueError: The column indices can not be repeated
        """
        if not isinstance(rows, (list, tuple)):
            rows = list(rows)

        if not isinstance(columns, (list, tuple)):
            columns = list(columns)

        if len(list(set(columns))) != len(columns):
            raise ValueError("The column indices can not be repeated")

        if cmr == NULL:
            CMRcreateEnvironment(&cmr)

        cdef CMR_SUBMAT *submatrix = NULL
        cdef CMR_CHRMAT *cmr_submatrix = NULL

        try:
            CMR_CALL(CMRsubmatCreate(cmr, len(rows), len(columns), &submatrix))

            for i in range(submatrix.numRows):
                submatrix.rows[i] = rows[i]

            for j in range(submatrix.numColumns):
                submatrix.columns[j] = columns[j]

            CMR_CALL(CMRchrmatSlice(cmr, self._mat, submatrix, &cmr_submatrix))
        finally:
            CMR_CALL(CMRsubmatFree(cmr, &submatrix))

        return Matrix_cmr_chr_sparse._from_cmr(cmr_submatrix)

    cdef get_unsafe(self, Py_ssize_t i, Py_ssize_t j):
        """
        Return ``(i, j)`` entry of this matrix as an integer.

        .. warning::

           This is very unsafe; it assumes ``i`` and ``j`` are in the right
           range.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 2, 3], [4, 0, 6]]); M
            [1 2 3]
            [4 0 6]
            sage: M[1, 2]
            6
            sage: M[1, 3]
            Traceback (most recent call last):
            ...
            IndexError: matrix index out of range
            sage: M[-1, 0]
            4
        """
        cdef size_t index
        CMR_CALL(CMRchrmatFindEntry(self._mat, i, j, &index))
        if index == SIZE_MAX:
            return Integer(0)
        return Integer(self._mat.entryValues[index])

    def _dict(self):
        """
        Return the underlying dictionary of ``self``.
        """
        cdef dict d
        d = {}
        for row in range(self._mat.numRows):
            for index in range(self._mat.rowSlice[row], self._mat.rowSlice[row + 1]):
                d[(row, self._mat.entryColumns[index])] = Integer(self._mat.entryValues[index])
        return d

    def __copy__(self):
        """
        Matrix_cmr_chr_sparse matrices are immutable.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 2, 3], [4, 0, 6]])
            sage: copy(M) is M
            True
        """
        return self

    def __deepcopy__(self, memo):
        """
        Matrix_cmr_chr_sparse matrices are immutable.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 2, 3], [4, 0, 6]])
            sage: deepcopy(M) is M
            True
        """
        return self

    def __dealloc__(self):
        """
        Frees all the memory allocated for this matrix.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 2, 3], [4, 0, 6]])
            sage: del M
        """
        if self._root is None or self._root is self:
            # We own it, so we have to free it.
            CMR_CALL(CMRchrmatFree(cmr, &self._mat))

    def _test_change_ring(self, **options):
        return

    def _pickle(self):
        """
        Utility function for pickling.

        TESTS::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 2, 3], [4, 0, 6]])
            sage: loads(dumps(M)) == M
            True
        """
        version = 0
        return self._dict(), version

    def _unpickle(self, data, int version):
        if version != 0:
            raise RuntimeError("unknown matrix version (=%s)"%version)
        self._init_from_dict(data, self._nrows, self._ncols)

    # CMR-specific methods. Other classes that want to provide these methods should create
    # a copy of themselves as an instance of this class and delegate to it.

    @staticmethod
    def _from_data(data, immutable=True):
        """
        Create a matrix (:class:`Matrix_cmr_chr_sparse`) from data or a matrix.

        INPUT:

        - ``data`` -- a matrix or data to construct a matrix.

        - ``immutable`` -- (boolean) make the matrix immutable. By default,
            the output matrix is mutable.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse._from_data([[1, 2, 3], [4, 0, 6]]); M
            [1 2 3]
            [4 0 6]
            sage: N = matrix(ZZ, [[1, 2, 3], [4, 0, 6]])
            sage: Matrix_cmr_chr_sparse._from_data(N)
            [1 2 3]
            [4 0 6]
        """
        if not isinstance(data, Matrix):
            data = matrix(ZZ, data, sparse=True)
        if not isinstance(data, Matrix_cmr_chr_sparse):
            data = Matrix_cmr_chr_sparse(data.parent(), data, immutable=immutable)
        return data

    @staticmethod
    cdef _from_cmr(CMR_CHRMAT *mat, bint immutable=False, base_ring=None):
        r"""
        INPUT:

        - ``mat`` -- a ``CMR_CHRMAT``; after this call, it is owned by the created Python object

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        """
        cdef Matrix_cmr_chr_sparse result
        if base_ring is None:
            base_ring = ZZ
        ms = MatrixSpace(base_ring, mat.numRows, mat.numColumns, sparse=True)
        result = Matrix_cmr_chr_sparse.__new__(Matrix_cmr_chr_sparse, ms, immutable=immutable)
        result._mat = mat
        result._root = None
        return result

    @staticmethod
    def _network_matrix_from_digraph(digraph, forest_arcs=None, arcs=None, vertices=None):
        r"""
        Return the network matrix of ``digraph``, pivoted according to ``forest_arcs``.

        Its rows are indexed parallel to ``forest_arcs``.
        It is in "short tableau" form, i.e., the columns are indexed parallel
        to the elements of ``arcs`` that are not in ``forest_arcs``.

        .. NOTE::

            In [Sch1986]_, the columns are indexed by all arcs of the digraph,
            giving a "long tableau" form of the network matrix.

        INPUT:

        - ``digraph`` -- a :class:`DiGraph`

        - ``forest_arcs`` -- a sequence of arcs of the ``digraph`` or ``None`` (the default:
          use the labels of the ``arcs`` as a boolean value)

        - ``arcs`` -- a sequence of arcs of the digraph or ``None`` (the default:
          all arcs going out from the ``vertices``)

        - ``vertices`` -- a sequence of vertices of the digraph or ``None`` (the default:
          all vertices of the ``digraph``)

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse

        Defining the forest by arc labels::

            sage: D = DiGraph([[0, 1, 2, 3],
            ....:              [(0, 1, True), (0, 2, True), (1, 2), (1, 3, True), (2, 3)]])
            sage: M = Matrix_cmr_chr_sparse._network_matrix_from_digraph(D); M
            [ 1 -1]
            [-1  1]
            [ 1  0]

        Defining the forest by a separate list of forest arcs::

            sage: D = DiGraph([[0, 1, 2, 3],
            ....:              [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3)]])
            sage: T = [(0, 1), (0, 2), (1, 3)]
            sage: M = Matrix_cmr_chr_sparse._network_matrix_from_digraph(D, T); M
            [ 1 -1]
            [-1  1]
            [ 1  0]

        Prescribing an order for the arcs (columns)::

            sage: D = DiGraph([[0, 1, 2, 3],
            ....:              [(0, 1), (0, 2), (1, 2), (1, 3), (2, 3)]])
            sage: T = [(0, 1), (0, 2), (1, 3)]
            sage: A = [(2, 3), (0, 1), (0, 2), (1, 2), (1, 3)]
            sage: M = Matrix_cmr_chr_sparse._network_matrix_from_digraph(D, T, arcs=A); M
            [ 1 -1]
            [-1  1]
            [ 1  0]

        TESTS::

            sage: D = DiGraph([[0, 1, 2], [(0, 1), (1, 2), (0, 2)]])
            sage: not_a_forest = [(0, 1), (1, 2), (0, 2)]
            sage: M = Matrix_cmr_chr_sparse._network_matrix_from_digraph(D, not_a_forest); M
            Traceback (most recent call last):
            ...
            ValueError: not a spanning forest
        """
        cdef CMR_GRAPH *cmr_digraph = NULL
        cdef dict vertex_to_cmr_node = {}
        cdef dict arc_to_cmr_edge = {}
        cdef CMR_GRAPH_EDGE cmr_edge
        cdef CMR_GRAPH_NODE cmr_node

        if cmr == NULL:
            CMRcreateEnvironment(&cmr)

        CMR_CALL(CMRgraphCreateEmpty(cmr, &cmr_digraph, digraph.num_verts(), digraph.num_edges()))

        if vertices is None:
            iter_vertices = digraph.vertex_iterator()
        else:
            iter_vertices = vertices
        for u in iter_vertices:
            CMR_CALL(CMRgraphAddNode(cmr, cmr_digraph, &cmr_node))
            vertex_to_cmr_node[u] = cmr_node

        vertices = vertex_to_cmr_node.keys()
        if arcs is None:
            arcs = digraph.edge_iterator(labels=False, vertices=vertices, ignore_direction=False)

        for a in arcs:
            u, v = a
            CMR_CALL(CMRgraphAddEdge(cmr, cmr_digraph, vertex_to_cmr_node[u],
                                     vertex_to_cmr_node[v], &cmr_edge))
            arc_to_cmr_edge[(u, v)] = cmr_edge

        cdef CMR_GRAPH_EDGE *cmr_forest_arcs = NULL
        cdef bool *cmr_arcs_reversed = NULL
        cdef CMR_CHRMAT *cmr_matrix = NULL
        cdef bool is_correct_forest
        cdef size_t num_forest_arcs

        cdef size_t mem_arcs
        if forest_arcs is not None:
            mem_arcs = len(forest_arcs)
        else:
            mem_arcs = len(vertices) - 1

        CMR_CALL(_CMRallocBlockArray(cmr, <void **> &cmr_forest_arcs, mem_arcs, sizeof(CMR_GRAPH_EDGE)))
        try:
            if forest_arcs is None:
                num_forest_arcs = 0
                for u, v, label in digraph.edge_iterator(labels=True, vertices=vertices,
                                                         ignore_direction=False):
                    if label:
                        if num_forest_arcs >= mem_arcs:
                            raise ValueError('not a spanning forest')
                        cmr_forest_arcs[num_forest_arcs] = arc_to_cmr_edge[(u, v)]
                        num_forest_arcs += 1
            else:
                num_forest_arcs = len(forest_arcs)
                for i, (u, v) in enumerate(forest_arcs):
                    cmr_forest_arcs[i] = arc_to_cmr_edge[(u, v)]

            CMR_CALL(_CMRallocBlockArray(cmr, <void **> &cmr_arcs_reversed, len(arc_to_cmr_edge), sizeof(bool)))
            try:
                for j in range(len(arc_to_cmr_edge)):
                    cmr_arcs_reversed[j] = <bool> False
                CMR_CALL(CMRnetworkComputeMatrix(cmr, cmr_digraph, &cmr_matrix, NULL,
                                                 cmr_arcs_reversed, num_forest_arcs, cmr_forest_arcs,
                                                 0, NULL, &is_correct_forest))
                if not is_correct_forest:
                    raise ValueError('not a spanning forest')
            finally:
                CMR_CALL(_CMRfreeBlockArray(cmr, <void **> &cmr_arcs_reversed))
        finally:
            CMR_CALL(_CMRfreeBlockArray(cmr, <void **> &cmr_forest_arcs))

        return Matrix_cmr_chr_sparse._from_cmr(cmr_matrix)

    @staticmethod
    def one_sum(*summands):
        r"""
        Return a block-diagonal matrix constructed from the given matrices (summands).

        INPUT:

        - ``summands`` -- integer matrices or data from which integer matrices can be
          constructed

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        The terminology "1-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_.

        .. SEEALSO:: :meth:`two_sum`
                     :meth:`delta_sum`, :meth:`three_sum`, :meth:`y_sum`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse.one_sum([[1, 0], [-1, 1]], [[1, 1], [-1, 0]])
            sage: unicode_art(M)
            ⎛ 1  0│ 0  0⎞
            ⎜-1  1│ 0  0⎟
            ⎜─────┼─────⎟
            ⎜ 0  0│ 1  1⎟
            ⎝ 0  0│-1  0⎠
            sage: M = Matrix_cmr_chr_sparse.one_sum([[1, 0], [-1, 1]], [[1]], [[-1]])
            sage: unicode_art(M)
            ⎛ 1  0│ 0│ 0⎞
            ⎜-1  1│ 0│ 0⎟
            ⎜─────┼──┼──⎟
            ⎜ 0  0│ 1│ 0⎟
            ⎜─────┼──┼──⎟
            ⎝ 0  0│ 0│-1⎠

        TESTS::

            sage: M = Matrix_cmr_chr_sparse.one_sum(); M
            []
            sage: M.parent()
            Full MatrixSpace of 0 by 0 sparse matrices over Integer Ring

            sage: M = Matrix_cmr_chr_sparse.one_sum([[1, 0], [-1, 1]]); unicode_art(M)
            ⎛ 1  0⎞
            ⎝-1  1⎠
            sage: M.parent()
            Full MatrixSpace of 2 by 2 sparse matrices over Integer Ring
        """
        cdef Matrix_cmr_chr_sparse sum, summand
        cdef CMR_CHRMAT *sum_mat
        summands = iter(summands)
        try:
            first = next(summands)
        except StopIteration:
            return Matrix_cmr_chr_sparse._from_data({})
        sum = Matrix_cmr_chr_sparse._from_data(first, immutable=False)
        sum_mat = sum._mat
        row_subdivision = []
        column_subdivision = []

        cdef CMR_CHRMAT *tmp_sum_mat = NULL
        cdef CMR_CHRMAT *tmp_two_mats[2]
        sig_on()
        try:
            for s in summands:
                row_subdivision.append(sum_mat.numRows)
                column_subdivision.append(sum_mat.numColumns)
                summand = Matrix_cmr_chr_sparse._from_data(s)
                tmp_two_mats[0] = sum_mat
                tmp_two_mats[1] = summand._mat
                CMR_CALL(CMRonesumCompose(cmr, 2, &tmp_two_mats[0], &tmp_sum_mat))
                tmp_two_mats[0] = NULL
                tmp_two_mats[1] = NULL
                sum_mat = tmp_sum_mat
                tmp_sum_mat = NULL

        finally:
            sig_off()

        if sum_mat != sum._mat:
            sum = Matrix_cmr_chr_sparse._from_cmr(sum_mat, immutable=False)
        if row_subdivision or column_subdivision:
            sum.subdivide(row_subdivision, column_subdivision)
        sum.set_immutable()
        return sum

    def two_sum(first_mat, second_mat, first_index, second_index, nonzero_block="top_right"):
        r"""
        Return the 2-sum matrix constructed from the given matrices ``first_mat`` and
        ``second_mat``, with index of the first matrix ``first_index`` and index
        of the second matrix ``second_index``.
        Suppose that ``first_index`` indicates the last column of ``first_mat`` and
        ``second_index`` indicates the first row of ``second_mat``,
        i.e, the first matrix is
        `M_1=\begin{bmatrix} A & a\end{bmatrix}`
        and the second matrix is
        `M_2=\begin{bmatrix} b^T \\ D\end{bmatrix}`.
        Then the two sum
        `
        M_1 \oplus_2 M_2 = \begin{bmatrix}
        A & ab^T \\
        0 & D
        \end{bmatrix},
        `
        Suppose that ``first_index`` indicates the last row of ``first_mat`` and
        ``second_index`` indicates the first column of ``second_mat``,
        i.e, the first matrix is
        `M_1=\begin{bmatrix} A \\ c^T\end{bmatrix}`
        and the second matrix is
        `M_2=\begin{bmatrix} d & D\end{bmatrix}`.
        Then the two sum
        `M_1 \oplus_2 M_2 = \begin{bmatrix}
        A & 0 \\
        dc^T & D
        \end{bmatrix},
        `

        The terminology "2-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`one_sum`
                     :meth:`delta_sum`, :meth:`three_sum`, :meth:`y_sum`
                     :meth:`two_sum_decomposition`

        INPUT:

        - ``first_mat`` -- the first integer matrix
        - ``second_mat`` -- the second integer matrix
        - ``first_index`` -- the column/row index of the first integer matrix
        - ``second_index`` -- the row/column index of the second integer matrix
        - ``nonzero_block`` -- either ``"top_right"`` (default) or ``"bottom_left"``;
          whether the nonzero block in the 2-sum matrix locates in the top right or bottom left.
          If ``nonzero_block="top_right"``,
          ``first_index`` is the column index of the first integer matrix,
          ``second_index`` is the row index of the second integer matrix.
          The outer product of the corresponding column and row
          form the nonzero top right block of the 2-sum matrix.
          If ``nonzero_block="bottom_left"``,
          ``first_index`` is the row index of the first integer matrix,
          ``second_index`` is the column index of the second integer matrix.
          The outer product of the corresponding row and column
          form the nonzero bottom left block of the 2-sum matrix.

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: K33 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 4, sparse=True),
            ....:                            [[1, 1, 0, 0], [1, 1, 1, 0],
            ....:                             [1, 0, 0,-1], [0, 1, 1, 1],
            ....:                             [0, 0, 1, 1]]); K33
            [ 1  1  0  0]
            [ 1  1  1  0]
            [ 1  0  0 -1]
            [ 0  1  1  1]
            [ 0  0  1  1]
            sage: K33_dual = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 5, sparse=True),
            ....:                            [[1, 1, 1, 0, 0], [1, 1, 0, 1, 0],
            ....:                             [0, 1, 0, 1, 1], [0, 0,-1, 1, 1]]); K33_dual
            [ 1  1  1  0  0]
            [ 1  1  0  1  0]
            [ 0  1  0  1  1]
            [ 0  0 -1  1  1]
            sage: M = Matrix_cmr_chr_sparse.two_sum(K33, K33_dual, 0, 0,
            ....:                                   nonzero_block="bottom_left"); M
            [ 1  1  1  0| 0  0  0  0]
            [ 1  0  0 -1| 0  0  0  0]
            [ 0  1  1  1| 0  0  0  0]
            [ 0  0  1  1| 0  0  0  0]
            [-----------+-----------]
            [ 1  1  0  0| 1  1  0  0]
            [ 1  1  0  0| 1  0  1  0]
            [ 0  0  0  0| 1  0  1  1]
            [ 0  0  0  0| 0 -1  1  1]

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                            [[1, 2, 3], [4, 5, 6]]); M1
            [1 2 3]
            [4 5 6]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                            [[7, 8, 9], [-1, -2, -3]]); M2
            [ 7  8  9]
            [-1 -2 -3]
            sage: Matrix_cmr_chr_sparse.two_sum(M1, M2, 2, 0)
            [ 1  2|21 24 27]
            [ 4  5|42 48 54]
            [-----+--------]
            [ 0  0|-1 -2 -3]
            sage: M1.two_sum(M2, 1, 1)
            [  1   3| -2  -4  -6]
            [  4   6| -5 -10 -15]
            [-------+-----------]
            [  0   0|  7   8   9]
            sage: M1.two_sum(M2, 1, 1, nonzero_block="bottom_right")
            Traceback (most recent call last):
            ...
            ValueError: ('Unknown two sum mode', 'bottom_right')
            sage: M1.two_sum(M2, 1, 1, nonzero_block="bottom_left")
            [  1   2   3|  0   0]
            [-----------+-------]
            [ 32  40  48|  7   9]
            [ -8 -10 -12| -1  -3]

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 5, sparse=True),
            ....:                            [[1, 1, 0, 0, 0],
            ....:                             [1, 0, 1,-1, 1],
            ....:                             [0,-1, 1, 0,-1],
            ....:                             [0, 0,-1, 1, 0],
            ....:                             [0, 1, 1, 0, 1]]); M1
            [ 1  1  0  0  0]
            [ 1  0  1 -1  1]
            [ 0 -1  1  0 -1]
            [ 0  0 -1  1  0]
            [ 0  1  1  0  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 5, sparse=True),
            ....:                            [[1,-1, 1, 0, 0],
            ....:                             [1, 1, 1, 1,-1],
            ....:                             [0, 0,-1, 0, 1],
            ....:                             [1, 0, 0,-1, 0],
            ....:                             [0, 1, 0, 0, 1]]); M2
            [ 1 -1  1  0  0]
            [ 1  1  1  1 -1]
            [ 0  0 -1  0  1]
            [ 1  0  0 -1  0]
            [ 0  1  0  0  1]
            sage: M1.two_sum(M2, 1, 2, nonzero_block="bottom_left")
            [ 1  1  0  0  0| 0  0  0  0]
            [ 0 -1  1  0 -1| 0  0  0  0]
            [ 0  0 -1  1  0| 0  0  0  0]
            [ 0  1  1  0  1| 0  0  0  0]
            [--------------+-----------]
            [ 1  0  1 -1  1| 1 -1  0  0]
            [ 1  0  1 -1  1| 1  1  1 -1]
            [-1  0 -1  1 -1| 0  0  0  1]
            [ 0  0  0  0  0| 1  0 -1  0]
            [ 0  0  0  0  0| 0  1  0  1]
            sage: M1.two_sum(M2, 4, 0)
            [ 1  1  0  0| 0  0  0  0  0]
            [ 1  0  1 -1| 1 -1  1  0  0]
            [ 0 -1  1  0|-1  1 -1  0  0]
            [ 0  0 -1  1| 0  0  0  0  0]
            [ 0  1  1  0| 1 -1  1  0  0]
            [-----------+--------------]
            [ 0  0  0  0| 1  1  1  1 -1]
            [ 0  0  0  0| 0  0 -1  0  1]
            [ 0  0  0  0| 1  0  0 -1  0]
            [ 0  0  0  0| 0  1  0  0  1]

        TESTS::

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(GF(3), 2, 3, sparse=True),
            ....:                            [[1, 2, 3], [4, 5, 6]]); M1
            [1 2 0]
            [1 2 0]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(GF(5), 2, 3, sparse=True),
            ....:                            [[7, 8, 9], [-1, -2, -3]]); M2
            [2 3 4]
            [4 3 2]
            sage: Matrix_cmr_chr_sparse.two_sum(M1, M2, 2, 0)
            Traceback (most recent call last):
            ...
            ValueError: summands must have the same base ring,
            got Finite Field of size 3, Finite Field of size 5
        """
        cdef Matrix_cmr_chr_sparse sum, first, second
        cdef CMR_CHRMAT *sum_mat = NULL
        cdef size_t* firstSpecialRow = NULL
        cdef size_t* firstSpecialColumn = NULL
        cdef size_t* secondSpecialRow = NULL
        cdef size_t* secondSpecialColumn = NULL
        cdef size_t column
        cdef size_t row

        first = Matrix_cmr_chr_sparse._from_data(first_mat)
        second = Matrix_cmr_chr_sparse._from_data(second_mat)
        first_base_ring = first.parent().base_ring()
        second_base_ring = second.parent().base_ring()
        if first_base_ring != second_base_ring:
            raise ValueError(f'summands must have the same base ring, '
                             f'got {first_base_ring}, {second_base_ring}')

        if nonzero_block not in ["top_right", "bottom_left"]:
            raise ValueError("Unknown two sum mode", nonzero_block)

        if nonzero_block == "top_right":
            column = first_index
            row = second_index
            if column < 0 or column >= first._mat.numColumns:
                raise ValueError("First marker should be a column index of the first matrix")
            if row < 0 or row >= second._mat.numRows:
                raise ValueError("Second marker should be a row index of the second matrix")
            row_subdivision = []
            column_subdivision = []
            row_subdivision.append(first._mat.numRows)
            column_subdivision.append(first._mat.numColumns - 1)
            firstSpecialColumn = &column
            secondSpecialRow = &row
        else:
            row = first_index
            column = second_index
            if row < 0 or row >= first._mat.numRows:
                raise ValueError("First marker should be a Row index of the first matrix")
            if column < 0 or column >= second._mat.numColumns:
                raise ValueError("Second marker should be a column index of the second matrix")
            row_subdivision = []
            column_subdivision = []
            row_subdivision.append(first._mat.numRows - 1)
            column_subdivision.append(first._mat.numColumns)
            firstSpecialRow = &row
            secondSpecialColumn = &column

        cdef int8_t characteristic = first_base_ring.characteristic()

        sig_on()
        try:
            CMR_CALL(CMRtwosumCompose(cmr, first._mat, second._mat, firstSpecialRow, firstSpecialColumn, secondSpecialRow, secondSpecialColumn, characteristic, &sum_mat))
        finally:
            sig_off()

        sum = Matrix_cmr_chr_sparse._from_cmr(sum_mat, immutable=False, base_ring=first_base_ring)
        if row_subdivision or column_subdivision:
            sum.subdivide(row_subdivision, column_subdivision)
        sum.set_immutable()
        return sum

    def _delta_sum_cmr(first_mat, second_mat, first_special_row, first_special_columns, second_special_row, second_special_columns):
        r"""
        Return the `\Delta`-sum matrix constructed from the two matrices
        ``first_mat`` and ``second_mat`` via connecting rows
        ``first_special_row`` and columns ``first_special_columns``.

        This function implements the "distributed_ranks" strategy for the 3-sum operation.

        Let `M_1` and `M_2` denote the matrices given by ``first_mat`` and ``second_mat``. If ``first_special_row``
        indexes a row vector `c^T` and ``first_special_columns`` indexes two column vectors `a` of ``first_mat``,
        then ``second_special_row`` indexes a row vector `b` and ``second_special_columns`` indexes two column
        vectors `d` of ``second_mat``. In this case, the first matrix is
        `
            M_1 = \begin{bmatrix} A & a & a \\ c^T & 0 & \varepsilon \end{bmatrix}
        `
        and the second matrix is
        `
            M_2 = \begin{bmatrix} \varepsilon & 0 & b^T \\ d & d & D \end{bmatrix}.
        `
        Then the Seymour/Schrijver 3-sum is the matrix
        `
            M_1 \oplus_3 M_2 = \begin{bmatrix} A & a b^T \\ d c^T & D \end{bmatrix}.
        `

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`one_sum`, :meth:`two_sum`
                    :meth:`delta_sum`,:meth:`y_sum`, :meth:`three_sum`

        INPUT:

        - ``first_mat`` -- the first integer matrix
        - ``second_mat`` -- the second integer matrix
        - ``first_special_row`` -- the index of the special row in the first matrix
        - ``first_special_columns`` -- the indices of the two special columns in the first matrix
        - ``second_special_row`` -- the index of the special row in the second matrix
        - ``second_special_columns`` -- the indices of the two special columns in the second matrix

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [1, 0, 0, 1,-1, 1],
            ....:                             [0,-1, 1, 1, 0,-1],
            ....:                             [0, 0,-1,-1, 1, 0],
            ....:                             [0, 1, 1, 1, 0, 1]]); M1
            [ 1  1  0  0  0  0]
            [ 1  0  0  1 -1  1]
            [ 0 -1  1  1  0 -1]
            [ 0  0 -1 -1  1  0]
            [ 0  1  1  1  0  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1,-1,-1, 1, 0, 0],
            ....:                             [1, 1, 0, 1, 1,-1],
            ....:                             [0, 0, 0,-1, 0, 1],
            ....:                             [1, 0, 0, 0,-1, 0],
            ....:                             [0, 1, 1, 0, 0, 1]]); M2
            [ 1 -1 -1  1  0  0]
            [ 1  1  0  1  1 -1]
            [ 0  0  0 -1  0  1]
            [ 1  0  0  0 -1  0]
            [ 0  1  1  0  0  1]
            sage: M1._delta_sum_cmr(M2, 1, [2, 3], 1, [1, 2])
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 4, sparse=True),
            ....:                            [[1, 1, 0, 0],
            ....:                             [1, 0, 1, 1],
            ....:                             [0, 1, 0,-1]]); M1
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0  1  0 -1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 4, sparse=True),
            ....:                            [[-1, 0, 1, 0],
            ....:                             [ 1, 1, 0, 1],
            ....:                             [ 0, 0, 1, 1]]); M2
            [-1  0  1  0]
            [ 1  1  0  1]
            [ 0  0  1  1]
            sage: M1._delta_sum_cmr(M2, 2, [2, 3], 0, [0, 1])
            [1 1 0 0]
            [1 0 1 0]
            [0 1 0 1]
            [0 0 1 1]
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 4, sparse=True),
            ....:                            [[1, 1, 0, 0],
            ....:                             [1, 0, 1, 1],
            ....:                             [0, 1, 0, 1]]); M1
            [1 1 0 0]
            [1 0 1 1]
            [0 1 0 1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 4, sparse=True),
            ....:                            [[1, 0, 1, 0],
            ....:                             [1, 1, 0, 1],
            ....:                             [0, 0, 1, 1]]); M2
            [1 0 1 0]
            [1 1 0 1]
            [0 0 1 1]
            sage: M1._delta_sum_cmr(M2, 2, [2, 3], 0, [0, 1])
            [1 1 0 0]
            [1 0 1 0]
            [0 1 0 1]
            [0 0 1 1]
        """
        cdef Matrix_cmr_chr_sparse sum, first, second
        cdef CMR_CHRMAT *sum_mat = NULL
        first = Matrix_cmr_chr_sparse._from_data(first_mat, immutable=False)
        second = Matrix_cmr_chr_sparse._from_data(second_mat, immutable=False)
        cdef size_t* firstSpecialRows = <size_t *>sig_malloc(sizeof(size_t))
        cdef size_t* firstSpecialColumns = <size_t *>sig_malloc(sizeof(size_t)*2)
        cdef size_t* secondSpecialRows = <size_t *>sig_malloc(sizeof(size_t))
        cdef size_t* secondSpecialColumns = <size_t *>sig_malloc(sizeof(size_t)*2)
        cdef int8_t characteristic = first_mat.parent().characteristic()

        if second_mat.parent().characteristic() != characteristic:
            raise ValueError("The characteristic of two matrices are different")

        # Check if indices are within range
        if first_special_row < 0 or first_special_row >= first._mat.numRows:
            raise ValueError("First special row index out of range")
        if first_special_columns[0] < 0 or first_special_columns[0] >= first._mat.numColumns:
            raise ValueError("First special column index 1 out of range")
        if first_special_columns[1] < 0 or first_special_columns[1] >= first._mat.numColumns:
            raise ValueError("First special column index 2 out of range")
        if second_special_row < 0 or second_special_row >= second._mat.numRows:
            raise ValueError("Second special row index out of range")
        if second_special_columns[0] < 0 or second_special_columns[0] >= second._mat.numColumns:
            raise ValueError("Second special column index 1 out of range")
        if second_special_columns[1] < 0 or second_special_columns[1] >= second._mat.numColumns:
            raise ValueError("Second special column index 2 out of range")

        firstSpecialRows[0] = first_special_row
        firstSpecialColumns[0] = first_special_columns[0]
        firstSpecialColumns[1] = first_special_columns[1]
        secondSpecialRows[0] = second_special_row
        secondSpecialColumns[0] = second_special_columns[0]
        secondSpecialColumns[1] = second_special_columns[1]

        sig_on()
        try:
            CMR_CALL(CMRdeltasumCompose(cmr, first._mat, second._mat, firstSpecialRows, firstSpecialColumns, secondSpecialRows, secondSpecialColumns, characteristic, &sum_mat))
        finally:
            sig_off()

        sum = Matrix_cmr_chr_sparse._from_cmr(sum_mat)
        return sum

    def _y_sum_cmr(first_mat, second_mat, first_special_rows, first_special_column, second_special_rows, second_special_column):
        r"""
        Return the Y-sum matrix constructed from the two matrices
        ``first_mat`` and ``second_mat`` via connecting rows
        ``first_special_rows`` and column ``first_special_column``.

        This function implements the "y_sum" strategy for the 3-sum operation.

        Let `M_1` and `M_2` denote the matrices given by ``first_mat`` and ``second_mat``. If ``first_special_rows``
        indexes two row vectors `c^T` of ``first_mat`` and ``first_special_column`` indexes a column vector `a` of
        ``first_mat``, then ``second_special_rows`` indexes two row vectors `b^T` of ``second_mat`` and
        ``second_special_column`` indexes a column vector `d` of ``second_mat``. In this case, the first matrix is
        `
            M_1 = \begin{bmatrix} A & a \\ c^T & 0 \\ c^T & \varepsilon \end{bmatrix}
        `
        and the second matrix is
        `
            M_2 = \begin{bmatrix} \varepsilon & b^T \\ 0 & b^T \\ d & D \end{bmatrix}.
        `
        Then the Y-sum is the matrix
        `
            M_1 \oplus_3 M_2 = \begin{bmatrix} A & a b^T \\ d c^T & D \end{bmatrix}.
        `

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`one_sum`, :meth:`two_sum`
                     :meth:`delta_sum`, :meth:`y_sum`, :meth:`three_sum`

        INPUT:

        - ``first_mat`` -- the first integer matrix
        - ``second_mat`` -- the second integer matrix
        - ``first_special_rows`` -- the indices of the two special rows in the first matrix
        - ``first_special_column`` -- the index of the special column in the first matrix
        - ``second_special_rows`` -- the indices of the two special rows in the second matrix
        - ``second_special_column`` -- the index of the special column in the second matrix

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`
        """
        cdef Matrix_cmr_chr_sparse sum, first, second
        cdef CMR_CHRMAT *sum_mat = NULL
        first = Matrix_cmr_chr_sparse._from_data(first_mat, immutable=False)
        second = Matrix_cmr_chr_sparse._from_data(second_mat, immutable=False)
        cdef size_t* firstSpecialRows = <size_t *>sig_malloc(sizeof(size_t)*2)
        cdef size_t* firstSpecialColumns = <size_t *>sig_malloc(sizeof(size_t))
        cdef size_t* secondSpecialRows = <size_t *>sig_malloc(sizeof(size_t)*2)
        cdef size_t* secondSpecialColumns = <size_t *>sig_malloc(sizeof(size_t))
        cdef int8_t characteristic = first_mat.parent().characteristic()

        if second_mat.parent().characteristic() != characteristic:
            raise ValueError("The characteristic of two matrices are different")

        # Check if indices are within range
        if first_special_rows[0] < 0 or first_special_rows[0] >= first._mat.numRows:
            raise ValueError("First special row index 1 out of range")
        if first_special_rows[1] < 0 or first_special_rows[1] >= first._mat.numRows:
            raise ValueError("First special row index 2 out of range")
        if first_special_column < 0 or first_special_column >= first._mat.numColumns:
            raise ValueError("First special column index out of range")
        if second_special_rows[0] < 0 or second_special_rows[0] >= second._mat.numRows:
            raise ValueError("Second special row index 1 out of range")
        if second_special_rows[1] < 0 or second_special_rows[1] >= second._mat.numRows:
            raise ValueError("Second special row index 2 out of range")
        if second_special_column < 0 or second_special_column >= second._mat.numColumns:
            raise ValueError("Second special column index out of range")

        firstSpecialRows[0] = first_special_rows[0]
        firstSpecialRows[1] = first_special_rows[1]
        firstSpecialColumns[0] = first_special_column
        secondSpecialRows[0] = second_special_rows[0]
        secondSpecialRows[1] = second_special_rows[1]
        secondSpecialColumns[0] = second_special_column

        sig_on()
        try:
            CMR_CALL(CMRysumCompose(cmr, first._mat, second._mat, firstSpecialRows, firstSpecialColumns, secondSpecialRows, secondSpecialColumns, characteristic, &sum_mat))
        finally:
            sig_off()

        sum = Matrix_cmr_chr_sparse._from_cmr(sum_mat)
        return sum

    def _three_sum_cmr(first_mat, second_mat,
                  first_special_rows, first_special_columns, second_special_rows, second_special_columns):
        r"""
        Return the 3-sum matrix constructed from the two matrices
        ``first_mat`` and ``second_mat`` via connecting rows
        ``first_special_rows`` and ``second_special_rows`` and columns ``first_special_columns`` and ``second_special_columns``.

        Let `M_1` and `M_2` denote the matrices given by ``first_mat`` and ``second_mat``, let `A` be the matrix
        `M_1` without the rows ``first_special_rows[0]`` and ``first_special_rows[1]`` and column ``first_special_columns[2]``.
        After permuting these to be last, `M_1` must be of the form
        `
            M_1 = \begin{bmatrix}
            A & 0 \\
            C_{i,\star} & \alpha \\
            C_{j,\star} & \beta
            \end{bmatrix},
        `
        where `\alpha,\beta \in \{-1,+1 \}` (otherwise, ``RuntimeError("Invalid matrix structure")`` is returned). Let `D` be the
        matrix `M_2` without the row ``second_special_rows[0]`` and columns ``second_special_columns[0]`` and
        ``second_special_columns[1]``. After reordering these to be first, `M_2` must be of the form
        `
            M_2 = \begin{bmatrix}
            \gamma & \delta & 0^T \\
            C_{\star,k} & C_{\star,\ell} & D
            \end{bmatrix},
        `
        where `\gamma,\delta \in \{ -1,+1 \}` (otherwise, ``RuntimeError("Invalid matrix structure")`` is returned) and such that the matrix
        `
            N = \begin{bmatrix}
            \gamma & \delta & 0 \\
            C_{i,k} & C_{i,\ell} & \alpha \\
            C_{j,k} & C_{j,\ell} & \beta
            \end{bmatrix}
        `
        is totally unimodular (otherwise, ``RuntimeError("Inconsistent pieces of input")`` is returned). The columns ``first_special_columns[0]`` and
        ``first_special_columns[1]`` indicate the columns of `M_1` that shall correspond to `C_{\star,k}` and
        `C_{\star,\ell}`, respectively. Similarly, the rows ``second_special_rows[1]`` and ``second_special_rows[2]``
        indicate the rows of `M_2` that shall correspond to `C_{i,\star}` and `C_{j,\star}`, respectively.

        .. note::
            The 2-by-2 submatrix of `M_1` indexed by rows ``first_special_rows[0]`` and ``first_special_rows[1]`` and
            columns ``first_special_columns[0]`` and ``first_special_columns[1]`` must be identical to the submatrix of
            `M_2` indexed by rows ``second_special_rows[1]`` and ``second_special_rows[2]`` and columns
            ``secondSpecialColumns[0]`` and ``secondSpecialColumns[1]``, which is the matrix `C_{\{i,j\},\{k,\ell\}}`.
            ``second_special_columns[0]`` and ``second_special_columns[1]``, which is the matrix `C_{\{i,j\},\{k,\ell\}}`. Otherwise, ``RuntimeError("Invalid matrix structure")`` is returned.

        The 3-sum of `M_1` and `M_2` (at these rows/columns) is the matrix
        `
            M = \begin{bmatrix}
            A & 0 \\
            C & D
            \end{bmatrix},
        `
        where `C` is the unique rank-2 matrix having linearly independent rows `C_{i,\star}` and
        `C_{j,\star}` and linearly independent columns `C_{\star,k}` and `C_{\star,\ell}`.

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`one_sum`, :meth:`two_sum`,
                     :meth:`delta_sum`, :meth:`y_sum`, :meth:`three_sum`

        INPUT:

        - ``first_mat`` -- the first integer matrix
        - ``second_mat`` -- the second integer matrix
        - ``first_special_rows`` -- the indices of two special rows in the first matrix
        - ``first_special_columns`` -- the indices of three special columns in the first matrix, where the last column is an extra column
        - ``second_special_rows`` -- the indices of three special rows in the second matrix, where the first row is an extra row
        - ``second_special_columns`` -- the indices of two special columns in the second matrix

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 5, sparse=True),
            ....:                            [[1, 0, 1, 1, 0],
            ....:                             [0, 1, 1, 1, 0],
            ....:                             [1, 0, 1, 0, 1],
            ....:                             [0,-1, 0,-1, 1]]); M1
            [ 1  0  1  1  0]
            [ 0  1  1  1  0]
            [ 1  0  1  0  1]
            [ 0 -1  0 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 4, sparse=True),
            ....:                            [[1, 1, 0, 0],
            ....:                             [1, 0, 1, 1],
            ....:                             [0,-1, 1, 1],
            ....:                             [1, 0, 1, 0],
            ....:                             [0,-1, 0, 1]]); M2
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0 -1  1  1]
            [ 1  0  1  0]
            [ 0 -1  0  1]
            sage: M1._three_sum_cmr(M2, [2,3], [2,3,4], [0,1,2], [0,1])
            [ 1  0  1  1  0  0]
            [ 0  1  1  1  0  0]
            [ 1  0  1  0  1  1]
            [ 0 -1  0 -1  1  1]
            [ 1  0  1  0  1  0]
            [ 0 -1  0 -1  0  1]
            sage: M1._three_sum_cmr(M2, [2,3], [0,1,4], [0,3,2], [0,1])
            [ 1  0  1  1  0  0]
            [ 0  1  1  1  0  0]
            [ 1  0  1  0  1  1]
            [ 0 -1  0 -1  1  1]
            [ 1  0  1  0  1  0]
            [ 0 -1  0 -1  0  1]
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 5, sparse=True),
            ....:                            [[1, 0,-1, 1, 0],
            ....:                             [0, 1,-1, 1, 0],
            ....:                             [1, 0, 1, 0, 1],
            ....:                             [0,-1, 1,-1, 1]]); M1
            [ 1  0 -1  1  0]
            [ 0  1 -1  1  0]
            [ 1  0  1  0  1]
            [ 0 -1  1 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 4, sparse=True),
            ....:                            [[-1, 1, 0, 0],
            ....:                             [1, 0, 1, 1],
            ....:                             [1,-1, 1, 1],
            ....:                             [1, 0, 1, 0],
            ....:                             [0,-1, 0, 1]]); M2
            [-1  1  0  0]
            [ 1  0  1  1]
            [ 1 -1  1  1]
            [ 1  0  1  0]
            [ 0 -1  0  1]
            sage: M1._three_sum_cmr(M2, [2,3], [2,3,4], [0,1,2], [0,1])
            [ 1  0 -1  1  0  0]
            [ 0  1 -1  1  0  0]
            [ 1  0  1  0  1  1]
            [ 0 -1  1 -1  1  1]
            [ 1  0  1  0  1  0]
            [-1 -1  0 -1  0  1]

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0, 0,-1, 1, 0, 0],
            ....:                             [0, 1, 1, 0, 1, 0],
            ....:                             [1, 0, 1,-1, 1, 1],
            ....:                             [0,-1, 1, 0,-1, 1]]); M1
            [ 1  1  0  0  0  0]
            [ 0  0 -1  1  0  0]
            [ 0  1  1  0  1  0]
            [ 1  0  1 -1  1  1]
            [ 0 -1  1  0 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[ 1,-1, 0, 0, 0],
            ....:                             [ 1, 0, 1,-1, 0],
            ....:                             [ 1,-1, 1, 1, 1],
            ....:                             [-1, 1, 0, 0, 0],
            ....:                             [ 0, 0, 1, 0,-1],
            ....:                             [ 0, 1, 0, 1, 0]]); M2
            [ 1 -1  0  0  0]
            [ 1  0  1 -1  0]
            [ 1 -1  1  1  1]
            [-1  1  0  0  0]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  0]
            sage: Matrix_cmr_chr_sparse._three_sum_cmr(M1, M2, [3,4], [1,2,5], [0,1,2], [1,0])
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [ 1  0  1 -1  1  1 -1  0]
            [ 0 -1  1  0 -1  1  1  1]
            [ 0  1 -1  0  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 1  1  0 -1  2  0  1  0]

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [1, 0, 1,-1, 1, 1],
            ....:                             [0,-1, 1, 0,-1, 1],
            ....:                             [0, 0,-1, 1, 0, 0],
            ....:                             [0, 1, 1, 0, 1, 0]]); M1
            [ 1  1  0  0  0  0]
            [ 1  0  1 -1  1  1]
            [ 0 -1  1  0 -1  1]
            [ 0  0 -1  1  0  0]
            [ 0  1  1  0  1  0]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[0, 0, 1, 0,-1],
            ....:                             [1,-1, 1, 0, 0],
            ....:                             [1, 1, 1, 1,-1],
            ....:                             [0, 0,-1, 0, 1],
            ....:                             [1, 0, 0,-1, 0],
            ....:                             [0, 1, 0, 0, 1]]); M2
            [ 0  0  1  0 -1]
            [ 1 -1  1  0  0]
            [ 1  1  1  1 -1]
            [ 0  0 -1  0  1]
            [ 1  0  0 -1  0]
            [ 0  1  0  0  1]
            sage: M = M1._three_sum_cmr(M2, [1, 2], [1,2,5],
            ....:                  [0,1,2], [4, 2]); M
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [ 1  0  1 -1  1  1 -1  0]
            [ 0 -1  1  0 -1  1  1  1]
            [ 0  1 -1  0  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 1  1  0 -1  2  0  1  0]
            sage: M1._three_sum_cmr(M2, [1, 2], [1,2,5],
            ....:                  [0,1,2], [2, 4])
            Traceback (most recent call last):
            ...
            RuntimeError: Invalid matrix structure

            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[0, 0, 1, 0, 1],
            ....:                             [1,-1, 1, 0, 0],
            ....:                             [1, 1, 1, 1,-1],
            ....:                             [0, 0,-1, 0, 1],
            ....:                             [1, 0, 0,-1, 0],
            ....:                             [0, 1, 0, 0, 1]]); M2
            [ 0  0  1  0  1]
            [ 1 -1  1  0  0]
            [ 1  1  1  1 -1]
            [ 0  0 -1  0  1]
            [ 1  0  0 -1  0]
            [ 0  1  0  0  1]
            sage: M = M1._three_sum_cmr(M2, [1, 2], [1,2,5],
            ....:                  [0,1,2], [4, 2])
            Traceback (most recent call last):
            ...
            RuntimeError: Inconsistent pieces of input
        """
        cdef Matrix_cmr_chr_sparse sum, first, second
        cdef CMR_CHRMAT *sum_mat = NULL
        first = Matrix_cmr_chr_sparse._from_data(first_mat, immutable=False)
        second = Matrix_cmr_chr_sparse._from_data(second_mat, immutable=False)
        cdef size_t firstSpecialRows[2]
        cdef size_t firstSpecialColumns[3]
        cdef size_t secondSpecialRows[3]
        cdef size_t secondSpecialColumns[2]

        for i in range(2):
            firstSpecialRows[i] = first_special_rows[i]
        for i in range(3):
            firstSpecialColumns[i] = first_special_columns[i]
        for i in range(3):
            secondSpecialRows[i] = second_special_rows[i]
        for i in range(2):
            secondSpecialColumns[i] = second_special_columns[i]

        for i in range(2):
            if firstSpecialRows[i] < 0 or firstSpecialRows[i] >= first._mat.numRows:
                raise ValueError(f"First special rows {i} should be a row index of the first matrix")
            if secondSpecialColumns[i] < 0 or secondSpecialColumns[i] >= second._mat.numColumns:
                raise ValueError(f"Second special columns {i} should be a column index of the second matrix")
        for i in range(3):
            if firstSpecialColumns[i] < 0 or firstSpecialColumns[i] >= first._mat.numColumns:
                raise ValueError(f"First special columns {i} should be a column index of the first matrix")
            if secondSpecialRows[i] < 0 or secondSpecialRows[i] >= second._mat.numRows:
                raise ValueError(f"Second special rows {i} should be a row index of the second matrix")

        cdef int8_t characteristic = first_mat.parent().characteristic()

        if second_mat.parent().characteristic() != characteristic:
            raise ValueError("The characteristic of two matrices are different")

        sig_on()
        try:
            CMR_CALL(CMRthreesumCompose(cmr, first._mat, second._mat, &firstSpecialRows[0], &firstSpecialColumns[0], &secondSpecialRows[0], &secondSpecialColumns[0], characteristic, &sum_mat))
        finally:
            sig_off()

        sum = Matrix_cmr_chr_sparse._from_cmr(sum_mat)
        return sum

    def delta_sum(first_mat, second_mat,
                            first_row_index=-1,
                            first_columns_index=[-2, -1],
                            second_row_index=0,
                            second_columns_index=[0, 1],
                            algorithm="cmr",
                            sign_verify=False):
        r"""
        Return the `\Delta`-sum matrix constructed from the two matrices
        ``first_mat`` and ``second_mat``.

        Let `M_1` and `M_2` denote the matrices given by ``first_mat`` and ``second_mat``. If ``first_row_index``
        indexes a row vector `c^T` and ``first_columns_index`` indexes two column vectors `a` of ``first_mat``,
        then ``second_row_index`` indexes a row vector `b` and ``second_columns_index`` indexes two column
        vectors `d` of ``second_mat``. In this case, the first matrix is
        `
            M_1 = \begin{bmatrix} A & a & a \\ c^T & 0 & \varepsilon \end{bmatrix}
        `
        and the second matrix is
        `
            M_2 = \begin{bmatrix} \varepsilon & 0 & b^T \\ d & d & D \end{bmatrix}.
        `
        Then the Seymour/Schrijver 3-sum is the matrix
        `
            M_1 \oplus_3 M_2 = \begin{bmatrix} A & a b^T \\ d c^T & D \end{bmatrix}.
        `

        The terminology "`\Delta`-sum" is one type of "3-sum",
        which is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`y_sum`, :meth:`three_sum`
                     :meth:`is_delta_sum`

        INPUT:

        - ``first_mat`` -- the first integer matrix `M_1`
        - ``second_mat`` -- the second integer matrix `M_2`
        - ``first_row_index`` -- the row index of `c^T` in `M_1`
        - ``first_columns_index`` -- the column indices of `a` in `M_1`
        - ``second_row_index`` -- the row index of `b^T` in `M_2`
        - ``second_columns_index`` -- the column indices of `d`  in `M_2`
        - ``algorithm`` -- ``"cmr"`` or ``"direct"``
          If ``algorithm="cmr"``, then use :meth:`_delta_sum_cmr`;
          If ``algorithm="direct"``, then construct three sum directly.
          Both options will check the given two matrices and the related indices
          satisfying the requirements of 3-sum.
        - ``sign_verify`` -- boolean (default: ``False``);
          whether to check the sign correctness.
          Note that ``algorithm="cmr"`` will always check the sign consistency.
          See :meth:`is_delta_sum`.

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1, 1],
            ....:                             [0, 0, 1, 0,-1,-1],
            ....:                             [0, 1, 0, 1, 1, 1],
            ....:                             [1, 0,-1, 1, 0, 1],]); M1
            [ 1  1  0  0  0  0]
            [ 0 -1  0 -1  1  1]
            [ 0  0  1  0 -1 -1]
            [ 0  1  0  1  1  1]
            [ 1  0 -1  1  0  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[ 1, 0, 1, 1, 1,-1],
            ....:                             [-1,-1, 1, 1, 0, 0],
            ....:                             [ 0, 0, 0,-1, 0, 1],
            ....:                             [ 0, 0, 1, 0,-1, 0],
            ....:                             [ 1, 1, 0, 0, 0, 1]]); M2
            [ 1  0  1  1  1 -1]
            [-1 -1  1  1  0  0]
            [ 0  0  0 -1  0  1]
            [ 0  0  1  0 -1  0]
            [ 1  1  0  0  0  1]
            sage: Matrix_cmr_chr_sparse.delta_sum(M1, M2)
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]

        Three sum can be computed for any row and column indices:

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [1, 0, 1,-1, 1, 0],
            ....:                             [0,-1, 1, 0,-1, 1],
            ....:                             [0, 0,-1, 1, 0,-1],
            ....:                             [0, 1, 1, 0, 1, 1]]); M1
            [ 1  1  0  0  0  0]
            [ 1  0  1 -1  1  0]
            [ 0 -1  1  0 -1  1]
            [ 0  0 -1  1  0 -1]
            [ 0  1  1  0  1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1,-1, 1, 0, 0,-1],
            ....:                             [1, 1, 1, 1,-1, 0],
            ....:                             [0, 0,-1, 0, 1, 0],
            ....:                             [1, 0, 0,-1, 0, 0],
            ....:                             [0, 1, 0, 0, 1, 1]]); M2
            [ 1 -1  1  0  0 -1]
            [ 1  1  1  1 -1  0]
            [ 0  0 -1  0  1  0]
            [ 1  0  0 -1  0  0]
            [ 0  1  0  0  1  1]
            sage: M = M1.delta_sum(M2, 1, [-1, 2], 1, [1, -1]); M
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]
            sage: N = M1.delta_sum(M2, 1, [-1, 2], 1, [1, -1], algorithm="direct")
            sage: M == N
            True

            sage: M1.delta_sum(M2, 1, [2, 3], 1, [1, -1])
            Traceback (most recent call last):
            ...
            RuntimeError: Invalid matrix structure
            sage: M1.delta_sum(M2, 1, [2, 3], 1, [1, -1], algorithm="direct")
            Traceback (most recent call last):
            ...
            ValueError: The given two matrices and related indices do not satisfy the rule for delta sum!

            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1,-1, 1, 0, 0,-1],
            ....:                             [1,-1, 1, 1,-1, 0],
            ....:                             [0, 0,-1, 0, 1, 0],
            ....:                             [1, 0, 0,-1, 0, 0],
            ....:                             [0, 1, 0, 0, 1, 1]]); M2
            [ 1 -1  1  0  0 -1]
            [ 1 -1  1  1 -1  0]
            [ 0  0 -1  0  1  0]
            [ 1  0  0 -1  0  0]
            [ 0  1  0  0  1  1]
            sage: M1.delta_sum(M2, 1, [-1, 2], 1, [1, -1])
            Traceback (most recent call last):
            ...
            RuntimeError: Inconsistent pieces of input
            sage: M1.delta_sum(M2, 1, [-1, 2], 1, [1, -1], algorithm="direct")
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]
            sage: M1.delta_sum(M2, 1, [-1, 2], 1, [1, -1], algorithm="direct", sign_verify=True)
            'sign_2 in first_mat should be 1. '
        """
        m1 = first_mat.nrows()
        n1 = first_mat.ncols()
        m2 = second_mat.nrows()
        n2 = second_mat.ncols()
        j1 = first_columns_index[0]
        j2 = first_columns_index[1]
        j1 = j1 if j1 >= 0 else n1 + j1
        j2 = j2 if j2 >= 0 else n1 + j2
        i1 = first_row_index
        i1 = i1 if i1 >= 0 else m1 + i1
        k1 = second_columns_index[0]
        k2 = second_columns_index[1]
        k1 = k1 if k1 >= 0 else n2 + k1
        k2 = k2 if k2 >= 0 else n2 + k2
        i2 = second_row_index
        i2 = i2 if i2 >= 0 else m2 + i2

        if algorithm not in ["cmr", "direct"]:
            raise ValueError("Unknown algorithm", algorithm)

        if algorithm == "cmr":
            M = Matrix_cmr_chr_sparse._delta_sum_cmr(first_mat, second_mat,
                                                     i1, [j1, j2],
                                                     i2, [k1, k2])
        if algorithm == "direct":
            row_index_1 = [i for i in range(m1) if i != i1]
            column_index_1 = [j for j in range(n1) if j != j1 and j != j2]
            row_index_2 = [i for i in range(m2) if i != i2]
            column_index_2 = [j for j in range(n2) if j != k1 and j != k2]
            a2 = first_mat.matrix_from_rows_and_columns(row_index_1, [j2])
            b1 = second_mat.matrix_from_rows_and_columns(row_index_2, [k1])

            a1 = first_mat.matrix_from_rows_and_columns([i1], column_index_1)
            b2 = second_mat.matrix_from_rows_and_columns([i2], column_index_2)

            A = first_mat.matrix_from_rows_and_columns(row_index_1, column_index_1)
            B = second_mat.matrix_from_rows_and_columns(row_index_2, column_index_2)

            first_subrows = A.rows()
            second_subrows = B.rows()
            upper_right_rows = a2.tensor_product(b2).rows()
            lower_left_rows = b1.tensor_product(a1).rows()

            row_list = []
            for i in range(m1 - 1):
                r = list(first_subrows[i])
                u = list(upper_right_rows[i])
                r.extend(u)
                row_list.append(r)
            for i in range(m2 - 1):
                r = list(lower_left_rows[i])
                u = list(second_subrows[i])
                r.extend(u)
                row_list.append(r)
            M = Matrix_cmr_chr_sparse._from_data(row_list, immutable=False)

        result = M.is_delta_sum(first_mat, second_mat,
                                          first_row_index=first_row_index,
                                          first_columns_index=first_columns_index,
                                          second_row_index=second_row_index,
                                          second_columns_index=second_columns_index,
                                          sign_verify=sign_verify)
        if result is True:
            return M
        elif result is False:
            raise ValueError('The given two matrices and related indices '
                             'do not satisfy the rule for delta sum!')
        else:
            return result[1]

    def three_sum(first_mat, second_mat,
                              first_rows_index=[-2, -1],
                              first_column_index=-1,
                              first_intersection_columns=[-3, -2],
                              second_row_index=0,
                              second_columns_index=[0, 1],
                              second_intersection_rows=[1, 2],
                              algorithm="cmr",
                              sign_verify=False):
        r"""
        Return the 3-sum matrix constructed from the given matrices ``first_mat`` and
        ``second_mat``.
        In this case,
        the first matrix is
        `
            M_1 = \begin{bmatrix}
            A & 0 \\
            C_{i,\star} & \alpha \\
            C_{j,\star} & \beta
            \end{bmatrix},
        `
        where `\alpha,\beta \in \{-1,+1 \}`,
        and the second matrix is
        `
            M_2 = \begin{bmatrix}
            \gamma & \delta & 0^T \\
            C_{\star,k} & C_{\star,\ell} & D
            \end{bmatrix},
        `
        where `\gamma,\delta \in \{ -1,+1 \}` such that the matrix
        `
            N = \begin{bmatrix}
            \gamma & \delta & 0 \\
            C_{i,k} & C_{i,\ell} & \alpha \\
            C_{j,k} & C_{j,\ell} & \beta
            \end{bmatrix}
        `
        is totally unimodular.
        Then the 3-sum of `M_1` and `M_2` (at these rows/columns) is the matrix
        `
            M = \begin{bmatrix}
            A & 0 \\
            C & D
            \end{bmatrix},
        `
        where `C` is the unique rank-2 matrix having linearly independent rows `C_{i,\star}` and
        `C_{j,\star}` and linearly independent columns `C_{\star,k}` and `C_{\star,\ell}`.

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`delta_sum`, :meth:`y_sum`, :meth:`is_three_sum`

        INPUT:

        - ``first_mat`` -- the first integer matrix `M_1`
        - ``second_mat`` -- the second integer matrix `M_2`
        - ``first_rows_index`` -- the indices of rows `a_1^T` and `a_2^T` in `M_1`
        - ``first_column_index`` -- the index of the extra column in `M_1`
        - ``first_intersection_columns`` -- the indices of columns `k` and `\ell`
        - ``second_row_index`` -- the index of the extra row in `M_2`
        - ``second_columns_index`` -- the indices of columns `b_1` and `b_2`  in `M_2`
        - ``second_intersection_rows`` -- the indices of rows `i` and `j`
        - ``algorithm`` -- ``"cmr"`` or ``"direct"``
          If ``algorithm="cmr"``, then use :meth:`_three_sum_cmr`;
          If ``algorithm="direct"``, then construct three sum directly.
          Both options will check the give two matrices and the related indices
          satisfying the requirements of 3-sum.
        - ``sign_verify`` -- boolean (default: ``False``);
          whether to check the sign correctness.
          See :meth:`is_three_sum`.

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0, 0,-1, 1, 0, 0],
            ....:                             [0, 1, 1, 0, 1, 0],
            ....:                             [1, 0, 1,-1, 1, 1],
            ....:                             [0,-1, 1, 0,-1, 1]]); M1
            [ 1  1  0  0  0  0]
            [ 0  0 -1  1  0  0]
            [ 0  1  1  0  1  0]
            [ 1  0  1 -1  1  1]
            [ 0 -1  1  0 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[-1, 1, 0, 0, 0],
            ....:                             [ 1, 0, 1,-1, 0],
            ....:                             [ 1,-1, 1, 1, 1],
            ....:                             [-1, 1, 0, 0, 0],
            ....:                             [ 0, 0, 1, 0,-1],
            ....:                             [ 0, 1, 0, 1, 0]]); M2
            [-1  1  0  0  0]
            [ 1  0  1 -1  0]
            [ 1 -1  1  1  1]
            [-1  1  0  0  0]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  0]
            sage: Matrix_cmr_chr_sparse.three_sum(M1, M2, [-2,-1], -1, [2, 3], 0, [1,0], [3,5])
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [-1 -1  0  1 -2  1 -1  0]
            [-1  0 -1  1 -1  1  1  1]
            [ 1  0  1 -1  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 0 -1  1  0 -1  0  1  0]
            sage: Matrix_cmr_chr_sparse.three_sum(M1, M2, first_intersection_columns=[2, 1])
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [ 1  0  1 -1  1  1 -1  0]
            [ 0 -1  1  0 -1  1  1  1]
            [ 0  1 -1  0  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 1  1  0 -1  2  0  1  0]

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [1, 0, 1,-1, 1, 1],
            ....:                             [0,-1, 1, 0,-1, 1],
            ....:                             [0, 0,-1, 1, 0, 0],
            ....:                             [0, 1, 1, 0, 1, 0]]); M1
            [ 1  1  0  0  0  0]
            [ 1  0  1 -1  1  1]
            [ 0 -1  1  0 -1  1]
            [ 0  0 -1  1  0  0]
            [ 0  1  1  0  1  0]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[0, 0, 1, 0,-1],
            ....:                             [1,-1, 1, 0, 0],
            ....:                             [1, 1, 1, 1,-1],
            ....:                             [0, 0,-1, 0, 1],
            ....:                             [1, 0, 0,-1, 0],
            ....:                             [0, 1, 0, 0, 1]]); M2
            [ 0  0  1  0 -1]
            [ 1 -1  1  0  0]
            [ 1  1  1  1 -1]
            [ 0  0 -1  0  1]
            [ 1  0  0 -1  0]
            [ 0  1  0  0  1]
            sage: M = M1.three_sum(M2, first_rows_index=[1, 2],
            ....:                  first_intersection_columns=[2, 3],
            ....:                  second_columns_index=[4, 2],
            ....:                  second_intersection_rows=[3, 5]); M
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [-1 -1  0  1 -2  1 -1  0]
            [-1  0 -1  1 -1  1  1  1]
            [ 1  0  1 -1  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 0 -1  1  0 -1  0  1  0]
            sage: M1.three_sum(M2, first_rows_index=[1, 2],
            ....:                  first_column_index=1,
            ....:                  second_columns_index=[2, 4])
            Traceback (most recent call last):
            ...
            RuntimeError: Invalid matrix structure
            sage: M1.three_sum(M2, first_rows_index=[1, 2],
            ....:                  first_column_index=1,
            ....:                  second_columns_index=[2, 4], algorithm="direct")
            Traceback (most recent call last):
            ...
            ValueError: The intersection matrix is not the same!
        """
        m1 = first_mat.nrows()
        n1 = first_mat.ncols()
        m2 = second_mat.nrows()
        n2 = second_mat.ncols()
        j1 = first_rows_index[0]
        j2 = first_rows_index[1]
        j1 = j1 if j1 >= 0 else m1 + j1
        j2 = j2 if j2 >= 0 else m1 + j2
        i1 = first_column_index
        i1 = i1 if i1 >= 0 else n1 + i1
        jk1, jk2 = first_intersection_columns
        jk1 = jk1 if jk1 >= 0 else n1 + jk1
        jk2 = jk2 if jk2 >= 0 else n1 + jk2
        k1 = second_columns_index[0]
        k2 = second_columns_index[1]
        k1 = k1 if k1 >= 0 else n2 + k1
        k2 = k2 if k2 >= 0 else n2 + k2
        i2 = second_row_index
        i2 = i2 if i2 >= 0 else m2 + i2
        j1k, j2k = second_intersection_rows
        j1k = j1k if j1k >= 0 else m2 + k1
        j2k = j2k if j2k >= 0 else m2 + k2

        if algorithm not in ["cmr", "direct"]:
            raise ValueError("Unknown algorithm", algorithm)

        if algorithm == "cmr":
            M = Matrix_cmr_chr_sparse._three_sum_cmr(first_mat, second_mat,
                                                     [j1, j2], [jk1, jk2, i1],
                                                     [i2, j1k, j2k], [k1, k2])
        if algorithm == "direct":
            row_index_1 = [i for i in range(m1) if i != j1 and i != j2]
            column_index_1 = [j for j in range(n1) if j != i1]
            row_index_2 = [i for i in range(m2) if i != i2]
            column_index_2 = [j for j in range(n2) if j != k1 and j != k2]
            a_mat = first_mat.matrix_from_rows_and_columns([j1, j2], column_index_1)
            b_mat = second_mat.matrix_from_rows_and_columns(row_index_2, [k1, k2])

            A = first_mat.matrix_from_rows_and_columns(row_index_1, column_index_1)
            B = second_mat.matrix_from_rows_and_columns(row_index_2, column_index_2)

            first_subrows = A.rows()
            second_subrows = B.rows()
            intersection1_mat = first_mat.matrix_from_rows_and_columns([j1, j2], [jk1, jk2])
            intersection2_mat = second_mat.matrix_from_rows_and_columns([j1k, j2k], [k1, k2])
            if intersection1_mat != intersection2_mat:
                raise ValueError('The intersection matrix is not the same!')
            lower_left_rows = (b_mat * intersection1_mat.inverse() * a_mat).rows()

            row_list = []
            for i in range(m1 - 2):
                r = list(first_subrows[i])
                u = [0 for j in range(n2 - 2)]
                r.extend(u)
                row_list.append(r)
            for i in range(m2 - 1):
                r = list(lower_left_rows[i])
                u = list(second_subrows[i])
                r.extend(u)
                row_list.append(r)
            M = Matrix_cmr_chr_sparse._from_data(row_list, immutable=False)

        result = M.is_three_sum(first_mat, second_mat,
                                first_rows_index=first_rows_index,
                                first_column_index=first_column_index,
                                first_intersection_columns=first_intersection_columns,
                                second_row_index=second_row_index,
                                second_columns_index=second_columns_index,
                                second_intersection_rows=second_intersection_rows,
                                sign_verify=sign_verify)
        if result is True:
            return M
        elif result is False:
            raise ValueError('The given two matrices and related indices '
                            'do not satisfy the rule for three sum!')
        else:
            return result[1]

    def y_sum(first_mat, second_mat,
                            first_rows_index=[-2, -1],
                            first_column_index=-1,
                            second_rows_index=[0, 1],
                            second_column_index=0,
                            algorithm="cmr",
                            sign_verify=False):
        r"""
        Return the Y-sum matrix constructed from the given matrices ``first_mat`` and
        ``second_mat``.
        In this case, the first matrix is
        `
            M_1 = \begin{bmatrix} A & a \\ c^T & 0 \\ c^T & \varepsilon \end{bmatrix}
        `
        and the second matrix is
        `
            M_2 = \begin{bmatrix} \varepsilon & b^T \\ 0 & b^T \\ d & D \end{bmatrix}.
        `
        Then the Y-sum is the matrix
        `
            M_1 \oplus_3 M_2 = \begin{bmatrix} A & a b^T \\ d c^T & D \end{bmatrix}.

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`delta_sum`, :meth:`three_sum`

        INPUT:

        - ``first_mat`` -- the first integer matrix `M_1`
        - ``second_mat`` -- the second integer matrix `M_2`
        - ``first_rows_index`` -- the row indices of `c^T` in `M_1`
        - ``first_column_index`` -- the column index of `a` in `M_1`
        - ``second_rows_index`` -- the row indices of `b^T` in `M_2`
        - ``second_column_index`` -- the column index of `d`  in `M_2`
        - ``algorithm`` -- ``"cmr"`` or ``"direct"``
          If ``algorithm="cmr"``, then use :meth:`_y_sum_cmr`;
          If ``algorithm="direct"``, then construct three sum directly.
          Both options will check the given two matrices and the related indices
          satisfying the requirements of 3-sum.
        - ``sign_verify`` -- boolean (default: ``False``);
          NotImplemented yet.

        OUTPUT: A :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[1, 1, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1],
            ....:                             [0, 0, 1, 0,-1],
            ....:                             [0, 1, 0, 1, 1],
            ....:                             [1, 0,-1, 1, 0],
            ....:                             [1, 0,-1, 1, 1],]); M1
            [ 1  1  0  0  0]
            [ 0 -1  0 -1  1]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  1]
            [ 1  0 -1  1  0]
            [ 1  0 -1  1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[ 1, 1, 1, 1,-1],
            ....:                             [ 0, 1, 1, 1,-1],
            ....:                             [-1, 1, 1, 0, 0],
            ....:                             [ 0, 0,-1, 0, 1],
            ....:                             [ 0, 1, 0,-1, 0],
            ....:                             [ 1, 0, 0, 0, 1]]); M2
            [ 1  1  1  1 -1]
            [ 0  1  1  1 -1]
            [-1  1  1  0  0]
            [ 0  0 -1  0  1]
            [ 0  1  0 -1  0]
            [ 1  0  0  0  1]
            sage: Matrix_cmr_chr_sparse.y_sum(M1, M2)
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]

            sage: M1.y_sum(M2, [-2, -1], 4, [0, 1], 1)
            Traceback (most recent call last):
            ...
            RuntimeError: Invalid matrix structure
            sage: M1.y_sum(M2, [-2, -1], 4, [0, 1], 1, algorithm="direct")
            Traceback (most recent call last):
            ...
            ValueError: The given two matrices and related indices do not satisfy the rule for y sum!
        """
        m1 = first_mat.nrows()
        n1 = first_mat.ncols()
        m2 = second_mat.nrows()
        n2 = second_mat.ncols()
        j1 = first_rows_index[0]
        j2 = first_rows_index[1]
        j1 = j1 if j1 >= 0 else m1 + j1
        j2 = j2 if j2 >= 0 else m1 + j2
        i1 = first_column_index
        i1 = i1 if i1 >= 0 else n1 + i1
        k1 = second_rows_index[0]
        k2 = second_rows_index[1]
        k1 = k1 if k1 >= 0 else m2 + k1
        k2 = k2 if k2 >= 0 else m2 + k2
        i2 = second_column_index
        i2 = i2 if i2 >= 0 else n2 + i2

        if algorithm == "cmr":
            M = Matrix_cmr_chr_sparse._y_sum_cmr(first_mat, second_mat,
                                                     [j1, j2], i1,
                                                     [k1, k2], i2)
        if algorithm == "direct":
            column_index_1 = [i for i in range(n1) if i != i1]
            row_index_1 = [j for j in range(m1) if j != j1 and j != j2]
            column_index_2 = [i for i in range(n2) if i != i2]
            row_index_2 = [j for j in range(m2) if j != k1 and j != k2]
            c = first_mat.matrix_from_rows_and_columns([j1], column_index_1)
            b = second_mat.matrix_from_rows_and_columns([k1], column_index_2)

            a = first_mat.matrix_from_rows_and_columns(row_index_1, [i1])
            d = second_mat.matrix_from_rows_and_columns(row_index_2, [i2])

            A = first_mat.matrix_from_rows_and_columns(row_index_1, column_index_1)
            D = second_mat.matrix_from_rows_and_columns(row_index_2, column_index_2)

            first_subrows = A.rows()
            second_subrows = D.rows()
            lower_left_rows = d.tensor_product(c).rows()
            upper_right_rows = a.tensor_product(b).rows()

            row_list = []
            for i in range(m1 - 2):
                r = list(first_subrows[i])
                u = list(upper_right_rows[i])
                r.extend(u)
                row_list.append(r)
            for i in range(m2 - 2):
                r = list(lower_left_rows[i])
                u = list(second_subrows[i])
                r.extend(u)
                row_list.append(r)
            M = Matrix_cmr_chr_sparse._from_data(row_list, immutable=False)

        result = M.is_y_sum(first_mat, second_mat,
                                first_rows_index=first_rows_index,
                                first_column_index=first_column_index,
                                second_rows_index=second_rows_index,
                                second_column_index=second_column_index,
                                sign_verify=sign_verify)
        if result is True:
            return M
        elif result is False:
            raise ValueError('The given two matrices and related indices '
                            'do not satisfy the rule for y sum!')
        else:
            return result[1]

    def _is_submatrix_rank0(self, rows, columns, entry_index=False):
        if entry_index:
            for i in rows:
                for j in columns:
                    if self[i, j] != 0:
                        return i, j
            return True
        return self.matrix_from_rows_and_columns(rows, columns) == 0

    def _is_submatrix_rank1(self, rows, columns):
        if self.matrix_from_rows_and_columns(rows, columns) == 0:
            return False
        i, j = self._is_submatrix_rank0(rows, columns, entry_index=True)
        Cij = self[i, j]
        Ci = self.matrix_from_rows_and_columns([i], columns)
        for r in rows:
            if r != i:
                Cr = self.matrix_from_rows_and_columns([r], columns)
                if Cr - (self[r, j] / Cij) * Ci != 0:
                    return False
        return True

    def _is_submatrix_rank2(self, rows, columns, special_rows=None, special_columns=None):
        if special_rows is None:
            special_rows = rows[:2]
        if special_columns is None:
            special_columns = columns[:2]
        Cik = self[special_rows[0], special_columns[0]]
        Cjk = self[special_rows[1], special_columns[0]]
        Cil = self[special_rows[0], special_columns[1]]
        Cjl = self[special_rows[1], special_columns[1]]
        det = Cik * Cjl - Cjk * Cil
        if det == 0:
            raise RuntimeError("The submatrix indexed by special rows and columns should be rank 2")

        Ci = self.matrix_from_rows_and_columns([special_rows[0]], columns)
        Cj = self.matrix_from_rows_and_columns([special_rows[1]], columns)
        for r in rows:
            if r not in special_rows:
                Cr = self.matrix_from_rows_and_columns([r], columns)
                Crk = self[r, special_columns[0]]
                Crl = self[r, special_columns[1]]
                if det * Cr - (Crk * Cjl - Crl * Cjk) * Ci - (- Crk * Cil + Crl * Cik) * Cj != 0:
                    return False
        return True

    def two_sum_decomposition(self, A_rows, A_columns):
        r"""
        Decompose the matrix into two children matrices using the two sum decomposition with specified indices.

        The input matrix `M` must have a 2-separation that can be reordered to look like
        `M = \begin{bmatrix} A & B \\ C & D \end{bmatrix}`,
        where `\text{rank}(B) + \text{rank}(C) = 1`.
        If `\text{rank}(B) = 0`, then the two components of the 2-sum are matrices
        `M_1 = \begin{bmatrix} A \\ c^T \end{bmatrix}`
        and
        `M_2 = \begin{bmatrix} d & D \end{bmatrix}`
        such that `C = d c^T` holds and such that
        `c^T` is an actual row of `M`.
        Otherwise, the two components of the 2-sum are matrices
        `M_1 = \begin{bmatrix} A & a \end{bmatrix}`
        and
        `M_2 = \begin{bmatrix} b^T \\ D \end{bmatrix}`
        such that `B = a b^T` holds and such
        that `a` is an actual column of `M`.

        .. SEEALSO:: :meth:`two_sum_decomposition`

        INPUT:

        - ``A_rows`` -- list of row indices for the submatrix A
        - ``A_columns`` -- list of column indices for the submatrix A

        OUTPUT: A tuple of two :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 9, 9, sparse=True),
            ....:                            [[ 1,  1,  0,  0,  0,  0,  0,  0,  0],
            ....:                             [ 1,  0,  1, -1, -1,  1,  1,  0,  0],
            ....:                             [ 0, -1,  1,  0,  1, -1, -1,  0,  0],
            ....:                             [ 0,  0, -1,  1,  0,  0,  0,  0,  0],
            ....:                             [ 0,  1,  1,  0, -1,  1,  1,  0,  0],
            ....:                             [ 0,  0,  0,  0,  1,  1,  1,  1, -1],
            ....:                             [ 0,  0,  0,  0,  0,  0, -1,  0,  1],
            ....:                             [ 0,  0,  0,  0,  1,  0,  0, -1,  0],
            ....:                             [ 0,  0,  0,  0,  0,  1,  0,  0,  1]]); M
            [ 1  1  0  0  0  0  0  0  0]
            [ 1  0  1 -1 -1  1  1  0  0]
            [ 0 -1  1  0  1 -1 -1  0  0]
            [ 0  0 -1  1  0  0  0  0  0]
            [ 0  1  1  0 -1  1  1  0  0]
            [ 0  0  0  0  1  1  1  1 -1]
            [ 0  0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0  0 -1  0]
            [ 0  0  0  0  0  1  0  0  1]
            sage: M1, M2 = M.two_sum_decomposition([0, 1, 2, 3, 4], [0, 1, 2, 3]); M1
            [ 1  1  0  0  0]
            [ 1  0  1 -1 -1]
            [ 0 -1  1  0  1]
            [ 0  0 -1  1  0]
            [ 0  1  1  0 -1]
            sage: M2
            [ 1 -1 -1  0  0]
            [ 1  1  1  1 -1]
            [ 0  0 -1  0  1]
            [ 1  0  0 -1  0]
            [ 0  1  0  0  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 9, 9, sparse=True),
            ....:                            [[ 1,  1,  0,  0,  0,  0,  0,  0,  0],
            ....:                             [ 1,  0,  1, -1, -1,  1,  1,  0,  0],
            ....:                             [ 0, -1,  1,  0,  1, -1, -1,  0,  0],
            ....:                             [ 0,  0, -1,  1,  0,  0,  0,  0,  0],
            ....:                             [ 0,  1,  1,  0, -1,  1,  1,  0,  0],
            ....:                             [ 0,  0,  0,  0,  1,  1,  1,  1, -1],
            ....:                             [ 0,  0,  0,  0,  0,  0, -1,  0,  1],
            ....:                             [ 0,  0,  0,  0,  1,  0,  0, -1,  0],
            ....:                             [ 0,  0,  0,  0,  0,  1,  0,  0,  1]]); M
            [ 1  1  0  0  0  0  0  0  0]
            [ 1  0  1 -1 -1  1  1  0  0]
            [ 0 -1  1  0  1 -1 -1  0  0]
            [ 0  0 -1  1  0  0  0  0  0]
            [ 0  1  1  0 -1  1  1  0  0]
            [ 0  0  0  0  1  1  1  1 -1]
            [ 0  0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0  0 -1  0]
            [ 0  0  0  0  0  1  0  0  1]
            sage: M1, M2 = M.two_sum_decomposition([5, 6, 7, 8], [4, 5, 6, 7, 8]); M1
            [ 1  1  1  1 -1]
            [ 0  0 -1  0  1]
            [ 1  0  0 -1  0]
            [ 0  1  0  0  1]
            [-1  1  1  0  0]
            sage: M2
            [ 0  1  1  0  0]
            [ 1  1  0  1 -1]
            [-1  0 -1  1  0]
            [ 0  0  0 -1  1]
            [ 1  0  1  1  0]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 9, 9, sparse=True),
            ....:                            [[ 1, 1, 0, 0, 0, 0, 0, 0, 0],
            ....:                             [ 0,-1, 1, 0,-1, 0, 0, 0, 0],
            ....:                             [ 0, 0,-1, 1, 0, 0, 0, 0, 0],
            ....:                             [ 0, 1, 1, 0, 1, 0, 0, 0, 0],
            ....:                             [ 1, 0, 1,-1, 1, 1,-1, 0, 0],
            ....:                             [ 1, 0, 1,-1, 1, 1, 1, 1,-1],
            ....:                             [-1, 0,-1, 1,-1, 0, 0, 0, 1],
            ....:                             [ 0, 0, 0, 0, 0, 1, 0,-1, 0],
            ....:                             [ 0, 0, 0, 0, 0, 0, 1, 0, 1]]); M
            [ 1  1  0  0  0  0  0  0  0]
            [ 0 -1  1  0 -1  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0  0]
            [ 0  1  1  0  1  0  0  0  0]
            [ 1  0  1 -1  1  1 -1  0  0]
            [ 1  0  1 -1  1  1  1  1 -1]
            [-1  0 -1  1 -1  0  0  0  1]
            [ 0  0  0  0  0  1  0 -1  0]
            [ 0  0  0  0  0  0  1  0  1]
            sage: M1, M2 = M.two_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3, 4]); M1
            [ 1  1  0  0  0]
            [ 0 -1  1  0 -1]
            [ 0  0 -1  1  0]
            [ 0  1  1  0  1]
            [ 1  0  1 -1  1]
            sage: M2
            [ 1  1 -1  0  0]
            [ 1  1  1  1 -1]
            [-1  0  0  0  1]
            [ 0  1  0 -1  0]
            [ 0  0  1  0  1]

        TESTS::

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0],
            ....:                             [ 0, -1,  0,  1],
            ....:                             [ 1,  0,  1,  1]]);
            sage: M.two_sum_decomposition([0, 1], [0, 1])
            Traceback (most recent call last):
            ...
            RuntimeError: rank(B) + rank(C) != 1
        """
        cdef CMR_CHRMAT *matrix = self._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef char epsilon
        cdef CMR_CHRMAT *first = NULL
        cdef CMR_CHRMAT *second = NULL

        C_rows = [i for i in range(matrix.numRows) if i not in A_rows]
        C_columns = A_columns
        B_rows = A_rows
        B_columns = [j for j in range(matrix.numColumns) if j not in A_columns]

        is_C_rank0 = self._is_submatrix_rank0(C_rows, C_columns)
        is_C_rank1 = self._is_submatrix_rank1(C_rows, C_columns)
        is_B_rank0 = self._is_submatrix_rank0(B_rows, B_columns)
        is_B_rank1 = self._is_submatrix_rank1(B_rows, B_columns)

        if not ((is_C_rank0 and is_B_rank1) or (is_C_rank1 and is_B_rank0)):
            raise RuntimeError("rank(B) + rank(C) != 1")

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_TWO

            for i in range(matrix.numRows):
                if i in A_rows:
                    if self.matrix_from_rows_and_columns([i], B_columns) == 0:
                        sepa.rowsFlags[i] = CMR_SEPA_FIRST
                    else:
                        sepa.rowsFlags[i] = CMR_SEPA_FIRST | CMR_SEPA_FLAG_RANK1
                else:
                    if self.matrix_from_rows_and_columns([i], C_columns) == 0:
                        sepa.rowsFlags[i] = CMR_SEPA_SECOND
                    else:
                        sepa.rowsFlags[i] = CMR_SEPA_SECOND | CMR_SEPA_FLAG_RANK1

            for j in range(matrix.numColumns):
                if j in A_columns:
                    if self.matrix_from_rows_and_columns(C_rows, [j]) == 0:
                        sepa.columnsFlags[j] = CMR_SEPA_FIRST
                    else:
                        sepa.columnsFlags[j] = CMR_SEPA_FIRST | CMR_SEPA_FLAG_RANK1
                else:
                    if self.matrix_from_rows_and_columns(B_rows, [j]) == 0:
                        sepa.columnsFlags[j] = CMR_SEPA_SECOND
                    else:
                        sepa.columnsFlags[j] = CMR_SEPA_SECOND | CMR_SEPA_FLAG_RANK1

            CMR_CALL(CMRtwosumDecomposeFirst(cmr, matrix, sepa, &first, NULL, NULL, NULL, NULL, NULL, NULL))
            CMR_CALL(CMRtwosumDecomposeSecond(cmr, matrix, sepa, &second, NULL, NULL, NULL, NULL, NULL, NULL))

            first_matrix = Matrix_cmr_chr_sparse._from_cmr(first)
            second_matrix = Matrix_cmr_chr_sparse._from_cmr(second)
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        return first_matrix, second_matrix

    def delta_sum_decomposition(self, A_rows, A_columns):
        """
        Decompose the matrix into two children matrices using the delta sum decomposition with specified indices.

        Let `M` denote the matrix given by ``delta_sum_mat``. Then
        `
            M = \begin{bmatrix}
            A & a b^T \\
            d c^T & D
            \end{bmatrix},
        `
        where `a, b, c, d` are vectors and `A, D` are submatrices.
        The two components of the delta sum `M_1` and `M_2`, given by ``first_mat`` and ``second_mat``, must be of the form
        `
            M_1 = \begin{bmatrix}
            A & a & a \\
            c^T & 0 & \varepsilon
            \end{bmatrix},
        `
        and
        `
            M_2 = \begin{bmatrix}
            \varepsilon & 0 & b^T \\
            d & d & D
            \end{bmatrix}.
        `

        INPUT:

        - ``A_rows`` -- list of row indices for the first matrix
        - ``A_columns`` -- list of column indices for the first matrix
        - ``special_rows`` -- list of special row index (default: last row)
        - ``special_columns`` -- list of two special column index (default: last column)

        OUTPUT: A tuple of two :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1, 1],
            ....:                             [0, 0, 1, 0,-1,-1],
            ....:                             [0, 1, 0, 1, 1, 1],
            ....:                             [1, 0,-1, 1, 0, 1],
            ....:                             [1, 0,-1, 1, 1, 1]]); M
            [ 1  1  0  0  0  0]
            [ 0 -1  0 -1  1  1]
            [ 0  0  1  0 -1 -1]
            [ 0  1  0  1  1  1]
            [ 1  0 -1  1  0  1]
            [ 1  0 -1  1  1  1]
            sage: M1, M2 = M.delta_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3]); M1
            [ 1  1  0  0  0  0]
            [ 0 -1  0 -1  1  1]
            [ 0  0  1  0 -1 -1]
            [ 0  1  0  1  1  1]
            [ 1  0 -1  1  0 -1]
            sage: M2
            [-1  0  1  1]
            [ 1  1  0  1]
            [ 1  1  1  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0],
            ....:                             [ 0,  1,  0,  1],
            ....:                             [ 0,  0,  1,  1]]);
            sage: M1, M2 = M.delta_sum_decomposition([0, 1], [0, 1]); M1
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0  1  0 -1]
            sage: M2
            [-1  0  1  0]
            [ 1  1  0  1]
            [ 0  0  1  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0, -1,  0],
            ....:                             [ 0,  1,  0,  1],
            ....:                             [ 0,  0,  1,  1]]);
            sage: M1, M2 = M.delta_sum_decomposition([0, 1], [0, 1]); M1
            [ 1  1  0  0]
            [ 1  0 -1 -1]
            [ 0  1  0  1]
            sage: M2
            [1 0 1 0]
            [1 1 0 1]
            [0 0 1 1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0],
            ....:                             [ 0, -1,  0,  1],
            ....:                             [ 0,  0,  1,  1]]);
            sage: M1, M2 = M.delta_sum_decomposition([0, 1], [0, 1]); M1
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0 -1  0  1]
            sage: M2
            [1 0 1 0]
            [1 1 0 1]
            [0 0 1 1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0, -1,  0],
            ....:                             [ 0, -1,  0,  1],
            ....:                             [ 0,  0,  1,  1]]);
            sage: M1, M2 = M.delta_sum_decomposition([0, 1], [0, 1]); M1
            [ 1  1  0  0]
            [ 1  0 -1 -1]
            [ 0 -1  0 -1]
            sage: M2
            [-1  0  1  0]
            [ 1  1  0  1]
            [ 0  0  1  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0],
            ....:                             [ 0, -1,  0,  1],
            ....:                             [ 1,  0,  1,  1]]);
            sage: M.delta_sum_decomposition([0, 1], [0, 1])
            Traceback (most recent call last):
            ...
            RuntimeError: The bottom left submatrix is not of rank 2
        """
        cdef CMR_CHRMAT *matrix = self._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef char epsilon
        cdef CMR_CHRMAT *first = NULL
        cdef CMR_CHRMAT *second = NULL

        C_rows = [i for i in range(matrix.numRows) if i not in A_rows]
        C_columns = A_columns
        if not self._is_submatrix_rank1(C_rows, C_columns):
            raise RuntimeError("The bottom left submatrix is not of rank 2")

        B_rows = A_rows
        B_columns = [j for j in range(matrix.numColumns) if j not in A_columns]
        if not self._is_submatrix_rank1(B_rows, B_columns):
            raise RuntimeError("The upper right submatrix is not of rank 1")

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_THREE_DISTRIBUTED_RANKS

            for i in range(matrix.numRows):
                if i in A_rows:
                    sepa.rowsFlags[i] = CMR_SEPA_FIRST
                else:
                    sepa.rowsFlags[i] = CMR_SEPA_SECOND

            for j in range(matrix.numColumns):
                if j in A_columns:
                    sepa.columnsFlags[j] = CMR_SEPA_FIRST
                else:
                    sepa.columnsFlags[j] = CMR_SEPA_SECOND

            CMR_CALL(CMRsepaFindBinaryRepresentatives(cmr, sepa, matrix, transpose, NULL, NULL))

            CMR_CALL(CMRdeltasumDecomposeEpsilon(cmr, matrix, transpose, sepa, &epsilon))
            CMR_CALL(CMRdeltasumDecomposeFirst(cmr, matrix, sepa, epsilon, &first, NULL, NULL, NULL, NULL, NULL, NULL))
            CMR_CALL(CMRdeltasumDecomposeSecond(cmr, matrix, sepa, epsilon, &second, NULL, NULL, NULL, NULL, NULL, NULL))

            first_matrix = Matrix_cmr_chr_sparse._from_cmr(first)
            second_matrix = Matrix_cmr_chr_sparse._from_cmr(second)
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        return first_matrix, second_matrix

    def three_sum_decomposition(self, first_rows_index, first_columns_index, special_rows=None, special_columns=None):
        """
        Decompose the matrix into two children matrices using the 3-sum decomposition with specified sepa.

        Let `M` denote the matrix given by ``three_sum_mat``. Then
        `
            M = \begin{bmatrix}
            A & 0 \\
            C & D
            \end{bmatrix},
        `
        where `\text{rank}(C) = 2`.
        The two components of the 3-sum `M_1` and `M_2`, given by ``first_mat`` and ``second_mat``, must be of the form
        `
            M_1 = \begin{bmatrix}
            A & 0 \\
            C_{i,\star} & 1 \\
            C_{j,\star} & \beta
            \end{bmatrix},
        `
        where `\beta \in \{-1,+1 \}`,
        and
        `
            M_2 = \begin{bmatrix}
            \gamma & 1 & 0^T \\
            C_{\star,k} & C_{\star,\ell} & D
            \end{bmatrix},
        `
        where `\gamma \in \{ -1,+1 \}` such that the matrix
        `
            N = \begin{bmatrix}
            \gamma & 1 & 0 \\
            C_{i,k} & C_{i,\ell} & 1 \\
            C_{j,k} & C_{j,\ell} & \beta
            \end{bmatrix}
        `
        is totally unimodular. The columns ``first_special_columns[0]`` and
        ``first_special_columns[1]`` indicate the columns of `M_1` that shall correspond to `C_{\star,k}` and
        `C_{\star,\ell}`, respectively. Similarly, the rows ``second_special_rows[1]`` and ``second_special_rows[2]``
        indicate the rows of `M_2` that shall correspond to `C_{i,\star}` and `C_{j,\star}`, respectively.

        The value of `\beta \in \{-1,+1\}` must be so that there exists a singular submatrix of `M_1` with exactly two nonzeros per row and per column that covers the bottom-right `\beta`-entry.

        INPUT:

        - ``first_rows_index`` -- list of row indices for the first matrix
        - ``first_columns_index`` -- list of column indices for the first matrix
        - ``special_rows`` -- list of two special row indices (default: last two rows)
        - ``special_columns`` -- list of two special column indices (default: last two columns)

        OUTPUT: A tuple of two :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[1, 0, 1, 1, 0, 0],
            ....:                             [0, 1, 1, 1, 0, 0],
            ....:                             [1, 0, 1, 0, 1, 1],
            ....:                             [0,-1, 0,-1, 1, 1],
            ....:                             [1, 0, 1, 0, 1, 0],
            ....:                             [0,-1, 0,-1, 0, 1]]); M
            [ 1  0  1  1  0  0]
            [ 0  1  1  1  0  0]
            [ 1  0  1  0  1  1]
            [ 0 -1  0 -1  1  1]
            [ 1  0  1  0  1  0]
            [ 0 -1  0 -1  0  1]
            sage: M1, M2 = M.three_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3], [2, 3], [2, 3]); M1
            [ 1  0  1  1  0]
            [ 0  1  1  1  0]
            [ 1  0  1  0  1]
            [ 0 -1  0 -1  1]
            sage: M2
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0 -1  1  1]
            [ 1  0  1  0]
            [ 0 -1  0  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[-1,  0, -1,  1, 0, 0],
            ....:                             [ 0, -1,  1, -1, 0, 0],
            ....:                             [-1,  0, -1,  0, 1, 1],
            ....:                             [ 0, -1,  0, -1, 1, 1],
            ....:                             [-1,  0, -1,  0, 1, 0],
            ....:                             [ 0, -1,  0, -1, 0, 1]]); M
            [-1  0 -1  1  0  0]
            [ 0 -1  1 -1  0  0]
            [-1  0 -1  0  1  1]
            [ 0 -1  0 -1  1  1]
            [-1  0 -1  0  1  0]
            [ 0 -1  0 -1  0  1]
            sage: M1, M2 = M.three_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3], [2, 3], [2, 3]); M1
            [-1  0 -1  1  0]
            [ 0 -1  1 -1  0]
            [-1  0 -1  0  1]
            [ 0 -1  0 -1  1]
            sage: M2
            [-1  1  0  0]
            [-1  0  1  1]
            [ 0 -1  1  1]
            [-1  0  1  0]
            [ 0 -1  0  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[ 1,  0,  1,  1,  0,  0],
            ....:                             [ 0,  1,  1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0,  1, -1],
            ....:                             [ 0,  1,  0,  1, -1,  1],
            ....:                             [ 1,  0,  1,  0,  1,  0],
            ....:                             [ 0,  1,  0,  1,  0,  1]]); M
            [ 1  0  1  1  0  0]
            [ 0  1  1  1  0  0]
            [ 1  0  1  0  1 -1]
            [ 0  1  0  1 -1  1]
            [ 1  0  1  0  1  0]
            [ 0  1  0  1  0  1]
            sage: M1, M2 = M.three_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3], [2, 3], [2, 3]); M1
            [ 1  0  1  1  0]
            [ 0  1  1  1  0]
            [ 1  0  1  0  1]
            [ 0  1  0  1 -1]
            sage: M2
            [ 1  1  0  0]
            [ 1  0  1 -1]
            [ 0  1 -1  1]
            [ 1  0  1  0]
            [ 0  1  0  1]

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[ 0,  1, -1,  0,  0,  0],
            ....:                             [ 0,  0,  1,  1,  0,  0],
            ....:                             [ 1,  0,  0,  1,  0,  0],
            ....:                             [ 0,  0,  0,  0,  1,  1],
            ....:                             [ 1, -1,  0,  0,  1,  0],
            ....:                             [ 0, -1,  0,  0,  0,  1]]); M
            [ 0  1 -1  0  0  0]
            [ 0  0  1  1  0  0]
            [ 1  0  0  1  0  0]
            [ 0  0  0  0  1  1]
            [ 1 -1  0  0  1  0]
            [ 0 -1  0  0  0  1]
            sage: M1, M2 = M.three_sum_decomposition([0, 1, 2, 4, 5], [0, 1, 2, 3], [4, 5], [0, 1]); M1
            [ 0  1 -1  0  0]
            [ 0  0  1  1  0]
            [ 1  0  0  1  0]
            [ 1 -1  0  0  1]
            [ 0 -1  0  0  1]
            sage: M2
            [-1  1  0  0]
            [ 0  0  1  1]
            [ 1 -1  1  0]
            [ 0 -1  0  1]

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1, 0,-1, 0],
            ....:                             [ 1, 1, 0, 0],
            ....:                             [ 0, 1, 0, 1],
            ....:                             [ 1, 1,-1, 1]])
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                            [[-1, 1, 0],
            ....:                             [ 1, 0, 1],
            ....:                             [ 1,-1, 1]])
            sage: M = Matrix_cmr_chr_sparse.three_sum(M1, M2); M
            [ 1  0 -1  0]
            [ 1  1  0  0]
            [ 0  1  0  1]
            [ 1  1 -1  1]
            sage: M.three_sum_decomposition(first_rows_index=[0,1,2,3], first_columns_index=[0,1,2], special_columns=[1,2])
            (
            [ 1  0 -1  0]
            [ 1  1  0  0]  [-1  1  0]
            [ 0  1  0  1]  [ 1  0  1]
            [ 1  1 -1  1], [ 1 -1  1]
            )

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0, 0,-1, 1, 0, 0],
            ....:                             [0, 1, 1, 0, 1, 0],
            ....:                             [1, 0, 1,-1, 1, 1],
            ....:                             [0,-1, 1, 0,-1, 1]]); M1
            [ 1  1  0  0  0  0]
            [ 0  0 -1  1  0  0]
            [ 0  1  1  0  1  0]
            [ 1  0  1 -1  1  1]
            [ 0 -1  1  0 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[-1, 1, 0, 0, 0],
            ....:                             [ 1, 0, 1,-1, 0],
            ....:                             [ 1,-1, 1, 1, 1],
            ....:                             [-1, 1, 0, 0, 0],
            ....:                             [ 0, 0, 1, 0,-1],
            ....:                             [ 0, 1, 0, 1, 0]]); M2
            [-1  1  0  0  0]
            [ 1  0  1 -1  0]
            [ 1 -1  1  1  1]
            [-1  1  0  0  0]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  0]
            sage: M = Matrix_cmr_chr_sparse.three_sum(M1, M2, first_intersection_columns=[2,1]); M
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [ 1  0  1 -1  1  1 -1  0]
            [ 0 -1  1  0 -1  1  1  1]
            [ 0  1 -1  0  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 1  1  0 -1  2  0  1  0]
            sage: M.is_three_sum(M1, M2, first_intersection_columns=[2,1], sign_verify=False)
            True
            sage: M.is_three_sum(M1, M2, first_intersection_columns=[2,1])
            True
            sage: C1, C2 = M.three_sum_decomposition(first_rows_index=[0,1,2,3,4], first_columns_index=[0,1,2,3,4], special_columns=[2,1])
            sage: C1 == M1
            True
            sage: C2
            [-1  1  0  0  0]
            [ 1  0  1 -1  0]
            [ 1 -1  1  1  1]
            [-1  1  0  0  0]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  0]

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 5, sparse=True),
            ....:                            [[ 0,  1, -1,  0, 0],
            ....:                             [ 0,  0,  1,  1, 0],
            ....:                             [ 1,  0,  0,  1, 0],
            ....:                             [ 1, -1,  0,  0, 1],
            ....:                             [ 0, -1,  0,  0, 1]])
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[-1,  1,  0, 0],
            ....:                             [ 0,  0,  1, 1],
            ....:                             [ 1, -1,  1, 0],
            ....:                             [ 0, -1,  0, 1]])
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[ 0,  1, -1,  0, 0, 0],
            ....:                             [ 0,  0,  1,  1, 0, 0],
            ....:                             [ 1,  0,  0,  1, 0, 0],
            ....:                             [ 0,  0,  0,  0, 1, 1],
            ....:                             [ 1, -1,  0,  0, 1, 0],
            ....:                             [ 0, -1,  0,  0, 0, 1]])
            sage: M.three_sum_decomposition(first_rows_index=[0, 1, 2, 4, 5], first_columns_index=[0, 1, 2, 3], special_columns=[0, 1]) == (M1, M2)
            True

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[ 0,  1, -1,  0, 0, 0],
            ....:                             [ 0,  0,  1,  1, 0, 0],
            ....:                             [ 1,  0,  0,  1, 0, 0],
            ....:                             [ 0,  0,  0,  0, 1, 1],
            ....:                             [ 1,  0, -1,  0, 1, 0],
            ....:                             [ 0, -1,  0,  0, 0, 1]])
            sage: M.three_sum_decomposition(first_rows_index=[0, 1, 2, 4, 5], first_columns_index=[0, 1, 2, 3], special_columns=[0, 1])
            Traceback (most recent call last):
            ...
            RuntimeError: User input error

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 5, sparse=True),
            ....:                            [[ 0,  1, -1,  0, 0],
            ....:                             [ 0,  0,  1,  1, 0],
            ....:                             [ 1,  0,  0,  1, 0],
            ....:                             [ 1, -1,  0,  0, 1],
            ....:                             [ 0, -1,  0,  0, 1]])
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[-1,  1,  0, 0],
            ....:                             [ 0,  0,  1, 1],
            ....:                             [ 1, -1,  1, 0],
            ....:                             [ 0, -1,  0, 1]])
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[ 0,  1, -1,  0, 0, 0],
            ....:                             [ 0,  0,  1,  1, 0, 0],
            ....:                             [ 1,  0,  0,  1, 0, 0],
            ....:                             [ 0,  0,  1,  0, 1, 1],
            ....:                             [ 1, -1,  0,  0, 1, 0],
            ....:                             [ 0, -1,  0,  0, 0, 1]])
            sage: M.three_sum_decomposition(first_rows_index=[0, 1, 2, 4, 5], first_columns_index=[0, 1, 2, 3], special_columns=[0, 1])
            Traceback (most recent call last):
            ...
            RuntimeError: The bottom left submatrix is not of rank 2
            sage: M.is_three_sum(M1, M2, [4, 5], -1, [0, 1], 0, [0, 1], [2, 3])
            False

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[ 0,  1, -1,  0, 0, 0],
            ....:                             [ 0,  0,  1,  1, 0, 0],
            ....:                             [ 1,  0,  0,  1, 0, 0],
            ....:                             [ 0,  0,  0,  0, 1, 1],
            ....:                             [ 1, -1,  1,  0, 1, 0],
            ....:                             [ 0, -1, -1,  0, 0, 1]])
            sage: C1, C2 = M.three_sum_decomposition(first_rows_index=[0, 1, 2, 4, 5], first_columns_index=[0, 1, 2, 3], special_columns=[0, 1]); (C1, C2)
            (
            [ 0  1 -1  0  0]
            [ 0  0  1  1  0]  [-1  1  0  0]
            [ 1  0  0  1  0]  [ 0  0  1  1]
            [ 1 -1  1  0  1]  [ 1 -1  1  0]
            [ 0 -1 -1  0  1], [ 0 -1  0  1]
            )
            sage: M.is_three_sum(C1, C2, [3, 4], -1, [0, 1], 0, [0, 1], [2, 3])
            True
        """
        cdef CMR_CHRMAT *matrix = self._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef size_t specialRows[2]
        cdef size_t specialColumns[2]
        cdef char gamma, beta
        cdef CMR_CHRMAT *first = NULL
        cdef CMR_CHRMAT *second = NULL

        if special_rows is None:
            special_rows = [first_rows_index[-2], first_rows_index[-1]]
        if special_columns is None:
            special_columns = [first_columns_index[-2], first_columns_index[-1]]
        specialRows[0] = special_rows[0]
        specialRows[1] = special_rows[1]
        specialColumns[0] = special_columns[0]
        specialColumns[1] = special_columns[1]

        C_rows = [i for i in range(matrix.numRows) if i not in first_rows_index or i in special_rows]
        C_columns = first_columns_index
        if not self._is_submatrix_rank2(C_rows, C_columns, special_rows, special_columns):
            raise RuntimeError("The bottom left submatrix is not of rank 2")

        B_rows = [i for i in first_rows_index if i not in special_rows]
        B_columns = [j for j in range(matrix.numColumns) if j not in C_columns]
        if not self._is_submatrix_rank0(B_rows, B_columns):
            raise RuntimeError("The upper right submatrix is not zero")

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_THREE_CONCENTRATED_RANK

            for i in range(matrix.numRows):
                if i in first_rows_index and i not in special_rows:
                    sepa.rowsFlags[i] = CMR_SEPA_FIRST
                else:
                    sepa.rowsFlags[i] = CMR_SEPA_SECOND

            for j in range(matrix.numColumns):
                if j in first_columns_index:
                    sepa.columnsFlags[j] = CMR_SEPA_FIRST
                else:
                    sepa.columnsFlags[j] = CMR_SEPA_SECOND
            CMR_CALL(CMRsepaFindBinaryRepresentatives(cmr, sepa, matrix, transpose, NULL, NULL))

            CMR_CALL(CMRthreesumDecomposeSignConnecting(cmr, matrix, transpose, sepa, specialRows, specialColumns, &gamma, &beta))
            CMR_CALL(CMRthreesumDecomposeFirst(cmr, matrix, sepa, specialRows, specialColumns, beta, &first, NULL, NULL, NULL, NULL, NULL, NULL))
            CMR_CALL(CMRthreesumDecomposeSecond(cmr, matrix, sepa, specialRows, specialColumns, gamma, &second, NULL, NULL, NULL, NULL, NULL, NULL))

            first_matrix = Matrix_cmr_chr_sparse._from_cmr(first)
            second_matrix = Matrix_cmr_chr_sparse._from_cmr(second)
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        return first_matrix, second_matrix

    def y_sum_decomposition(self, A_rows, A_columns):
        """
        Decompose the matrix into two children matrices using the Y-sum decomposition with specified indices.

        Let `M` denote the matrix given by ``y_sum_mat``. Then
        `
            M = \begin{bmatrix}
            A & a b^T \\
            d c^T & D
            \end{bmatrix},
        `
        where `a, b, c, d` are vectors and `A, D` are submatrices.
        The two components of the Y-sum `M_1` and `M_2`, given by ``first_mat`` and ``second_mat``, must be of the form
        `
            M_1 = \begin{bmatrix}
            A & a \\
            c^T & 0 \\
            c^T & \varepsilon
            \end{bmatrix},
        `
        and
        `
            M_2 = \begin{bmatrix}
            \varepsilon & b^T \\
            0 & b^T \\
            d & D
            \end{bmatrix}.
        `

        INPUT:

        - ``A_rows`` -- list of row indices for the first matrix
        - ``A_columns`` -- list of column indices for the first matrix
        - ``special_rows`` -- list of two special row indices (default: last two rows)
        - ``special_columns`` -- list of special column index (default: last column)

        OUTPUT: A tuple of two :class:`Matrix_cmr_chr_sparse`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1, 1],
            ....:                             [0, 0, 1, 0,-1,-1],
            ....:                             [0, 1, 0, 1, 1, 1],
            ....:                             [1, 0,-1, 1, 0, 1],
            ....:                             [1, 0,-1, 1, 1, 1]]); M
            [ 1  1  0  0  0  0]
            [ 0 -1  0 -1  1  1]
            [ 0  0  1  0 -1 -1]
            [ 0  1  0  1  1  1]
            [ 1  0 -1  1  0  1]
            [ 1  0 -1  1  1  1]
            sage: M1, M2 = M.y_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3]); M1
            [ 1  1  0  0  0]
            [ 0 -1  0 -1  1]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  1]
            [ 1  0 -1  1  0]
            [ 1  0 -1  1  1]
            sage: M2
            [1 1 1]
            [0 1 1]
            [1 0 1]
            [1 1 1]
        """
        cdef CMR_CHRMAT *matrix = self._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef char epsilon
        cdef CMR_CHRMAT *first = NULL
        cdef CMR_CHRMAT *second = NULL

        C_rows = [i for i in range(matrix.numRows) if i not in A_rows]
        C_columns = A_columns
        if not self._is_submatrix_rank1(C_rows, C_columns):
            raise RuntimeError("The bottom left submatrix is not of rank 2")

        B_rows = A_rows
        B_columns = [j for j in range(matrix.numColumns) if j not in A_columns]
        if not self._is_submatrix_rank1(B_rows, B_columns):
            raise RuntimeError("The upper right submatrix is not of rank 1")

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_THREE_DISTRIBUTED_RANKS

            for i in range(matrix.numRows):
                if i in A_rows:
                    sepa.rowsFlags[i] = CMR_SEPA_FIRST
                else:
                    sepa.rowsFlags[i] = CMR_SEPA_SECOND

            for j in range(matrix.numColumns):
                if j in A_columns:
                    sepa.columnsFlags[j] = CMR_SEPA_FIRST
                else:
                    sepa.columnsFlags[j] = CMR_SEPA_SECOND

            CMR_CALL(CMRsepaFindBinaryRepresentatives(cmr, sepa, matrix, transpose, NULL, NULL))

            CMR_CALL(CMRysumDecomposeEpsilon(cmr, matrix, transpose, sepa, &epsilon))
            CMR_CALL(CMRysumDecomposeFirst(cmr, matrix, sepa, epsilon, &first, NULL, NULL, NULL, NULL, NULL, NULL))
            CMR_CALL(CMRysumDecomposeSecond(cmr, matrix, sepa, epsilon, &second, NULL, NULL, NULL, NULL, NULL, NULL))

            first_matrix = Matrix_cmr_chr_sparse._from_cmr(first)
            second_matrix = Matrix_cmr_chr_sparse._from_cmr(second)
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        return first_matrix, second_matrix

    def is_delta_sum(three_sum_mat, first_mat, second_mat,
                               first_row_index=-1,
                               first_columns_index=[-2, -1],
                               second_row_index=0,
                               second_columns_index=[0, 1],
                               sign_verify=True):
        r"""
        Check whether ``first_mat`` and ``second_mat`` form ``three_sum_mat``
        via the 3-sum operation.
        Assume that ``three_sum_strategy="distributed_ranks"`` or ``"Wide_Wide"``.
        If ``sign_verify=True``, also check whether the 3-sum satisfies that
        ``three_sum_mat`` is totally unimodular, if and only if,
        ``first_mat`` and ``second_mat`` are both totally unimodular.

        Let `M_1` and `M_2` denote the matrices given by ``first_mat`` and ``second_mat``. If ``first_row_index``
        indexes a row vector `c^T` and ``first_columns_index`` indexes two column vectors `a` of ``first_mat``,
        then ``second_row_index`` indexes a row vector `b` and ``second_columns_index`` indexes two column
        vectors `d` of ``second_mat``. In this case, the first matrix is
        `
            M_1 = \begin{bmatrix} A & a & a \\ c^T & 0 & \varepsilon \end{bmatrix}
        `
        and the second matrix is
        `
            M_2 = \begin{bmatrix} \varepsilon & 0 & b^T \\ d & d & D \end{bmatrix}.
        `
        Then the Seymour/Schrijver 3-sum is the matrix
        `
            M_1 \oplus_3 M_2 = \begin{bmatrix} A & a b^T \\ d c^T & D \end{bmatrix}.

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        The value of `\varepsilon \in \{-1,+1\}` must be so that there exists a singular submatrix of `M_1` with exactly two nonzeros per row and per column that covers the top-left `\varepsilon`-entry.
        The signs of `\varepsilon` are determined by
        a shortest path between two sets of vertices in the bipartite graph,
        where the sets of vertices corresponding to the nonzero
        row and column indices of `c^T, a`,
        and the bipartite graph consists of vertices corresponding to the rows
        and columns of `M`, and edges corresponding to the nonzero entry.
        between the rows and columns of `M`, see [Sch1986]_, Ch. 20.3.

        .. SEEALSO:: :meth:`delta_sum`, :meth:`is_three_sum`
                     :meth:`is_totally_unimodular`

        INPUT:

        - ``three_sum_mat`` -- the large integer matrix `M`
        - ``first_mat`` -- the first integer matrix `M_1`
        - ``second_mat`` -- the second integer matrix `M_2`
        - ``first_row_index`` -- the row index of `c^T` in `M_1`
        - ``first_columns_index`` -- the column indices of `a` in `M_1`
        - ``second_row_index`` -- the row index of `b^T` in `M_2`
        - ``second_columns_index`` -- the column indices of `d`  in `M_2`
        - ``sign_verify`` -- boolean (default: ``True``);
          whether to check the sign correctness of `\epsilon_1` and `\epsilon_2`.

        OUTPUT: boolean, or (boolean, string)

        If it is False only because of the sign, then also output the correct sign.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1, 1],
            ....:                             [0, 0, 1, 0,-1,-1],
            ....:                             [0, 1, 0, 1, 1, 1],
            ....:                             [1, 0,-1, 1, 0, 1],]); M1
            [ 1  1  0  0  0  0]
            [ 0 -1  0 -1  1  1]
            [ 0  0  1  0 -1 -1]
            [ 0  1  0  1  1  1]
            [ 1  0 -1  1  0  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[ 1, 0, 1, 1, 1,-1],
            ....:                             [-1,-1, 1, 1, 0, 0],
            ....:                             [ 0, 0, 0,-1, 0, 1],
            ....:                             [ 0, 0, 1, 0,-1, 0],
            ....:                             [ 1, 1, 0, 0, 0, 1]]); M2
            [ 1  0  1  1  1 -1]
            [-1 -1  1  1  0  0]
            [ 0  0  0 -1  0  1]
            [ 0  0  1  0 -1  0]
            [ 1  1  0  0  0  1]
            sage: M = Matrix_cmr_chr_sparse.delta_sum(M1, M2); M
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]
            sage: M.is_delta_sum(M1, M2, sign_verify=False)
            True
            sage: M.is_delta_sum(M1, M2)
            True

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 5, sparse=True),
            ....:                            [[ 0, 0, 1,-1,-1],
            ....:                             [ 1, 1, 1, 0, 0],
            ....:                             [ 0, 1, 0, 1, 1],
            ....:                             [-1, 0,-1, 0, 1]]); M1
            [ 0  0  1 -1 -1]
            [ 1  1  1  0  0]
            [ 0  1  0  1  1]
            [-1  0 -1  0  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 5, sparse=True),
            ....:                            [[ 1, 0, 1,-1, 0],
            ....:                             [ 0, 0, 1, 0, 1],
            ....:                             [-1,-1, 0, 1, 1],
            ....:                             [-1,-1, 0, 0, 1]]); M2
            [ 1  0  1 -1  0]
            [ 0  0  1  0  1]
            [-1 -1  0  1  1]
            [-1 -1  0  0  1]
            sage: M = Matrix_cmr_chr_sparse.delta_sum(M1, M2); M
            [ 0  0  1 -1  1  0]
            [ 1  1  1  0  0  0]
            [ 0  1  0  1 -1  0]
            [ 0  0  0  1  0  1]
            [ 1  0  1  0  1  1]
            [ 1  0  1  0  0  1]
            sage: Matrix_cmr_chr_sparse.is_delta_sum(M, M1, M2)
            (False,
             'sign_1 in second_mat should be -1. sign_2 in first_mat should be -1. ')

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0],
            ....:                             [ 0,  1,  0,  1],
            ....:                             [ 0,  0,  1,  1]]);
            sage: M1, M2 = M.delta_sum_decomposition([0, 1], [0, 1]); M1
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0  1  0 -1]
            sage: M2
            [-1  0  1  0]
            [ 1  1  0  1]
            [ 0  0  1  1]
            sage: M.is_totally_unimodular()
            True
            sage: Matrix_cmr_chr_sparse.is_delta_sum(M, M1, M2)
            True
        """
        if not isinstance(first_columns_index, (list, tuple)) or len(first_columns_index) != 2:
            raise ValueError('The index of two columns needs to be given!')
        if not isinstance(second_columns_index, (list, tuple)) or len(second_columns_index) != 2:
            raise ValueError('The index of two columns needs to be given!')

        m1 = first_mat.nrows()
        n1 = first_mat.ncols()
        m2 = second_mat.nrows()
        n2 = second_mat.ncols()
        m = three_sum_mat.nrows()
        n = three_sum_mat.ncols()
        if m != (m1 + m2 - 2): # The number of rows should match
            return False
        if n != (n1 + n2 - 4): # The number of columns should match
            return False

        # Check the extra two columns for a2 and b1
        j1 = first_columns_index[0]
        j2 = first_columns_index[1]
        j1 = j1 if j1 >= 0 else n1 + j1
        j2 = j2 if j2 >= 0 else n1 + j2
        i1 = first_row_index
        i1 = i1 if i1 >= 0 else m1 + i1
        row_index_1 = [i for i in range(m1) if i != i1]
        for i in row_index_1:
            if first_mat[i, j1] != first_mat[i, j2]:
                return False
        sign_2 = first_mat[i1, j2] if first_mat[i1, j1] == 0 else first_mat[i1, j1]
        if sign_2 == 0:
            return False

        k1 = second_columns_index[0]
        k2 = second_columns_index[1]
        k1 = k1 if k1 >= 0 else n2 + k1
        k2 = k2 if k2 >= 0 else n2 + k2
        i2 = second_row_index
        i2 = i2 if i2 >= 0 else m2 + i2
        row_index_2 = [i for i in range(m2) if i != i2]
        for i in row_index_2:
            if second_mat[i, k1] != second_mat[i, k2]:
                return False
        sign_1 = second_mat[i2, k2] if second_mat[i2, k1] == 0 else second_mat[i2, k1]
        if sign_1 == 0:
            return False

        # Check whether the result comes from the three sum
        column_index_1 = [j for j in range(n1) if j != j1 and j != j2]
        for i in range(m1 - 1):
            for j in range(n1 - 2):
                if first_mat[row_index_1[i], column_index_1[j]] != three_sum_mat[i, j]:
                    return False
        column_index_2 = [j for j in range(n2) if j != k1 and j != k2]
        for i in range(m2 - 1):
            for j in range(n2 - 2):
                if second_mat[row_index_2[i], column_index_2[j]] != three_sum_mat[m1 - 1 + i, n1 - 2 + j]:
                    return False
        for i in range(m1 - 1):
            for j in range(n2 - 2):
                rank1_entry = first_mat[row_index_1[i], j1] * second_mat[i2, column_index_2[j]]
                if rank1_entry != three_sum_mat[i, n1 - 2 + j]:
                    return False
        for i in range(m2 - 1):
            for j in range(n1 - 2):
                rank1_entry = first_mat[i1, column_index_1[j]] * second_mat[row_index_2[i], k1]
                if rank1_entry != three_sum_mat[m1 - 1 + i, j]:
                    return False

        if sign_verify is not True:
            return True
        # Check the sign
        cdef CMR_CHRMAT *matrix = three_sum_mat._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef char epsilon

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_THREE_DISTRIBUTED_RANKS

            for i in range(matrix.numRows):
                if i in range(m1 - 1):
                    sepa.rowsFlags[i] = CMR_SEPA_FIRST
                else:
                    sepa.rowsFlags[i] = CMR_SEPA_SECOND

            for j in range(matrix.numColumns):
                if j in range(n1 - 2):
                    sepa.columnsFlags[j] = CMR_SEPA_FIRST
                else:
                    sepa.columnsFlags[j] = CMR_SEPA_SECOND

            CMR_CALL(CMRsepaFindBinaryRepresentatives(cmr, sepa, matrix, transpose, NULL, NULL))

            CMR_CALL(CMRdeltasumDecomposeEpsilon(cmr, matrix, transpose, sepa, &epsilon))
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        msg = ""
        if (first_mat[i1, j2] - epsilon) % 4 != 0:
            msg += f'sign_1 in second_mat should be {epsilon}. '
        if (second_mat[i2, k1] - epsilon) % 4 != 0:
            msg += f'sign_2 in first_mat should be {epsilon}. '
        if msg:
            return False, msg
        return True

    def is_three_sum(three_sum_mat, first_mat, second_mat,
                                 first_rows_index=[-2, -1],
                                 first_column_index=-1,
                                 first_intersection_columns=[-3, -2],
                                 second_row_index=0,
                                 second_columns_index=[0, 1],
                                 second_intersection_rows=[1, 2],
                                 sign_verify=True):
        r"""
        Check whether ``first_mat`` and ``second_mat`` form ``three_sum_mat``
        via the 3-sum operation with the given special rows and columns.
        Assume that ``three_sum_strategy="concentrated_ranks"`` or ``"Mixed_Mixed"``.
        If ``sign_verify=True``, also check whether the 3-sum satisfies that
        ``three_sum_mat`` is totally unimodular, if and only if,
        ``first_mat`` and ``second_mat`` are both totally unimodular.

        Let `M` denote the matrix given by ``three_sum_mat``. Then
        `
            M = \begin{bmatrix}
            A & 0 \\
            C & D
            \end{bmatrix},
        `
        where `\text{rank}(C) = 2`.
        The two components of the 3-sum `M_1` and `M_2`, given by ``first_mat`` and ``second_mat``, must be of the form
        `
            M_1 = \begin{bmatrix}
            A & 0 \\
            C_{i,\star} & 1 \\
            C_{j,\star} & \beta
            \end{bmatrix},
        `
        where `\beta \in \{-1,+1 \}`,
        and
        `
            M_2 = \begin{bmatrix}
            \gamma & 1 & 0^T \\
            C_{\star,k} & C_{\star,\ell} & D
            \end{bmatrix},
        `
        where `\gamma \in \{ -1,+1 \}` such that the matrix
        `
            N = \begin{bmatrix}
            \gamma & 1 & 0 \\
            C_{i,k} & C_{i,\ell} & 1 \\
            C_{j,k} & C_{j,\ell} & \beta
            \end{bmatrix}
        `
        is totally unimodular. The columns ``first_special_columns[0]`` and
        ``first_special_columns[1]`` indicate the columns of `M_1` that shall correspond to `C_{\star,k}` and
        `C_{\star,\ell}`, respectively. Similarly, the rows ``second_special_rows[1]`` and ``second_special_rows[2]``
        indicate the rows of `M_2` that shall correspond to `C_{i,\star}` and `C_{j,\star}`, respectively.

        The value of `\beta \in \{-1,+1\}` must be so that there exists a singular submatrix of `M_1` with exactly two nonzeros per row and per column that covers the bottom-right `\beta`-entry.

        The terminology "3-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`is_delta_sum`, :meth:`three_sum`
                     :meth:`is_totally_unimodular`

        INPUT:

        - ``three_sum_mat`` -- the large integer matrix `M`
        - ``first_mat`` -- the first integer matrix `M_1`
        - ``second_mat`` -- the second integer matrix `M_2`
        - ``first_rows_index`` -- the indices of rows `a_1^T` and `a_2^T` in `M_1`
        - ``first_column_index`` -- the index of the column with `\epsilon_2` in `M_1`
        - ``second_row_index`` -- the index of the row with `\epsilon_1` in `M_2`
        - ``second_columns_index`` -- the indices of columns `b_1` and `b_2`  in `M_2`
        - ``sign_verify`` -- boolean (default: ``True``);
          whether to check the sign correctness of `\epsilon_1` and `\epsilon_2`.

        OUTPUT: boolean, or (boolean, string)

        If it is False only because of the sign, then also output the correct sign.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 6, sparse=True),
            ....:                            [[1, 1, 0, 0, 0, 0],
            ....:                             [0, 0,-1, 1, 0, 0],
            ....:                             [0, 1, 1, 0, 1, 0],
            ....:                             [1, 0, 1,-1, 1, 1],
            ....:                             [0,-1, 1, 0,-1, 1]]); M1
            [ 1  1  0  0  0  0]
            [ 0  0 -1  1  0  0]
            [ 0  1  1  0  1  0]
            [ 1  0  1 -1  1  1]
            [ 0 -1  1  0 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[ 1,-1, 0, 0, 0],
            ....:                             [ 1, 0, 1,-1, 0],
            ....:                             [ 1,-1, 1, 1, 1],
            ....:                             [-1, 1, 0, 0, 0],
            ....:                             [ 0, 0, 1, 0,-1],
            ....:                             [ 0, 1, 0, 1, 0]]); M2
            [ 1 -1  0  0  0]
            [ 1  0  1 -1  0]
            [ 1 -1  1  1  1]
            [-1  1  0  0  0]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  0]
            sage: M = Matrix_cmr_chr_sparse.three_sum(M1, M2, first_intersection_columns=[2,1]); M
            [ 1  1  0  0  0  0  0  0]
            [ 0  0 -1  1  0  0  0  0]
            [ 0  1  1  0  1  0  0  0]
            [ 1  0  1 -1  1  1 -1  0]
            [ 0 -1  1  0 -1  1  1  1]
            [ 0  1 -1  0  1  0  0  0]
            [ 0  0  0  0  0  1  0 -1]
            [ 1  1  0 -1  2  0  1  0]
            sage: M.is_three_sum(M1, M2, first_intersection_columns=[2,1], sign_verify=False)
            True
            sage: M.is_three_sum(M1, M2, first_intersection_columns=[2,1])
            True

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 5, sparse=True),
            ....:                            [[ 1, 0, 1, 1, 0],
            ....:                             [ 0, 1, 1, 1, 0],
            ....:                             [ 1, 0, 1, 0, 1],
            ....:                             [ 0,-1, 0,-1, 1]]); M1
            [ 1  0  1  1  0]
            [ 0  1  1  1  0]
            [ 1  0  1  0  1]
            [ 0 -1  0 -1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 4, sparse=True),
            ....:                            [[ 1, 1, 0, 0],
            ....:                             [ 1, 0, 1, 1],
            ....:                             [ 0,-1, 1, 1],
            ....:                             [ 1, 0, 1, 0],
            ....:                             [ 0,-1, 0, 1]]); M2
            [ 1  1  0  0]
            [ 1  0  1  1]
            [ 0 -1  1  1]
            [ 1  0  1  0]
            [ 0 -1  0  1]
            sage: M = Matrix_cmr_chr_sparse.three_sum(M1, M2); M
            [ 1  0  1  1  0  0]
            [ 0  1  1  1  0  0]
            [ 1  0  1  0  1  1]
            [ 0 -1  0 -1  1  1]
            [ 1  0  1  0  1  0]
            [ 0 -1  0 -1  0  1]
            sage: Matrix_cmr_chr_sparse.is_three_sum(M, M1, M2)
            True

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1, 0,-1, 0],
            ....:                             [ 1, 1, 0, 0],
            ....:                             [ 0, 1, 0, 1],
            ....:                             [ 1, 1,-1, 1]])
            sage: M1.is_totally_unimodular()
            True
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                            [[ 1,-1, 0],
            ....:                             [ 1, 0, 1],
            ....:                             [ 1,-1, 1]])
            sage: M2.is_totally_unimodular()
            True
            sage: M = Matrix_cmr_chr_sparse.three_sum(M1, M2); M
            [ 1  0 -1  0]
            [ 1  1  0  0]
            [ 0  1  0  1]
            [ 1  1 -1  1]
            sage: M.is_totally_unimodular()
            True
            sage: Matrix_cmr_chr_sparse.is_three_sum(M, M1, M2)
            True
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                            [[ 1, 1, 0],
            ....:                             [ 1, 0, 1],
            ....:                             [ 1,-1, 1]])
            sage: M2.is_totally_unimodular()
            False
            sage: Matrix_cmr_chr_sparse.is_three_sum(M, M1, M2)
            (False, 'gamma in second_mat should be -1. ')
        """
        if not isinstance(first_rows_index, (list, tuple)) or len(first_rows_index) != 2:
            raise ValueError('The index of two columns needs to be given!')
        if not isinstance(second_columns_index, (list, tuple)) or len(second_columns_index) != 2:
            raise ValueError('The index of two columns needs to be given!')

        m1 = first_mat.nrows()
        n1 = first_mat.ncols()
        m2 = second_mat.nrows()
        n2 = second_mat.ncols()
        m = three_sum_mat.nrows()
        n = three_sum_mat.ncols()
        if m != (m1 + m2 - 3): # The number of rows should match
            return False
        if n != (n1 + n2 - 3): # The number of columns should match
            return False

        # Check whether the extra column of M1 is zero except the two extra rows
        j1 = first_rows_index[0]
        j2 = first_rows_index[1]
        j1 = j1 if j1 >= 0 else m1 + j1
        j2 = j2 if j2 >= 0 else m1 + j2
        i1 = first_column_index
        i1 = i1 if i1 >= 0 else n1 + i1
        row_index_1 = [i for i in range(m1) if i != j1 and i != j2]
        for i in row_index_1:
            if first_mat[i, i1] != 0:
                return False
        if first_mat[j1, i1] == 0 or first_mat[j2, i1] == 0:
            return False
        # Check whether the extra row of M2 is zero except the two extra columns
        k1 = second_columns_index[0]
        k2 = second_columns_index[1]
        k1 = k1 if k1 >= 0 else n2 + k1
        k2 = k2 if k2 >= 0 else n2 + k2
        i2 = second_row_index
        i2 = i2 if i2 >= 0 else m2 + i2
        column_index_2 = [j for j in range(n2) if j != k1 and j != k2]
        for j in column_index_2:
            if second_mat[i2, j] != 0:
                return False
        if second_mat[i2, k1] == 0 or second_mat[i2, k2] == 0:
            return False

        # Check whether the intersection of two matrices are identical
        jk1, jk2 = first_intersection_columns
        jk1 = jk1 if jk1 >= 0 else n1 + jk1
        jk2 = jk2 if jk2 >= 0 else n1 + jk2
        j1k, j2k = second_intersection_rows
        j1k = j1k if j1k >= 0 else m2 + k1
        j2k = j2k if j2k >= 0 else m2 + k2
        intersection1_mat = first_mat.matrix_from_rows_and_columns([j1, j2], [jk1, jk2])
        intersection2_mat = second_mat.matrix_from_rows_and_columns([j1k, j2k], [k1, k2])
        if intersection1_mat != intersection2_mat:
            return False, "the intersection matrices in the two matrices are inconsistent"

        # Check whether the result comes from the three sum
        column_index_1 = [j for j in range(n1) if j != i1]
        for i in range(m1 - 2):
            for j in range(n1 - 1):
                if first_mat[row_index_1[i], column_index_1[j]] != three_sum_mat[i, j]:
                    return False, "A in the first matrix is inconsistent with the three sum"
        row_index_2 = [i for i in range(m2) if i != i2]
        for i in range(m2 - 1):
            for j in range(n2 - 2):
                if second_mat[row_index_2[i], column_index_2[j]] != three_sum_mat[m1 - 2 + i, n1 - 1 + j]:
                    return False, "B in the second matrix is inconsistent with the three sum"
        for i in range(m1 - 2):
            for j in range(n2 - 2):
                if three_sum_mat[i, n1 - 1 + j] != 0:
                    return False, "the upper-right corner in the three sum is not 0"
        a_mat = first_mat.matrix_from_rows_and_columns([j1, j2], column_index_1)
        b_mat = second_mat.matrix_from_rows_and_columns(row_index_2, [k1, k2])
        rank2_block = b_mat * intersection1_mat.inverse() * a_mat
        for i in range(m2 - 1):
            for j in range(n1 - 1):
                if rank2_block[i, j] != three_sum_mat[m1 - 2 + i, j]:
                    return False, "C in the three sum is inconsistent with the two matrices"

        if sign_verify is not True:
            return True
        # Check the sign
        cdef CMR_CHRMAT *matrix = three_sum_mat._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef size_t specialRows[2]
        cdef size_t specialColumns[2]
        cdef char gamma, beta

        special_rows = [m1 - 2 + j1k - 1, m1 - 2 + j2k - 1]
        special_columns = [jk1, jk2]
        specialRows[0] = special_rows[0]
        specialRows[1] = special_rows[1]
        specialColumns[0] = special_columns[0]
        specialColumns[1] = special_columns[1]
        Cik = three_sum_mat[special_rows[0], special_columns[0]]
        Cjk = three_sum_mat[special_rows[1], special_columns[0]]
        Cil = three_sum_mat[special_rows[0], special_columns[1]]
        Cjl = three_sum_mat[special_rows[1], special_columns[1]]

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_THREE_CONCENTRATED_RANK

            for i in range(matrix.numRows):
                if i in range(m1 - 2):
                    sepa.rowsFlags[i] = CMR_SEPA_FIRST
                else:
                    sepa.rowsFlags[i] = CMR_SEPA_SECOND

            for j in range(matrix.numColumns):
                if j in range(n1 - 1):
                    sepa.columnsFlags[j] = CMR_SEPA_FIRST
                else:
                    sepa.columnsFlags[j] = CMR_SEPA_SECOND
            CMR_CALL(CMRsepaFindBinaryRepresentatives(cmr, sepa, matrix, transpose, NULL, NULL))

            CMR_CALL(CMRthreesumDecomposeSignConnecting(cmr, matrix, transpose, sepa, specialRows, specialColumns, &gamma, &beta))
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        msg = ""
        if (first_mat[j1, i1] * first_mat[j2, i1] - beta) % 4 != 0:
            msg += f'beta in first_mat should be {beta}. '
        if (second_mat[i2, k1] * second_mat[i2, k2] - gamma) % 4 != 0:
            msg += f'gamma in second_mat should be {gamma}. '
        if msg:
            return False, msg
        return True

    def is_y_sum(three_sum_mat, first_mat, second_mat,
                    first_rows_index=[-2, -1],
                    first_column_index=-1,
                    second_rows_index=[0, 1],
                    second_column_index=0,
                    sign_verify=True):
        r"""
        Check whether ``first_mat`` and ``second_mat`` form ``three_sum_mat``
        via the Y-sum operation.

        Let `M_1` and `M_2` denote the matrices given by ``first_mat`` and ``second_mat``. If ``first_rows_index``
        indexes row vectors `c^T` in ``first_mat`` and ``first_column_index`` indexes a column vector `a` in ``first_mat``,
        then ``second_rows_index`` indexes row vectors `b^T` and ``second_column_index`` indexes a column vector `d` in ``second_mat``.
        In this case, the first matrix is
        `
            M_1 = \begin{bmatrix} A & a \\ c^T & 0 \\ c^T & \varepsilon \end{bmatrix}
        `
        and the second matrix is
        `
            M_2 = \begin{bmatrix} \varepsilon & b^T \\ 0 & b^T \\ d & D \end{bmatrix}.
        `
        Then the Y-sum is the matrix
        `
            M_1 \oplus_3 M_2 = \begin{bmatrix} A & a b^T \\ d c^T & D \end{bmatrix}.

        The terminology "Y-sum" is used in the context of Seymour's decomposition
        of totally unimodular matrices and regular matroids, see [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`delta_sum`, :meth:`three_sum`

        INPUT:

        - ``three_sum_mat`` -- the large integer matrix `M`
        - ``first_mat`` -- the first integer matrix `M_1`
        - ``second_mat`` -- the second integer matrix `M_2`
        - ``first_rows_index`` -- the row indices of `c^T` in `M_1`
        - ``first_column_index`` -- the column index of `a` in `M_1`
        - ``second_rows_index`` -- the row indices of `b^T` in `M_2`
        - ``second_column_index`` -- the column index of `d`  in `M_2`
        - ``sign_verify`` -- boolean (default: ``True``);
            whether to check the sign correctness of `\epsilon_1` and `\epsilon_2`.

        OUTPUT: boolean, or (boolean, string)

        If it is False only because of the sign, then also output the correct sign.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[1, 1, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1],
            ....:                             [0, 0, 1, 0,-1],
            ....:                             [0, 1, 0, 1, 1],
            ....:                             [1, 0,-1, 1, 0],
            ....:                             [1, 0,-1, 1, 1],]); M1
            [ 1  1  0  0  0]
            [ 0 -1  0 -1  1]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  1]
            [ 1  0 -1  1  0]
            [ 1  0 -1  1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[ 1, 1, 1, 1,-1],
            ....:                             [ 0, 1, 1, 1,-1],
            ....:                             [-1, 1, 1, 0, 0],
            ....:                             [ 0, 0,-1, 0, 1],
            ....:                             [ 0, 1, 0,-1, 0],
            ....:                             [ 1, 0, 0, 0, 1]]); M2
            [ 1  1  1  1 -1]
            [ 0  1  1  1 -1]
            [-1  1  1  0  0]
            [ 0  0 -1  0  1]
            [ 0  1  0 -1  0]
            [ 1  0  0  0  1]
            sage: M = Matrix_cmr_chr_sparse.y_sum(M1, M2); M
            [ 1  1  0  0  0  0  0  0]
            [ 0 -1  0 -1  1  1  1 -1]
            [ 0  0  1  0 -1 -1 -1  1]
            [ 0  1  0  1  1  1  1 -1]
            [-1  0  1 -1  1  1  0  0]
            [ 0  0  0  0  0 -1  0  1]
            [ 0  0  0  0  1  0 -1  0]
            [ 1  0 -1  1  0  0  0  1]
            sage: M.is_y_sum(M1, M2, sign_verify=False)
            True
            sage: M.is_y_sum(M1, M2)
            (False,
                'sign_1 in second_mat should be -1. sign_2 in first_mat should be -1. ')

            sage: M1 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[1, 1, 0, 0, 0],
            ....:                             [0,-1, 0,-1, 1],
            ....:                             [0, 0, 1, 0,-1],
            ....:                             [0, 1, 0, 1, 1],
            ....:                             [1, 0,-1, 1, 0],
            ....:                             [1, 0,-1, 1, 1],]); M1
            [ 1  1  0  0  0]
            [ 0 -1  0 -1  1]
            [ 0  0  1  0 -1]
            [ 0  1  0  1  1]
            [ 1  0 -1  1  0]
            [ 1  0 -1  1  1]
            sage: M2 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 5, sparse=True),
            ....:                            [[-1, 1, 1, 1,-1],
            ....:                             [ 0, 1, 1, 1,-1],
            ....:                             [-1, 1, 1, 0, 0],
            ....:                             [ 0, 0,-1, 0, 1],
            ....:                             [ 0, 1, 0,-1, 0],
            ....:                             [ 1, 0, 0, 0, 1]]); M2
            [-1  1  1  1 -1]
            [ 0  1  1  1 -1]
            [-1  1  1  0  0]
            [ 0  0 -1  0  1]
            [ 0  1  0 -1  0]
            [ 1  0  0  0  1]
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 8, 8, sparse=True), [
            ....:    [ 1,  1,  0,  0,  0,  0,  0,  0],
            ....:    [ 0, -1,  0, -1,  1,  1,  1, -1],
            ....:    [ 0,  0,  1,  0, -1, -1, -1,  1],
            ....:    [ 0,  1,  0,  1,  1,  1,  1, -1],
            ....:    [-1,  0,  1, -1,  1,  1,  0,  0],
            ....:    [ 0,  0,  0,  0,  0, -1,  0,  1],
            ....:    [ 0,  0,  0,  0,  1,  0, -1,  0],
            ....:    [ 1,  0, -1,  1,  0,  0,  0,  1]])
            sage: Matrix_cmr_chr_sparse.is_y_sum(M, M1, M2)
            (False, 'sign_1 in second_mat should be -1. ')

            sage: M.y_sum_decomposition([0, 1, 2, 3], [0, 1, 2, 3])
            (
            [ 1  1  0  0  0]  [-1  1  1  1 -1]
            [ 0 -1  0 -1  1]  [ 0  1  1  1 -1]
            [ 0  0  1  0 -1]  [ 1  1  1  0  0]
            [ 0  1  0  1  1]  [ 0  0 -1  0  1]
            [-1  0  1 -1  0]  [ 0  1  0 -1  0]
            [-1  0  1 -1 -1], [-1  0  0  0  1]
            )

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 4, sparse=True),
            ....:                            [[ 1,  1,  0,  0],
            ....:                             [ 1,  0,  1,  0],
            ....:                             [ 0,  1,  0,  1],
            ....:                             [ 0,  0,  1,  1]]);
            sage: M1, M2 = M.y_sum_decomposition([0, 1], [0, 1]); M1
            [ 1  1  0]
            [ 1  0  1]
            [ 0  1  0]
            [ 0  1 -1]
            sage: M2
            [-1  1  0]
            [ 0  1  0]
            [ 1  0  1]
            [ 0  1  1]
            sage: Matrix_cmr_chr_sparse.is_y_sum(M, M1, M2)
            True
        """
        if not isinstance(first_rows_index, (list, tuple)) or len(first_rows_index) != 2:
            raise ValueError('The index of two rows needs to be given!')
        if not isinstance(second_rows_index, (list, tuple)) or len(second_rows_index) != 2:
            raise ValueError('The index of two rows needs to be given!')

        m1 = first_mat.nrows()
        n1 = first_mat.ncols()
        m2 = second_mat.nrows()
        n2 = second_mat.ncols()
        m = three_sum_mat.nrows()
        n = three_sum_mat.ncols()
        if m != (m1 + m2 - 4): # The number of rows should match
            return False
        if n != (n1 + n2 - 2): # The number of columns should match
            return False

        # Check the extra two rows for c and b
        j1 = first_rows_index[0]
        j2 = first_rows_index[1]
        j1 = j1 if j1 >= 0 else m1 + j1
        j2 = j2 if j2 >= 0 else m1 + j2
        i1 = first_column_index
        i1 = i1 if i1 >= 0 else n1 + i1
        column_index_1 = [j for j in range(n1) if j != i1]
        for j in column_index_1:
            if first_mat[j1, j] != first_mat[j2, j]:
                return False
        sign_2 = first_mat[j2, i1] if first_mat[j1, i1] == 0 else first_mat[j1, i1]
        if sign_2 == 0:
            return False

        k1 = second_rows_index[0]
        k2 = second_rows_index[1]
        k1 = k1 if k1 >= 0 else m2 + k1
        k2 = k2 if k2 >= 0 else m2 + k2
        i2 = second_column_index
        i2 = i2 if i2 >= 0 else n2 + i2
        column_index_2 = [j for j in range(n2) if j != i2]
        for j in column_index_2:
            if second_mat[k1, j] != second_mat[k2, j]:
                return False
        sign_1 = second_mat[k2, i2] if second_mat[k1, i2] == 0 else second_mat[k1, i2]
        if sign_1 == 0:
            return False

        # Check whether the result comes from the Y-sum
        row_index_1 = [i for i in range(m1) if i != j1 and i != j2]
        for i in range(m1 - 2):
            for j in range(n1 - 1):
                if first_mat[row_index_1[i], column_index_1[j]] != three_sum_mat[i, j]:
                    return False, "A in the first matrix is inconsistent with the y sum"
        row_index_2 = [i for i in range(m2) if i != k1 and i != k2]
        for i in range(m2 - 2):
            for j in range(n2 - 1):
                if second_mat[row_index_2[i], column_index_2[j]] != three_sum_mat[m1 - 2 + i, n1 - 1 + j]:
                    return False, "D in the second matrix is inconsistent with the y sum"
        for i in range(m1 - 2):
            for j in range(n2 - 1):
                rank1_entry = first_mat[row_index_1[i], i1] * second_mat[k1, column_index_2[j]]
                if rank1_entry != three_sum_mat[i, n1 - 1 + j]:
                    return False, "B in the y sum is not consistent with the two matrices"
        for i in range(m2 - 2):
            for j in range(n1 - 1):
                rank1_entry = first_mat[j1, column_index_1[j]] * second_mat[row_index_2[i], i2]
                if rank1_entry != three_sum_mat[m1 - 2 + i, j]:
                    return False, "C in the y sum is not consistent with the two matrices"

        if sign_verify is not True:
            return True
        # Check the sign
        cdef CMR_CHRMAT *matrix = three_sum_mat._mat
        cdef CMR_CHRMAT *transpose = NULL
        cdef CMR_SEPA *sepa = NULL
        cdef char epsilon

        sig_on()
        try:
            CMR_CALL(CMRchrmatTranspose(cmr, matrix, &transpose))
            CMR_CALL(CMRsepaCreate(cmr, matrix.numRows, matrix.numColumns, &sepa))
            sepa.type = CMR_SEPA_TYPE_THREE_DISTRIBUTED_RANKS

            for i in range(matrix.numRows):
                if i in range(m1 - 2):
                    sepa.rowsFlags[i] = CMR_SEPA_FIRST
                else:
                    sepa.rowsFlags[i] = CMR_SEPA_SECOND

            for j in range(matrix.numColumns):
                if j in range(n1 - 1):
                    sepa.columnsFlags[j] = CMR_SEPA_FIRST
                else:
                    sepa.columnsFlags[j] = CMR_SEPA_SECOND

            CMR_CALL(CMRsepaFindBinaryRepresentatives(cmr, sepa, matrix, transpose, NULL, NULL))

            CMR_CALL(CMRysumDecomposeEpsilon(cmr, matrix, transpose, sepa, &epsilon))
        finally:
            if sepa is not NULL:
                CMR_CALL(CMRsepaFree(cmr, &sepa))
            if transpose is not NULL:
                CMR_CALL(CMRchrmatFree(cmr, &transpose))
            sig_off()

        msg = ""
        if (first_mat[j2, i1] - epsilon) % 4 != 0:
            msg += f'sign_1 in second_mat should be {epsilon}. '
        if (second_mat[k1, i2] - epsilon) % 4 != 0:
            msg += f'sign_2 in first_mat should be {epsilon}. '
        if msg:
            return False, msg
        return True

    def binary_pivot(self, row, column):
        r"""
        Apply a pivot to ``self`` and returns the resulting matrix.
        Calculations are done over the binary field.

        Suppose a matrix is `\begin{bmatrix} 1 & c^T \\ b & D\end{bmatrix}`.
        Then the pivot of the matrix with respect to `1` is
        `\begin{bmatrix} 1 & c^T \\ b & D - bc^T\end{bmatrix}`.

        The terminology "pivot" is defined in [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`binary_pivots`, :meth:`ternary_pivot`, :meth:`ternary_pivots`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 10, 10, sparse=True), [
            ....:     [1, 1, 0, 0, 0, 1, 0, 1, 0, 0],
            ....:     [1, 0, 0, 0, 0, 1, 1, 0, 1, 0],
            ....:     [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
            ....:     [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
            ....:     [0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
            ....:     [0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
            ....:     [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
            ....:     [0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
            ....:     [1, 0, 0, 0, 0, 0, 1, 0, 1, 1],
            ....:     [1, 1, 0, 0, 0, 1, 0, 0, 0, 0]
            ....: ]); M
            [1 1 0 0 0 1 0 1 0 0]
            [1 0 0 0 0 1 1 0 1 0]
            [0 0 0 0 1 1 0 0 0 0]
            [0 0 0 1 1 0 0 0 0 0]
            [0 0 1 1 0 0 0 0 0 0]
            [0 1 1 0 0 0 0 0 0 0]
            [0 0 0 0 0 0 0 0 1 0]
            [0 0 0 0 0 1 0 0 0 1]
            [1 0 0 0 0 0 1 0 1 1]
            [1 1 0 0 0 1 0 0 0 0]
            sage: M.binary_pivot(0, 0)
            [1 1 0 0 0 1 0 1 0 0]
            [1 1 0 0 0 0 1 1 1 0]
            [0 0 0 0 1 1 0 0 0 0]
            [0 0 0 1 1 0 0 0 0 0]
            [0 0 1 1 0 0 0 0 0 0]
            [0 1 1 0 0 0 0 0 0 0]
            [0 0 0 0 0 0 0 0 1 0]
            [0 0 0 0 0 1 0 0 0 1]
            [1 1 0 0 0 1 1 1 1 1]
            [1 0 0 0 0 0 0 1 0 0]
        """
        cdef Matrix_cmr_chr_sparse result
        cdef size_t pivot_row = row
        cdef size_t pivot_column = column
        cdef CMR_CHRMAT *result_mat

        CMR_CALL(CMRchrmatBinaryPivot(cmr, self._mat, pivot_row, pivot_column, &result_mat))
        result = Matrix_cmr_chr_sparse._from_cmr(result_mat)
        return result

    def binary_pivots(self, rows, columns):
        r"""
        Apply a sequence of pivots to ``self`` and returns the resulting matrix.
        Calculations are done over the binary field.

        .. SEEALSO:: :meth:`binary_pivot`, :meth:`ternary_pivot`, :meth:`ternary_pivots`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 10, 10, sparse=True), [
            ....:     [1, 1, 0, 0, 0, 1, 0, 1, 0, 0],
            ....:     [1, 0, 0, 0, 0, 1, 1, 0, 1, 0],
            ....:     [0, 0, 0, 0, 1, 1, 0, 0, 0, 0],
            ....:     [0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
            ....:     [0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
            ....:     [0, 1, 1, 0, 0, 0, 0, 0, 0, 0],
            ....:     [0, 0, 0, 0, 0, 0, 0, 0, 1, 0],
            ....:     [0, 0, 0, 0, 0, 1, 0, 0, 0, 1],
            ....:     [1, 0, 0, 0, 0, 0, 1, 0, 1, 1],
            ....:     [1, 1, 0, 0, 0, 1, 0, 0, 0, 0]
            ....: ]); M
            [1 1 0 0 0 1 0 1 0 0]
            [1 0 0 0 0 1 1 0 1 0]
            [0 0 0 0 1 1 0 0 0 0]
            [0 0 0 1 1 0 0 0 0 0]
            [0 0 1 1 0 0 0 0 0 0]
            [0 1 1 0 0 0 0 0 0 0]
            [0 0 0 0 0 0 0 0 1 0]
            [0 0 0 0 0 1 0 0 0 1]
            [1 0 0 0 0 0 1 0 1 1]
            [1 1 0 0 0 1 0 0 0 0]
            sage: M.binary_pivots([5, 4, 3, 2], [2, 3, 4, 5])
            [1 0 1 1 1 1 0 1 0 0]
            [1 1 1 1 1 1 1 0 1 0]
            [0 1 1 1 1 1 0 0 0 0]
            [0 1 1 1 1 0 0 0 0 0]
            [0 1 1 1 0 0 0 0 0 0]
            [0 1 1 0 0 0 0 0 0 0]
            [0 0 0 0 0 0 0 0 1 0]
            [0 1 1 1 1 1 0 0 0 1]
            [1 0 0 0 0 0 1 0 1 1]
            [1 0 1 1 1 1 0 0 0 0]
        """
        npivots = len(rows)
        if len(columns) != npivots:
            raise ValueError("The pivot rows and columns must have the same length")

        cdef size_t* pivot_rows = <size_t *>sig_malloc(sizeof(size_t)*npivots)
        cdef size_t* pivot_columns = <size_t *>sig_malloc(sizeof(size_t)*npivots)
        cdef CMR_CHRMAT *result_mat

        for i in range(npivots):
            pivot_rows[i] = rows[i]
            pivot_columns[i] = columns[i]

        try:
            CMR_CALL(CMRchrmatBinaryPivots(cmr, self._mat, npivots, pivot_rows, pivot_columns, &result_mat))
            return Matrix_cmr_chr_sparse._from_cmr(result_mat)
        finally:
            sig_free(pivot_rows)
            sig_free(pivot_columns)

    def ternary_pivot(self, row, column):
        r"""
        Apply a pivot to ``self`` and returns the resulting matrix.
        Calculations are done over the ternary field.

        Suppose a matrix is `\begin{bmatrix} \epsilon & c^T \\ b & D\end{bmatrix}`,
        where `\epsilon\in\{\pm 1\}`.
        Then the pivot of the matrix with respect to `\epsilon` is
        `\begin{bmatrix} -\epsilon & \epsilon c^T \\ \epsilon b & D-\epsilon bc^T\end{bmatrix}`.

        The terminology "pivot" is defined in [Sch1986]_, Ch. 19.4.

        .. SEEALSO:: :meth:`binary_pivot`, :meth:`binary_pivots`, :meth:`ternary_pivots`

        EXAMPLES:

        Single pivot on a `1`-entry::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 10, 10, sparse=True), [
            ....:     [ 1,  1, 0, 0, 0, -1, 0, 1, 0, 0],
            ....:     [-1,  0, 0, 0, 0,  1, 1, 0, 1, 0],
            ....:     [ 0,  0, 0, 0, 1,  1, 0, 0, 0, 0],
            ....:     [ 0,  0, 0, 1, 1,  0, 0, 0, 0, 0],
            ....:     [ 0,  0, 1, 1, 0,  0, 0, 0, 0, 0],
            ....:     [ 0,  1, 1, 0, 0,  0, 0, 0, 0, 0],
            ....:     [ 0,  0, 0, 0, 0,  0, 0, 0, 1, 0],
            ....:     [ 0,  0, 0, 0, 0,  1, 0, 0, 0, 1],
            ....:     [ 1,  0, 0, 0, 0,  0, 1, 0, 1, 1],
            ....:     [ 1,  1, 0, 0, 0,  1, 0, 0, 0, 0]
            ....: ]); M
            [ 1  1  0  0  0 -1  0  1  0  0]
            [-1  0  0  0  0  1  1  0  1  0]
            [ 0  0  0  0  1  1  0  0  0  0]
            [ 0  0  0  1  1  0  0  0  0  0]
            [ 0  0  1  1  0  0  0  0  0  0]
            [ 0  1  1  0  0  0  0  0  0  0]
            [ 0  0  0  0  0  0  0  0  1  0]
            [ 0  0  0  0  0  1  0  0  0  1]
            [ 1  0  0  0  0  0  1  0  1  1]
            [ 1  1  0  0  0  1  0  0  0  0]
            sage: M.ternary_pivot(0, 0)
            [-1  1  0  0  0 -1  0  1  0  0]
            [-1  1  0  0  0  0  1  1  1  0]
            [ 0  0  0  0  1  1  0  0  0  0]
            [ 0  0  0  1  1  0  0  0  0  0]
            [ 0  0  1  1  0  0  0  0  0  0]
            [ 0  1  1  0  0  0  0  0  0  0]
            [ 0  0  0  0  0  0  0  0  1  0]
            [ 0  0  0  0  0  1  0  0  0  1]
            [ 1 -1  0  0  0  1  1 -1  1  1]
            [ 1  0  0  0  0 -1  0 -1  0  0]

        Single pivot on a `-1`-entry::

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 10, 10, sparse=True), [
            ....:     [-1,  1, 0, 0, 0, -1, 0,  1, 0, 0],
            ....:     [-1,  0, 0, 0, 0,  1, 1,  0, 1, 0],
            ....:     [ 0,  0, 0, 0, 1,  1, 0,  0, 0, 0],
            ....:     [ 0,  0, 0, 1, 1,  0, 0,  0, 0, 0],
            ....:     [ 0,  0, 1, 1, 0,  0, 0,  0, 0, 0],
            ....:     [ 0,  1, 1, 0, 0,  0, 0,  0, 0, 0],
            ....:     [ 0,  0, 0, 0, 0,  0, 0,  0, 1, 0],
            ....:     [ 0,  0, 0, 0, 0,  1, 0,  0, 0, 1],
            ....:     [ 1,  0, 0, 0, 0,  0, 1,  0, 1, 1],
            ....:     [ 1,  1, 0, 0, 0,  1, 0,  0, 0, 0]
            ....: ]); M
            [-1  1  0  0  0 -1  0  1  0  0]
            [-1  0  0  0  0  1  1  0  1  0]
            [ 0  0  0  0  1  1  0  0  0  0]
            [ 0  0  0  1  1  0  0  0  0  0]
            [ 0  0  1  1  0  0  0  0  0  0]
            [ 0  1  1  0  0  0  0  0  0  0]
            [ 0  0  0  0  0  0  0  0  1  0]
            [ 0  0  0  0  0  1  0  0  0  1]
            [ 1  0  0  0  0  0  1  0  1  1]
            [ 1  1  0  0  0  1  0  0  0  0]
            sage: M.ternary_pivot(0, 0)
            [ 1 -1  0  0  0  1  0 -1  0  0]
            [ 1 -1  0  0  0 -1  1 -1  1  0]
            [ 0  0  0  0  1  1  0  0  0  0]
            [ 0  0  0  1  1  0  0  0  0  0]
            [ 0  0  1  1  0  0  0  0  0  0]
            [ 0  1  1  0  0  0  0  0  0  0]
            [ 0  0  0  0  0  0  0  0  1  0]
            [ 0  0  0  0  0  1  0  0  0  1]
            [-1  1  0  0  0 -1  1  1  1  1]
            [-1 -1  0  0  0  0  0  1  0  0]
        """
        cdef size_t pivot_row = row
        cdef size_t pivot_column = column
        cdef CMR_CHRMAT *result_mat

        CMR_CALL(CMRchrmatTernaryPivot(cmr, self._mat, pivot_row, pivot_column, &result_mat))
        return Matrix_cmr_chr_sparse._from_cmr(result_mat)

    def ternary_pivots(self, rows, columns):
        r"""
        Apply a sequence of pivots to ``self`` and returns the resulting matrix.
        Calculations are done over the ternary field.

        .. SEEALSO:: :meth:`binary_pivot`, :meth:`binary_pivots`, :meth:`ternary_pivot`
        """
        cdef size_t npivots = len(rows)
        if len(columns) != npivots:
            raise ValueError("The pivot rows and columns must have the same length")

        cdef size_t* pivot_rows = <size_t *>sig_malloc(sizeof(size_t)*npivots)
        cdef size_t* pivot_columns = <size_t *>sig_malloc(sizeof(size_t)*npivots)
        cdef CMR_CHRMAT *result_mat

        for i in range(npivots):
            pivot_rows[i] = rows[i]
            pivot_columns[i] = columns[i]

        try:
            CMR_CALL(CMRchrmatTernaryPivots(cmr, self._mat, npivots, pivot_rows, pivot_columns, &result_mat))
            return Matrix_cmr_chr_sparse._from_cmr(result_mat)
        finally:
            sig_free(pivot_rows)
            sig_free(pivot_columns)

    def is_unimodular(self, time_limit=60.0):
        r"""
        Return whether ``self`` is a unimodular matrix.

        A nonsingular square matrix `A` is called unimodular if it is integral
        and has determinant `\pm1`, i.e., an element of
        `\mathop{\operatorname{GL}}_n(\ZZ)` [Sch1986]_, Ch. 4.3.

        A rectangular matrix `A` of full row rank is called unimodular if it
        is integral and every basis `B` of `A` has determinant `\pm1`.
        [Sch1986]_, Ch. 19.1.

        More generally, a matrix `A` of rank `r` is called unimodular if it is
        integral and for every submatrix `B` formed by `r` linearly independent columns,
        the greatest common divisor of the determinants of all `r`-by-`r`
        submatrices of `B` is `1`. [Sch1986]_, Ch. 21.4.

        .. SEEALSO:: :meth:`is_k_equimodular`, :meth:`is_strongly_unimodular`, :meth:`is_totally_unimodular`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 0, 0], [0, 1, 0]]); M
            [1 0 0]
            [0 1 0]
            sage: M.is_unimodular()
            True
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 1, 0], [-1, 1, 1]]); M
            [ 1  1  0]
            [-1  1  1]
            sage: M.is_unimodular()
            False
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic():
            raise ValueError(f'only defined over characteristic 0, got {base_ring}')

        cdef CMR_INTMAT *int_mat = NULL
        cdef bool result

        sig_on()
        try:
            CMR_CALL(CMRchrmatToInt(cmr, self._mat, &int_mat))
            CMR_CALL(CMRunimodularTest(cmr, int_mat, &result, NULL, NULL, time_limit))
        finally:
            CMR_CALL(CMRintmatFree(cmr, &int_mat))
            sig_off()

        return <bint> result

    def is_strongly_unimodular(self, time_limit=60.0):
        r"""
        Return whether ``self`` is a strongly unimodular matrix.

        A matrix is strongly unimodular if ``self`` and ``self.transpose()`` are both unimodular.

        .. SEEALSO:: meth:`is_unimodular`, :meth:`is_strongly_k_modular`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 0, 1], [0, 1, 1], [1, 2, 3]]); M
            [1 0 1]
            [0 1 1]
            [1 2 3]
            sage: M.is_unimodular()
            True
            sage: M.is_strongly_unimodular()
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 0, 0], [0, 1, 0]]); M
            [1 0 0]
            [0 1 0]
            sage: M.is_strongly_unimodular()
            True
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic():
            raise ValueError(f'only defined over characteristic 0, got {base_ring}')

        cdef CMR_INTMAT *int_mat = NULL
        cdef bool result

        sig_on()
        try:
            CMR_CALL(CMRchrmatToInt(cmr, self._mat, &int_mat))
            CMR_CALL(CMRunimodularTestStrong(cmr, int_mat, &result, NULL, NULL, time_limit))
        finally:
            CMR_CALL(CMRintmatFree(cmr, &int_mat))
            sig_off()

        return <bint> result

    def equimodulus(self, time_limit=60.0):
        r"""
        Return the integer `k` such that ``self`` is
        equimodular with determinant gcd `k`.

        A matrix `M` of rank `r` is equimodular with determinant gcd `k`
        if the following two conditions are satisfied:

        - for some column basis `B` of `M`, the greatest common divisor of
          the determinants of all `r`-by-`r` submatrices of `B` is `k`;

        - the matrix `X` such that `M=BX` is totally unimodular.

        OUTPUT:

        - ``k``: ``self`` is equimodular with determinant gcd `k`
        - ``None``: ``self`` is not equimodular for any `k`

        .. SEEALSO:: :meth:`is_k_equimodular`, :meth:`strong_equimodulus`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 0, 1], [0, 1, 1], [1, 2, 3]]); M
            [1 0 1]
            [0 1 1]
            [1 2 3]
            sage: M.equimodulus()
            1
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 1, 1], [0, 1, 3]]); M
            [1 1 1]
            [0 1 3]
            sage: M.equimodulus()
        """
        cdef CMR_INTMAT *int_mat = NULL
        cdef bool result
        cdef int64_t k = 0

        sig_on()
        try:
            CMR_CALL(CMRchrmatToInt(cmr, self._mat, &int_mat))
            CMR_CALL(CMRequimodularTest(cmr, int_mat, &result, &k, NULL, NULL, time_limit))
        finally:
            CMR_CALL(CMRintmatFree(cmr, &int_mat))
            sig_off()

        if result:
            return k
        else:
            return None

    def strong_equimodulus(self, time_limit=60.0):
        r"""
        Return the integer `k` such that ``self`` is
        strongly equimodular with determinant gcd `k`.

        Return whether ``self`` is strongly `k`-equimodular.

        A matrix is strongly equimodular if ``self`` and ``self.transpose()``
        are both equimodular, which implies that they are equimodular for
        the same determinant gcd `k`.
        A matrix `M` of rank-`r` is `k`-equimodular if the following two conditions
        are satisfied:

        - for some column basis `B` of `M`, the greatest common divisor of the
          determinants of all `r`-by-`r` submatrices of `B` is `k`;

        - the matrix `X` such that `M=BX` is totally unimodular.

        OUTPUT:

        - ``k``: ``self`` is  `k`-equimodular
        - ``None``: ``self`` is not `k`-equimodular for any `k`

        .. SEEALSO:: :meth:`is_strongly_k_equimodular`, :meth:`equimodulus`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 0, 1], [0, 1, 1], [1, 2, 3]]); M
            [1 0 1]
            [0 1 1]
            [1 2 3]
            sage: M.strong_equimodulus()
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 0, 0], [0, 1, 0]]); M
            [1 0 0]
            [0 1 0]
            sage: M.strong_equimodulus()
            1
        """
        cdef CMR_INTMAT *int_mat = NULL
        cdef bool result
        cdef int64_t k = 0

        sig_on()
        try:
            CMR_CALL(CMRchrmatToInt(cmr, self._mat, &int_mat))
            CMR_CALL(CMRequimodularTestStrong(cmr, int_mat, &result, &k, NULL, NULL, time_limit))
        finally:
            CMR_CALL(CMRintmatFree(cmr, &int_mat))
            sig_off()

        if result:
            return k
        else:
            return None

    def is_k_equimodular(self, k, time_limit=60.0):
        r"""
        Return whether ``self`` is equimodular with determinant gcd `k`.

        A matrix `M` of rank-`r` is `k`-equimodular if the following two
        conditions are satisfied:

        - for some column basis `B` of `M`, the greatest common divisor of
          the determinants of all `r`-by-`r` submatrices of `B` is `k`;

        - the matrix `X` such that `M=BX` is totally unimodular.

        If the matrix has full row rank, it is `k`-equimodular if
        every full rank minor of the matrix has determinant `0,\pm k`.

        .. NOTE::

            In parts of the literature, a matrix with the above properties
            is called *strictly* `k`-modular.

        .. SEEALSO:: :meth:`is_unimodular`, :meth:`is_strongly_k_equimodular`,
                     :meth:`equimodulus`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 0, 1], [0, 1, 1], [1, 2, 3]]); M
            [1 0 1]
            [0 1 1]
            [1 2 3]
            sage: M.is_k_equimodular(1)
            True
            sage: M.is_k_equimodular(2)
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 1, 1], [0, 1, 3]]); M
            [1 1 1]
            [0 1 3]
            sage: M.is_k_equimodular(1)
            False
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic():
            raise ValueError(f'only defined over characteristic 0, got {base_ring}')

        cdef CMR_INTMAT *int_mat = NULL
        cdef bool result
        cdef int64_t gcd_det = k

        sig_on()
        try:
            CMR_CALL(CMRchrmatToInt(cmr, self._mat, &int_mat))
            CMR_CALL(CMRequimodularTest(cmr, int_mat, &result, &gcd_det, NULL, NULL, time_limit))
        finally:
            CMR_CALL(CMRintmatFree(cmr, &int_mat))
            sig_off()

        return True if result else False

    def is_strongly_k_equimodular(self, k, time_limit=60.0):
        r"""
        Return whether ``self`` is strongly `k`-equimodular.

        A matrix is strongly `k`-equimodular if ``self`` and ``self.transpose()``
        are both `k`-equimodular.

        .. SEEALSO:: :meth:`is_k_equimodular`, :meth:`is_strongly_unimodular`,
                     :meth:`strong_equimodulus`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 0, 1], [0, 1, 1], [1, 2, 3]]); M
            [1 0 1]
            [0 1 1]
            [1 2 3]
            sage: M.is_strongly_k_equimodular(1)
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 2, 3, sparse=True),
            ....:                           [[1, 0, 0], [0, 1, 0]]); M
            [1 0 0]
            [0 1 0]
            sage: M.is_strongly_k_equimodular(1)
            True
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic():
            raise ValueError(f'only defined over characteristic 0, got {base_ring}')

        cdef CMR_INTMAT *int_mat = NULL
        cdef bool result
        cdef int64_t gcd_det = k

        sig_on()
        try:
            CMR_CALL(CMRchrmatToInt(cmr, self._mat, &int_mat))
            CMR_CALL(CMRequimodularTestStrong(cmr, int_mat, &result, &gcd_det, NULL, NULL, time_limit))
        finally:
            CMR_CALL(CMRintmatFree(cmr, &int_mat))
            sig_off()

        return True if result else False

    def _is_binary_linear_matroid_graphic(self, *, time_limit=60.0, decomposition=False, certificate=False,
                   row_keys=None, column_keys=None):
        r"""
        Return whether the linear matroid of ``self`` over `\GF{2}` is graphic.
        If there is some entry not in `\{0, 1\}`, return ``False``.

        This is an internal method because it should really be exposed
        as a method of :class:`Matroid`.

        Equivalently, we also define the graphic matrix as follows.

        Let `G = (V,E)` be a graph and let `T` be a spanning forest.
        The matrix `M(G,T) \in \{0,1\}^{T \times (E \setminus T)}` defined via
        `
        M(D,T)_{e, f} := \begin{cases}
            1 & \text{if $e$ is contained in the unique cycle of $T\cup\{f\}$}, \\
            0  & \text{otherwise}
        \end{cases}
        `
        is called the graphic matrix of `G` with respect to `T`.
        A binary matrix `M` is called graphic if there exists a graph `G`
        with a spanning forest `T` such that `M = M(G,T)`.
        Moreover, `M` is called cographic if `M^T` is graphic, and
        it is called planar if it is graphic and cographic.

        .. SEEALSO::

            :meth:`M._is_graphic_cmr() <sage.matroids.linear_matroid.
            BinaryMatroid._is_graphic_cmr>`
            :meth:`M.is_graphic() <sage.matroids.matroid.
            Matroid.is_graphic>`

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [-1, 1], [0, -1]]); M
            [ 1  0]
            [-1  1]
            [ 0 -1]
            sage: M._is_binary_linear_matroid_graphic()
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [1, 1], [0, 1]]); M
            [1 0]
            [1 1]
            [0 1]
            sage: M._is_binary_linear_matroid_graphic()
            True
            sage: result, certificate = M._is_binary_linear_matroid_graphic(certificate=True)
            sage: graph, forest_edges, coforest_edges = certificate
            sage: graph.vertices(sort=True)  # the numbers have no meaning
            [1, 2, 7, 12]
            sage: graph.edges(sort=True, labels=False)
            [(1, 2), (1, 7), (1, 12), (2, 7), (7, 12)]
            sage: forest_edges    # indexed by rows of M
            ((1, 2), (7, 1), (12, 7))
            sage: coforest_edges  # indexed by cols of M
            ((2, 7), (1, 12))

        With keys::

            sage: result, certificate = M._is_binary_linear_matroid_graphic(certificate=True,
            ....:     row_keys=['a', 'b', 'c'], column_keys=['v', 'w'])
            sage: graph, forest_edges, coforest_edges = certificate
            sage: forest_edges
            {'a': (1, 2), 'b': (7, 1), 'c': (12, 7)}
            sage: coforest_edges
            {'v': (2, 7), 'w': (1, 12)}

        Creating a decomposition node::

            sage: result, node = M._is_binary_linear_matroid_graphic(decomposition=True,
            ....:     row_keys=['a', 'b', 'c'], column_keys=['v', 'w'])
            sage: result, node
            (True, GraphicNode (3×2))

        TESTS::

            sage: M._is_binary_linear_matroid_graphic(time_limit=0.0)
            Traceback (most recent call last):
            ...
            RuntimeError: Time limit exceeded
        """
        base_ring = self.parent().base_ring()
        from sage.rings.finite_rings.finite_field_constructor import GF
        GF2 = GF(2)
        if not GF2.has_coerce_map_from(base_ring):
            raise ValueError('not well-defined')

        cdef bool result_bool
        cdef CMR_GRAPH *graph = NULL
        cdef CMR_GRAPH_EDGE* forest_edges = NULL
        cdef CMR_GRAPH_EDGE* coforest_edges = NULL
        cdef CMR_SUBMAT* submatrix = NULL
        cdef CMR_GRAPHIC_STATISTICS stats

        sig_on()
        try:
            if decomposition or certificate:
                CMR_CALL(CMRgraphicTestMatrix(cmr, self._mat, &result_bool, &graph, &forest_edges,
                                              &coforest_edges, &submatrix, &stats, time_limit))
            else:
                CMR_CALL(CMRgraphicTestMatrix(cmr, self._mat, &result_bool, NULL, NULL,
                                              NULL, NULL, &stats, time_limit))
        finally:
            sig_off()

        result = <bint> result_bool

        if not decomposition and not certificate:
            return result

        if result:
            result = [result]
            sage_graph = _sage_graph(graph)
            sage_forest_edges = _sage_edges(graph, forest_edges, self.nrows(), row_keys)
            sage_coforest_edges = _sage_edges(graph, coforest_edges, self.ncols(), column_keys)
            if decomposition:
                result.append(GraphicNode(self, sage_graph, sage_forest_edges, sage_coforest_edges,
                                          row_keys=row_keys, column_keys=column_keys))
            if certificate:
                result.append((sage_graph, sage_forest_edges, sage_coforest_edges))
        else:
            result = [result]
            if decomposition:
                raise NotImplementedError
            if certificate:
                result.append(NotImplemented)  # submatrix TBD
        return result

    def _is_binary_linear_matroid_cographic(self, *, time_limit=60.0, certificate=False,
                     row_keys=None, column_keys=None):
        r"""
        Return whether the linear matroid of ``self`` over `\GF{2}` is cographic.
        If there is some entry not in `\{0, 1\}`, return ``False``.

        This is an internal method because it should really be exposed
        as a method of :class:`Matroid`.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 9, sparse=True),
            ....:                           [[1, 0, 0, 0, 1, -1, 1, 0, 0],
            ....:                            [0, 1, 0, 0, 0, 1, -1, 1, 0],
            ....:                            [0, 0, 1, 0, 0, 0, 1, -1, 1],
            ....:                            [0, 0, 0, 1, 1, 0, 0, 1, -1]]); M
            [ 1  0  0  0  1 -1  1  0  0]
            [ 0  1  0  0  0  1 -1  1  0]
            [ 0  0  1  0  0  0  1 -1  1]
            [ 0  0  0  1  1  0  0  1 -1]
            sage: M._is_binary_linear_matroid_cographic()
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(GF(2), 4, 9, sparse=True),
            ....:                           M); M
            [1 0 0 0 1 1 1 0 0]
            [0 1 0 0 0 1 1 1 0]
            [0 0 1 0 0 0 1 1 1]
            [0 0 0 1 1 0 0 1 1]
            sage: M._is_binary_linear_matroid_cographic()
            True
            sage: C3 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 1, 0],
            ....:                            [1, 0, 1],
            ....:                            [0, 1, 1]]); C3
            [1 1 0]
            [1 0 1]
            [0 1 1]
            sage: result, certificate = C3._is_binary_linear_matroid_cographic(certificate=True)
            sage: result
            True
            sage: graph, forest_edges, coforest_edges = certificate
            sage: graph.edges(sort=True, labels=False)
            [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]
            sage: forest_edges
            ((3, 2), (0, 3), (1, 3))
            sage: coforest_edges
            ((2, 0), (2, 1), (0, 1))
        """
        base_ring = self.parent().base_ring()
        from sage.rings.finite_rings.finite_field_constructor import GF
        GF2 = GF(2)
        if not GF2.has_coerce_map_from(base_ring):
            raise ValueError('not well-defined')

        cdef bool result
        cdef CMR_GRAPH *graph = NULL
        cdef CMR_GRAPH_EDGE* forest_edges = NULL
        cdef CMR_GRAPH_EDGE* coforest_edges = NULL
        cdef CMR_SUBMAT* submatrix = NULL
        cdef CMR_GRAPHIC_STATISTICS stats

        sig_on()
        try:
            if certificate:
                CMR_CALL(CMRgraphicTestTranspose(cmr, self._mat, &result, &graph, &forest_edges,
                                              &coforest_edges, &submatrix, &stats, time_limit))
            else:
                CMR_CALL(CMRgraphicTestTranspose(cmr, self._mat, &result, NULL, NULL,
                                              NULL, NULL, &stats, time_limit))
        finally:
            sig_off()

        if not certificate:
            return <bint> result

        if <bint> result:
            sage_graph = _sage_graph(graph)
            sage_forest_edges = _sage_edges(graph, forest_edges, self.nrows(), row_keys)
            sage_coforest_edges = _sage_edges(graph, coforest_edges, self.ncols(), column_keys)
            return True, (sage_graph, sage_forest_edges, sage_coforest_edges)

        return False, NotImplemented  # submatrix TBD

    def is_network_matrix(self, *, time_limit=60.0, certificate=False,
                          row_keys=None, column_keys=None):
        r"""
        Return whether the matrix ``self`` over `\GF{3}` or `\QQ` is a network matrix.
        If there is some entry not in `\{-1, 0, 1\}`, return ``False``.

        Let `D = (V,A)` be a digraph and let `T` be an (arbitrarily) directed
        spanning forest of the underlying undirected graph.
        The matrix `M(D,T) \in \{-1,0,1\}^{T \times (A \setminus T)}` defined via

        .. MATH::

            M(D,T)_{a,(v,w)} := \begin{cases}
                +1 & \text{if the unique $v$-$w$-path in $T$ passes through $a$ forwardly}, \\
                -1 & \text{if the unique $v$-$w$-path in $T$ passes through $a$ backwardly}, \\
                0  & \text{otherwise}
            \end{cases}

        is called the network matrix of `D` with respect to `T`.
        A matrix `M` is called network matrix if there exists a digraph `D`
        with a directed spanning forest `T` such that `M = M(D,T)`.
        Moreover, `M` is called conetwork matrix if `M^T` is a network matrix.

        ALGORITHM:

        The implemented recognition algorithm first tests the binary matroid of
        the support matrix of `M` for being graphic and
        uses camion for testing whether `M` is signed correctly.

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [2, 1], [0, -1]]); M
            [ 1  0]
            [ 2  1]
            [ 0 -1]
            sage: M.is_network_matrix()
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [-1, 1], [0, -1]]); M
            [ 1  0]
            [-1  1]
            [ 0 -1]
            sage: M.is_network_matrix()
            True
            sage: result, certificate = M.is_network_matrix(certificate=True)
            sage: graph, forest_edges, coforest_edges = certificate
            sage: graph
            Digraph on 4 vertices
            sage: graph.vertices(sort=True)  # the numbers have no meaning
            [1, 2, 7, 12]
            sage: graph.edges(sort=True, labels=False)
            [(2, 1), (2, 7), (7, 1), (7, 12), (12, 1)]
            sage: forest_edges    # indexed by rows of M
            ((2, 1), (7, 1), (7, 12))
            sage: coforest_edges  # indexed by cols of M
            ((2, 7), (12, 1))

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: K33 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 4, sparse=True),
            ....:                             [[-1, -1, -1, -1],
            ....:                              [ 1,  1,  0,  0],
            ....:                              [ 0,  0,  1,  1],
            ....:                              [ 1,  0,  1,  0],
            ....:                              [ 0,  1,  0,  1]]); K33
            [-1 -1 -1 -1]
            [ 1  1  0  0]
            [ 0  0  1  1]
            [ 1  0  1  0]
            [ 0  1  0  1]
            sage: K33.is_network_matrix()
            True

        This is test ``Basic`` in CMR's ``test_network.cpp``::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 6, 7, sparse=True),
            ....:                           [[-1,  0,  0,  0,  1, -1,  0],
            ....:                            [ 1,  0,  0,  1, -1,  1,  0],
            ....:                            [ 0, -1,  0, -1,  1, -1,  0],
            ....:                            [ 0,  1,  0,  0,  0,  0,  1],
            ....:                            [ 0,  0,  1, -1,  1,  0,  1],
            ....:                            [ 0,  0, -1,  1, -1,  0,  0]])
            sage: M.is_network_matrix()
            True
            sage: result, certificate = M.is_network_matrix(certificate=True)
            sage: result, certificate
            (True,
             (Digraph on 7 vertices,
              ((9, 8), (3, 8), (3, 4), (5, 4), (4, 6), (0, 6)),
              ((3, 9), (5, 3), (4, 0), (0, 8), (9, 0), (4, 9), (5, 6))))
            sage: digraph, forest_arcs, coforest_arcs = certificate
            sage: list(digraph.edges(sort=True))
            [(0, 6, None), (0, 8, None),
             (3, 4, None), (3, 8, None), (3, 9, None),
             (4, 0, None), (4, 6, None), (4, 9, None),
             (5, 3, None), (5, 4, None), (5, 6, None),
             (9, 0, None), (9, 8, None)]
            sage: digraph.plot(edge_colors={'red': forest_arcs})                        # needs sage.plot
            Graphics object consisting of 21 graphics primitives
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic() not in [0, 3] :
            raise ValueError(f'only defined over characteristic 0 or 3, got {base_ring}')

        cdef bool result
        cdef bool support_result
        cdef CMR_GRAPH *digraph = NULL
        cdef CMR_GRAPH_EDGE* forest_arcs = NULL
        cdef CMR_GRAPH_EDGE* coforest_arcs = NULL
        cdef bool* arcs_reversed = NULL
        cdef CMR_SUBMAT* submatrix = NULL
        cdef CMR_NETWORK_STATISTICS stats

        sig_on()
        try:
            if certificate:
                CMR_CALL(CMRnetworkTestMatrix(cmr, self._mat, &result, &support_result, &digraph, &forest_arcs,
                                              &coforest_arcs, &arcs_reversed, &submatrix, &stats,
                                              time_limit))
            else:
                CMR_CALL(CMRnetworkTestMatrix(cmr, self._mat, &result, &support_result, NULL, NULL,
                                              NULL, NULL, NULL, &stats, time_limit))
        finally:
            sig_off()

        if not certificate:
            return <bint> result

        if <bint> result:
            sage_digraph = _sage_digraph(digraph, arcs_reversed)
            sage_forest_arcs = _sage_arcs(digraph, forest_arcs, arcs_reversed, self.nrows(), row_keys)
            sage_coforest_arcs = _sage_arcs(digraph, coforest_arcs, arcs_reversed, self.ncols(), column_keys)
            return True, (sage_digraph, sage_forest_arcs, sage_coforest_arcs)

        return False, NotImplemented  # submatrix TBD

    def is_conetwork_matrix(self, *, time_limit=60.0, certificate=False,
                               row_keys=None, column_keys=None):
        r"""
        Return whether the matrix ``self`` over `\GF{3}` or `QQ` is a conetwork matrix.
        If there is some entry not in `\{-1, 0, 1\}`, return ``False``.

        A matrix is conetwork if and only if its transpose is network.

        .. SEEALSO:: :meth:`is_network_matrix`,

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 4, 9, sparse=True),
            ....:                           [[1, 0, 0, 0, 1, -1, 1, 0, 0],
            ....:                            [0, 1, 0, 0, 0, 1, -1, 1, 0],
            ....:                            [0, 0, 1, 0, 0, 0, 1, -1, 1],
            ....:                            [0, 0, 0, 1, 1, 0, 0, 1, -1]]); M
            [ 1  0  0  0  1 -1  1  0  0]
            [ 0  1  0  0  0  1 -1  1  0]
            [ 0  0  1  0  0  0  1 -1  1]
            [ 0  0  0  1  1  0  0  1 -1]
            sage: M.is_conetwork_matrix()
            True

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: K33 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 5, 4, sparse=True),
            ....:                           [[-1, -1, -1, -1],
            ....:                            [ 1,  1,  0,  0],
            ....:                            [ 0,  0,  1,  1],
            ....:                            [ 1,  0,  1,  0],
            ....:                            [ 0,  1,  0,  1]]); K33
            [-1 -1 -1 -1]
            [ 1  1  0  0]
            [ 0  0  1  1]
            [ 1  0  1  0]
            [ 0  1  0  1]
            sage: K33.is_conetwork_matrix()
            False

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: C3 = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True),
            ....:                           [[1, 1, 0],
            ....:                            [1, 0, 1],
            ....:                            [0, 1, 1]]); C3
            [1 1 0]
            [1 0 1]
            [0 1 1]
            sage: result, certificate = C3.is_conetwork_matrix(certificate=True)
            sage: result
            False
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic() not in [0, 3] :
            raise ValueError(f'only defined over characteristic 0 or 3, got {base_ring}')

        cdef bool result
        cdef bool support_result
        cdef CMR_GRAPH *digraph = NULL
        cdef CMR_GRAPH_EDGE* forest_arcs = NULL
        cdef CMR_GRAPH_EDGE* coforest_arcs = NULL
        cdef bool* arcs_reversed = NULL
        cdef CMR_SUBMAT* submatrix = NULL
        cdef CMR_NETWORK_STATISTICS stats

        sig_on()
        try:
            if certificate:
                CMR_CALL(CMRnetworkTestTranspose(cmr, self._mat, &result, &support_result, &digraph, &forest_arcs,
                                                &coforest_arcs, &arcs_reversed, &submatrix, &stats,
                                                time_limit))
            else:
                CMR_CALL(CMRnetworkTestTranspose(cmr, self._mat, &result, &support_result, NULL, NULL,
                                                NULL, NULL, NULL, &stats, time_limit))
        finally:
            sig_off()

        if not certificate:
            return <bint> result

        if <bint> result:
            sage_digraph = _sage_digraph(digraph, arcs_reversed)
            sage_forest_arcs = _sage_arcs(digraph, forest_arcs, arcs_reversed, self.nrows(), row_keys)
            sage_coforest_arcs = _sage_arcs(digraph, coforest_arcs, arcs_reversed, self.ncols(), column_keys)
            return True, (sage_digraph, sage_forest_arcs, sage_coforest_arcs)

        return False, NotImplemented  # submatrix TBD

    def _is_binary_linear_matroid_regular(self, *, time_limit=60.0, certificate=False,
                                          use_direct_graphicness_test=True,
                                          prefer_graphicness=True,
                                          series_parallel_ok=True,
                                          check_graphic_minors_planar=False,
                                          stop_when_irregular=True,
                                          decompose_strategy='delta_three',
                                          construct_leaf_graphs=False,
                                          construct_all_graphs=False,
                                          row_keys=None,
                                          column_keys=None):
        r"""
        Return whether the linear matroid of ``self`` over `\GF{2}` is regular.
        If there is some entry not in `\{0, 1\}`, return ``False``.

        This is an internal method because it should really be exposed
        as a method of :class:`Matroid`.

        .. SEEALSO::

            :meth:`M.is_regular() <sage.matroids.matroid.
            Matroid.is_regular>`

        INPUT:

        - ``certificate``: ``False`` or ``True``
          If ``True``, then return a :class:`DecompositionNode`
          if the linear matroid of ``self`` over `\GF{2}` is regular;
          If not, NotImplemented.

        - ``stop_when_irregular`` -- boolean (default: ``True``);
          whether to stop decomposing once irregularity is determined.

          For a description of other parameters, see :meth:`_set_cmr_seymour_parameters`

        - ``row_keys`` -- a finite or enumerated family of arbitrary objects
        that index the rows of the matrix

        - ``column_keys`` -- a finite or enumerated family of arbitrary objects
        that index the columns of the matrix

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [-1, 1], [0, -1]]); M
            [ 1  0]
            [-1  1]
            [ 0 -1]
            sage: M._is_binary_linear_matroid_regular()
            False
            sage: M = Matrix_cmr_chr_sparse(M.parent().change_ring(GF(2)),
            ....:                           M); M
            [1 0]
            [1 1]
            [0 1]
            sage: M._is_binary_linear_matroid_regular()
            True

            sage: MF = matroids.catalog.Fano(); MF
            Fano: Binary matroid of rank 3 on 7 elements, type (3, 0)
            sage: MFR = MF.representation().change_ring(ZZ); MFR
            [1 0 0 0 1 1 1]
            [0 1 0 1 0 1 1]
            [0 0 1 1 1 0 1]
            sage: MFR2 = block_diagonal_matrix(MFR, MFR, sparse=True); MFR2
            [1 0 0 0 1 1 1|0 0 0 0 0 0 0]
            [0 1 0 1 0 1 1|0 0 0 0 0 0 0]
            [0 0 1 1 1 0 1|0 0 0 0 0 0 0]
            [-------------+-------------]
            [0 0 0 0 0 0 0|1 0 0 0 1 1 1]
            [0 0 0 0 0 0 0|0 1 0 1 0 1 1]
            [0 0 0 0 0 0 0|0 0 1 1 1 0 1]
            sage: MS2 = MFR2.parent(); MS2
            Full MatrixSpace of 6 by 14 sparse matrices over Integer Ring
            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: MFR2cmr = Matrix_cmr_chr_sparse(MS2, MFR2)
            sage: result, certificate = MFR2cmr._is_binary_linear_matroid_regular(
            ....:                           certificate=True)
            sage: result, certificate
            (False, (OneSumNode (6×14) with 2 children, NotImplemented))
            sage: certificate[0].child_indices()
            (((0, 1, 2), (0, 4, 5, 6, 2, 3, 1)), ((3, 4, 5), (7, 11, 12, 13, 9, 10, 8)))
            sage: unicode_art(certificate[0])  # random (whether the left or the right branch has been followed)
            ╭OneSumNode (6×14) with 2 children╮
            │                                 │
            SeriesParallelReductionNode (3×7) UnknownNode (3×7)
            │
            ThreeConnectedIrregularNode (3×4)
            sage: result, certificate = MFR2cmr._is_binary_linear_matroid_regular(
            ....:                           certificate=True)
            sage: result, certificate
            (False, (OneSumNode (6×14) with 2 children, NotImplemented))
            sage: unicode_art(certificate[0])
            ╭OneSumNode (6×14) with 2 children╮
            │                                 │
            SeriesParallelReductionNode (3×7) UnknownNode (3×7)
            │
            ThreeConnectedIrregularNode (3×4)
            sage: result, certificate = MFR2cmr._is_binary_linear_matroid_regular(
            ....:                           certificate=True, stop_when_irregular=False)
            sage: result, certificate
            (False, (OneSumNode (6×14) with 2 children, NotImplemented))
            sage: unicode_art(certificate[0])
            ╭OneSumNode (6×14) with 2 children╮
            │                                 │
            SeriesParallelReductionNode (3×7) SeriesParallelReductionNode (3×7)
            │                                 │
            ThreeConnectedIrregularNode (3×4) ThreeConnectedIrregularNode (3×4)

        TESTS:

        This is test ``NestedMinorPivotsTwoSeparation`` in CMR's ``test_regular.cpp``::

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 11, 11, sparse=True),
            ....:                           [[1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0],
            ....:                            [1, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0],
            ....:                            [0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
            ....:                            [0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0],
            ....:                            [0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1],
            ....:                            [0, 1, 1, 1, 0, 0, 0, 0, 0, 1, 0],
            ....:                            [0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0],
            ....:                            [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0],
            ....:                            [0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0],
            ....:                            [0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0],
            ....:                            [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1]])
            sage: result, certificate = M._is_binary_linear_matroid_regular(
            ....:                           certificate=True)
            sage: result, certificate
            (True, GraphicNode (11×11))
            sage: unicode_art(certificate)
            GraphicNode (11×11)
            sage: result, certificate = M._is_binary_linear_matroid_regular(
            ....:                           certificate=True,
            ....:                           use_direct_graphicness_test=False)
            sage: result, certificate
            (True, TwoSumNode (11×11) with 2 children)
            sage: unicode_art(certificate)
            ╭──────────TwoSumNode (11×11) with 2 children
            │                 │
            GraphicNode (7×8) SeriesParallelReductionNode (5×4)
                              │
                              GraphicNode (4×4)

        Base ring check::

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(GF(5), 3, 2, sparse=True),
            ....:                           [[1, 0], [6, 11], [0, 1]]); M
            [1 0]
            [1 1]
            [0 1]
            sage: M._is_binary_linear_matroid_regular()
            Traceback (most recent call last):
            ...
            ValueError: not well-defined

        """
        base_ring = self.parent().base_ring()
        from sage.rings.finite_rings.finite_field_constructor import GF
        GF2 = GF(2)
        if not GF2.has_coerce_map_from(base_ring):
            raise ValueError('not well-defined')

        cdef bool result_bool
        cdef CMR_REGULAR_PARAMS params
        cdef CMR_REGULAR_STATS stats
        cdef CMR_SEYMOUR_NODE *dec = NULL
        cdef CMR_MINOR *minor = NULL

        cdef CMR_SEYMOUR_NODE **pdec = &dec
        cdef CMR_MINOR **pminor = &minor

        cdef dict kwds = dict(use_direct_graphicness_test=use_direct_graphicness_test,
                              prefer_graphicness=prefer_graphicness,
                              series_parallel_ok=series_parallel_ok,
                              check_graphic_minors_planar=check_graphic_minors_planar,
                              stop_when_irregular=stop_when_irregular,
                              stop_when_nongraphic=False,
                              stop_when_noncographic=False,
                              stop_when_nongraphic_and_noncographic=False,
                              decompose_strategy=decompose_strategy,
                              construct_leaf_graphs=construct_leaf_graphs,
                              construct_all_graphs=construct_all_graphs)

        _set_cmr_seymour_parameters(&params.seymour, kwds)
        sig_on()
        try:
            CMR_CALL(CMRregularTest(cmr, self._mat, &result_bool, pdec, pminor,
                                          &params, &stats, time_limit))
        finally:
            sig_off()

        result = <bint> result_bool
        if not certificate:
            return result
        node = create_DecompositionNode(dec, self, row_keys, column_keys, base_ring=GF2)

        if result:
            return result, node
        return result, (node, NotImplemented)

    def is_totally_unimodular(self, *, time_limit=60.0, certificate=False,
                              use_direct_graphicness_test=True,
                              prefer_graphicness=True,
                              series_parallel_ok=True,
                              check_graphic_minors_planar=False,
                              stop_when_nonTU=True,
                              decompose_strategy='delta_three',
                              construct_leaf_graphs=False,
                              construct_all_graphs=False,
                              row_keys=None,
                              column_keys=None):
        r"""
        Return whether ``self`` is a totally unimodular matrix.

        A matrix is totally unimodular if every subdeterminant is `0`, `1`, or `-1`.

        REFERENCES:

        - [Sch1986]_, Chapter 19

        INPUT:

        - ``certificate`` -- boolean (default: ``False``);
          if ``True``, then return
          a :class:`DecompositionNode` if ``self`` is totally unimodular;
          a submatrix with determinant not in `\{0, \pm1\}` if not.

        - ``stop_when_nonTU`` -- boolean (default: ``True``);
          whether to stop decomposing once not TU is determined.

          For a description of other parameters, see :meth:`_set_cmr_seymour_parameters`

        - ``row_keys`` -- a finite or enumerated family of arbitrary objects
          that index the rows of the matrix

        - ``column_keys`` -- a finite or enumerated family of arbitrary objects
          that index the columns of the matrix

        EXAMPLES::

            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [2, 1], [0, 1]]); M
            [1 0]
            [2 1]
            [0 1]
            sage: M.is_totally_unimodular()
            False
            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 2, sparse=True),
            ....:                           [[1, 0], [-1, 1], [0, 1]]); M
            [ 1  0]
            [-1  1]
            [ 0  1]
            sage: M.is_totally_unimodular()
            True
            sage: M.is_totally_unimodular(certificate=True)
            (True, GraphicNode (3×2))

            sage: MF = matroids.catalog.Fano(); MF
            Fano: Binary matroid of rank 3 on 7 elements, type (3, 0)
            sage: MFR = MF.representation().change_ring(ZZ); MFR
            [1 0 0 0 1 1 1]
            [0 1 0 1 0 1 1]
            [0 0 1 1 1 0 1]
            sage: MFR2 = block_diagonal_matrix(MFR, MFR, sparse=True); MFR2
            [1 0 0 0 1 1 1|0 0 0 0 0 0 0]
            [0 1 0 1 0 1 1|0 0 0 0 0 0 0]
            [0 0 1 1 1 0 1|0 0 0 0 0 0 0]
            [-------------+-------------]
            [0 0 0 0 0 0 0|1 0 0 0 1 1 1]
            [0 0 0 0 0 0 0|0 1 0 1 0 1 1]
            [0 0 0 0 0 0 0|0 0 1 1 1 0 1]
            sage: MS2 = MFR2.parent(); MS2
            Full MatrixSpace of 6 by 14 sparse matrices over Integer Ring
            sage: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse
            sage: MFR2cmr = Matrix_cmr_chr_sparse(MS2, MFR2)
            sage: MFR2cmr.is_totally_unimodular(certificate=True)
            (False, (OneSumNode (6×14) with 2 children, ((2, 1, 0), (5, 4, 3))))
            sage: result, certificate = MFR2cmr.is_totally_unimodular(certificate=True,
            ....:                                                     stop_when_nonTU=True)
            sage: result, certificate
            (False, (OneSumNode (6×14) with 2 children, ((2, 1, 0), (5, 4, 3))))
            sage: submatrix = MFR2.matrix_from_rows_and_columns(*certificate[1]); submatrix
            [0 1 1]
            [1 0 1]
            [1 1 0]
            sage: submatrix.determinant()
            2
            sage: submatrix = MFR2cmr.matrix_from_rows_and_columns(*certificate[1]); submatrix
            [0 1 1]
            [1 0 1]
            [1 1 0]

        If the matrix is totally unimodular, it always returns
        a full decomposition as a certificate::

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 9, 9, sparse=True),
            ....:                           [[-1,-1,-1,-1, 0, 0, 0, 0, 0],
            ....:                            [1, 1, 0, 0, 0, 0, 0, 0, 0],
            ....:                            [0, 0, 1, 1, 0, 0, 0, 0, 0],
            ....:                            [1, 0, 1, 0, 0, 0, 0, 0, 0],
            ....:                            [0, 1, 0, 1, 0, 0, 0, 0, 0],
            ....:                            [0, 0, 0, 0,-1, 1, 0, 1, 0],
            ....:                            [0, 0, 0, 0,-1, 1, 0, 0, 1],
            ....:                            [0, 0, 0, 0,-1, 0, 1, 1, 0],
            ....:                            [0, 0, 0, 0,-1, 0, 1, 0, 1]])
            sage: result, certificate = M.is_totally_unimodular(
            ....:                           certificate=True)
            sage: result, certificate
            (True, OneSumNode (9×9) with 2 children)
            sage: unicode_art(certificate)
            ╭───────────OneSumNode (9×9) with 2 children
            │                 │
            GraphicNode (5×4) CographicNode (4×5)
            sage: result, certificate = M.is_totally_unimodular(
            ....:                           certificate=True, stop_when_nonTU=False)
            sage: result, certificate
            (True, OneSumNode (9×9) with 2 children)
            sage: unicode_art(certificate)
            ╭───────────OneSumNode (9×9) with 2 children
            │                 │
            GraphicNode (5×4) CographicNode (4×5)

        This is test ``TreeFlagsNorecurse``, ``TreeFlagsStopNoncographic``,
        and ``TreeFlagsStopNongraphic`` in CMR's ``test_regular.cpp``,
        the underlying binary linear matroid is regular,
        but the matrix is not totally unimodular::

            sage: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 9, 9, sparse=True),
            ....:                           [[1, 1, 0, 0, 0, 0, 0, 0, 0],
            ....:                            [1, 1, 1, 0, 0, 0, 0, 0, 0],
            ....:                            [1, 0, 0, 1, 0, 0, 0, 0, 0],
            ....:                            [0, 1, 1, 1, 0, 0, 0, 0, 0],
            ....:                            [0, 0, 1, 1, 0, 0, 0, 0, 0],
            ....:                            [0, 0, 0, 0, 1, 1, 1, 0, 0],
            ....:                            [0, 0, 0, 0, 1, 1, 0, 1, 0],
            ....:                            [0, 0, 0, 0, 0, 1, 0, 1, 1],
            ....:                            [0, 0, 0, 0, 0, 0, 1, 1, 1]])
            sage: result, certificate = M.is_totally_unimodular(
            ....:                           certificate=True)
            sage: result, certificate
            (False, (OneSumNode (9×9) with 2 children, ((3, 2, 0), (3, 1, 0))))
            sage: unicode_art(certificate[0])
            ╭OneSumNode (9×9) with 2 children─╮
            │                                 │
            ThreeConnectedIrregularNode (5×4) UnknownNode (4×5)
            sage: result, certificate = M.is_totally_unimodular(
            ....:                           certificate=True,
            ....:                           stop_when_nonTU=False)
            sage: result, certificate
            (False, (OneSumNode (9×9) with 2 children, ((3, 2, 0), (3, 1, 0))))
            sage: unicode_art(certificate[0])
            ╭OneSumNode (9×9) with 2 children─╮
            │                                 │
            ThreeConnectedIrregularNode (5×4) ThreeConnectedIrregularNode (4×5)
        """
        base_ring = self.parent().base_ring()
        if base_ring.characteristic() not in [0, 3] :
            raise ValueError(f'only defined over characteristic 0 or 3, got {base_ring}')

        cdef bool result_bool
        cdef CMR_TU_PARAMS params
        cdef CMR_TU_STATS stats
        cdef CMR_SEYMOUR_NODE *dec = NULL
        cdef CMR_SUBMAT *submat = NULL

        cdef CMR_SEYMOUR_NODE **pdec = &dec
        cdef CMR_SUBMAT **psubmat = &submat

        cdef dict kwds = dict(use_direct_graphicness_test=use_direct_graphicness_test,
                              prefer_graphicness=prefer_graphicness,
                              series_parallel_ok=series_parallel_ok,
                              check_graphic_minors_planar=check_graphic_minors_planar,
                              stop_when_irregular=stop_when_nonTU,
                              stop_when_nongraphic=False,
                              stop_when_noncographic=False,
                              stop_when_nongraphic_and_noncographic=False,
                              decompose_strategy=decompose_strategy,
                              construct_leaf_graphs=construct_leaf_graphs,
                              construct_all_graphs=construct_all_graphs)

        params.algorithm = CMR_TU_ALGORITHM_DECOMPOSITION
        params.ternary = True
        params.camionFirst = False
        _set_cmr_seymour_parameters(&params.seymour, kwds)
        sig_on()
        try:
            CMR_CALL(CMRtuTest(cmr, self._mat, &result_bool, pdec, psubmat,
                                               &params, &stats, time_limit))
        finally:
            sig_off()

        result = <bint> result_bool
        if not certificate:
            return result
        node = create_DecompositionNode(dec, self, row_keys, column_keys, base_ring=ZZ)

        if result:
            return result, node

        if submat == NULL:
            submat_tuple = None
        else:
            submat_tuple = (tuple(submat.rows[i] for i in range(submat.numRows)),
                            tuple(submat.columns[i] for i in range(submat.numColumns)))

        return result, (node, submat_tuple)

    def is_complement_totally_unimodular(self, *, time_limit=60.0, certificate=False,
                                         use_direct_graphicness_test=True,
                                         series_parallel_ok=True,
                                         check_graphic_minors_planar=False,
                                         complete_tree='find_irregular',
                                         construct_matrices=False,
                                         construct_transposes=False,
                                         construct_graphs=False,
                                         row_keys=None,
                                         column_keys=None):
        raise NotImplementedError


cdef _set_cmr_seymour_parameters(CMR_SEYMOUR_PARAMS *params, dict kwds):
    """
    Set the parameters for Seymour's decomposition from the dictionary ``kwds``.

    INPUT:

    - ``params`` -- the parameters object to be set

    Keyword arguments:

    - ``stop_when_irregular`` -- boolean;
      whether to stop decomposing once irregularity is determined.

    - ``stop_when_nongraphic`` -- boolean;
      whether to stop decomposing once non-graphicness (or being non-network) is determined.

    - ``stop_when_noncographic`` -- boolean;
      whether to stop decomposing once non-cographicness (or being non-conetwork) is determined.

    - ``stop_when_nongraphic_and_noncographic`` -- boolean;
      whether to stop decomposing once non-graphicness and non-cographicness
      (or not being network and not being conetwork) is determined.

    - ``series_parallel_ok`` -- boolean (default: ``True``);
      whether to allow series-parallel operations in the decomposition tree.

    - ``check_graphic_minors_planar`` -- boolean (default: ``False``);
      whether minors identified as graphic should still be checked for cographicness.

    - ``use_direct_graphicness_test`` -- boolean (default: ``True``);
      whether to use fast graphicness routines.

    - ``prefer_graphicness`` -- boolean;
      whether to first test for (co)graphicness (or being (co)network)
      before applying series-parallel reductions.

    - ``decompose_strategy`` -- among ``'delta_pivot'``, ``'y_pivot'``, ``'three_pivot'``, ``'delta_three'``, ``'y_three'``} (default: ``'delta_three'``);
      whether to perform pivots to change the rank distribution, and how to construct the children.

        The value is a bit-wise OR of two decisions, one per rank distribution:
        - CMR_SEYMOUR_DECOMPOSE_FLAG_DISTRIBUTED_MASK indicates what to do if ranks are 1 and 1.
        - CMR_SEYMOUR_DECOMPOSE_FLAG_CONCENTRATED_MASK indicates what to do if ranks are 2 and 0.

        The possible choices for distributed ranks (1 and 1) are:
        - CMR_SEYMOUR_DECOMPOSE_FLAG_DISTRIBUTED_PIVOT pivot such that the rank distribution becomes concentrated.
        - CMR_SEYMOUR_DECOMPOSE_FLAG_DISTRIBUTED_DELTASUM for the `\Delta`-sum (default).
        - CMR_SEYMOUR_DECOMPOSE_FLAG_DISTRIBUTED_YSUM for the Y-sum.

        The possible choices for concentrated ranks (2 and 0) are:
        - CMR_SEYMOUR_DECOMPOSE_FLAG_CONCENTRATED_PIVOT pivot such that the rank distribution becomes distributed.
        - CMR_SEYMOUR_DECOMPOSE_FLAG_CONCENTRATED_THREESUM for the 3-sum (default).

    .. SEEALSO:: :meth:`delta_sum`, :meth:`three_sum`

    .. NOTE::

        A decomposition as described by Seymour (``'delta_pivot'``) can be selected via CMR_SEYMOUR_DECOMPOSE_FLAG_SEYMOUR.
        A decomposition as used by Truemper (``'three_pivot'``) can be selected via CMR_SEYMOUR_DECOMPOSE_FLAG_TRUEMPER.
        The default (``'delta_three'``) is to not carry out any pivots and choose Seymour's or Truemper's definition depending on the rank distribution.

    - ``construct_leaf_graphs`` -- boolean;
      whether to construct (co)graphs for all leaf nodes that are (co)graphic or (co)network.

    - ``construct_all_graphs`` -- boolean;
      whether to construct (co)graphs for all nodes that are (co)graphic or (co)network.
    """
    CMR_CALL(CMRseymourParamsInit(params))
    params.stopWhenIrregular = kwds['stop_when_irregular']
    params.stopWhenNongraphic = kwds['stop_when_nongraphic']
    params.stopWhenNoncographic = kwds['stop_when_noncographic']
    params.stopWhenNeitherGraphicNorCoGraphic = kwds['stop_when_nongraphic_and_noncographic']
    params.directGraphicness = kwds['use_direct_graphicness_test']
    params.preferGraphicness = kwds['prefer_graphicness']
    params.seriesParallel = kwds['series_parallel_ok']
    params.planarityCheck = kwds['check_graphic_minors_planar']
    if kwds['decompose_strategy'] is not 'delta_three':
        if kwds['decompose_strategy'] == 'delta_pivot':
            params.decomposeStrategy = CMR_SEYMOUR_DECOMPOSE_FLAG_SEYMOUR
        elif kwds['decompose_strategy'] == 'three_pivot':
            params.decomposeStrategy = CMR_SEYMOUR_DECOMPOSE_FLAG_TRUEMPER
        elif kwds['decompose_strategy'] == 'y_pivot':
            params.decomposeStrategy = CMR_SEYMOUR_DECOMPOSE_FLAG_DISTRIBUTED_YSUM | CMR_SEYMOUR_DECOMPOSE_FLAG_CONCENTRATED_PIVOT
        elif kwds['decompose_strategy'] == 'y_three':
            params.decomposeStrategy = CMR_SEYMOUR_DECOMPOSE_FLAG_DISTRIBUTED_YSUM | CMR_SEYMOUR_DECOMPOSE_FLAG_CONCENTRATED_THREESUM
        else:
            params.decomposeStrategy = kwds['decompose_strategy']
    params.constructLeafGraphs = kwds['construct_leaf_graphs']
    params.constructAllGraphs = kwds['construct_all_graphs']


cdef _sage_edge(CMR_GRAPH *graph, CMR_GRAPH_EDGE e):
    return Integer(CMRgraphEdgeU(graph, e)), Integer(CMRgraphEdgeV(graph, e))


cdef _sage_edges(CMR_GRAPH *graph, CMR_GRAPH_EDGE *edges, int n, keys):
    if keys is None:
        return tuple(_sage_edge(graph, edges[i])
                     for i in range(n))
    return {key: _sage_edge(graph, edges[i])
            for i, key in enumerate(keys)}


cdef _sage_graph(CMR_GRAPH *graph):
    #

    # The indices of the vertices have no meaning.
    # TODO: Can we label them canonically based on the edges?

    # Until we have a proper CMR Graph backend, we just create a Sage graph with whatever backend
    from sage.graphs.graph import Graph

    def vertices():
        i = CMRgraphNodesFirst(graph)
        while CMRgraphNodesValid(graph, i):
            yield i
            i = CMRgraphNodesNext(graph, i)

    def edges():
        i = CMRgraphEdgesFirst(graph)
        while CMRgraphEdgesValid(graph, i):
            e = CMRgraphEdgesEdge(graph, i)
            yield _sage_edge(graph, e)
            i = CMRgraphEdgesNext(graph, i)

    return Graph([list(vertices()), list(edges())])


cdef _sage_arc(CMR_GRAPH *graph, CMR_GRAPH_EDGE e, bint reversed):
    if reversed:
        return Integer(CMRgraphEdgeV(graph, e)), Integer(CMRgraphEdgeU(graph, e))
    return Integer(CMRgraphEdgeU(graph, e)), Integer(CMRgraphEdgeV(graph, e))


cdef _sage_arcs(CMR_GRAPH *graph, CMR_GRAPH_EDGE *arcs, bool *arcs_reversed, n, keys):
    if keys is None:
        return tuple(_sage_arc(graph, arcs[i], arcs_reversed[arcs[i]])
                     for i in range(n))
    return {key: _sage_arc(graph, arcs[i], arcs_reversed[arcs[i]])
            for i, key in enumerate(keys)}


cdef _sage_digraph(CMR_GRAPH *graph, bool *arcs_reversed):
    from sage.graphs.digraph import DiGraph

    def vertices():
        i = CMRgraphNodesFirst(graph)
        while CMRgraphNodesValid(graph, i):
            yield i
            i = CMRgraphNodesNext(graph, i)

    def arcs():
        i = CMRgraphEdgesFirst(graph)
        while CMRgraphEdgesValid(graph, i):
            e = CMRgraphEdgesEdge(graph, i)
            yield _sage_arc(graph, e, arcs_reversed[e])
            i = CMRgraphEdgesNext(graph, i)

    return DiGraph([list(vertices()), list(arcs())])
