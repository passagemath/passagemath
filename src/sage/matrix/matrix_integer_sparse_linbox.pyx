# sage_setup: distribution = sagemath-linbox
# sage.doctest: needs sage.libs.flint sage.libs.linbox

from cpython.long cimport PyLong_FromSize_t

from cysignals.signals cimport sig_check, sig_on, sig_str, sig_off

from sage.ext.stdsage cimport PY_NEW
from sage.libs.flint.fmpz cimport *
from sage.libs.flint.fmpz_mat cimport *
from sage.libs.flint.fmpz_poly_sage cimport fmpz_poly_set_coeff_mpz
from sage.libs.flint.fmpz_poly cimport fmpz_poly_fit_length, _fmpz_poly_set_length
from sage.libs.gmp.mpz cimport *
from sage.matrix.matrix cimport Matrix
from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense
from sage.matrix.matrix_integer_sparse cimport Matrix_integer_sparse
from sage.modules.vector_integer_dense cimport Vector_integer_dense
from sage.rings.integer cimport Integer
from sage.rings.integer_ring import ZZ
from sage.rings.polynomial.polynomial_integer_dense_flint cimport Polynomial_integer_dense_flint

cimport sage.libs.linbox.givaro as givaro
cimport sage.libs.linbox.linbox as linbox
from sage.libs.linbox.conversion cimport (
    new_linbox_vector_integer_dense,
    new_sage_vector_integer_dense,
    new_linbox_matrix_integer_sparse,
    METHOD_DEFAULT, METHOD_DENSE_ELIMINATION,
    METHOD_SPARSE_ELIMINATION, METHOD_BLACKBOX,
    METHOD_WIEDEMANN, get_method)


def _rank_linbox(Matrix_integer_sparse self):
    r"""
    Compute the rank using linbox.

    The result is not cached contrarily to the method ``rank``.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_sparse_linbox import _rank_linbox
        sage: M = MatrixSpace(ZZ, 3, sparse=True)
        sage: m = M([1,0,1,0,2,0,2,0,2])
        sage: _rank_linbox(m)
        2

    TESTS::

        sage: _rank_linbox(MatrixSpace(ZZ, 0, 0, sparse=True)())
        0
        sage: _rank_linbox(MatrixSpace(ZZ, 1, 0, sparse=True)())
        0
        sage: _rank_linbox(MatrixSpace(ZZ, 0, 1, sparse=True)())
        0
        sage: _rank_linbox(MatrixSpace(ZZ, 1, 1, sparse=True)())
        0
    """
    if self._nrows == 0 or self._ncols == 0:
        return 0

    cdef givaro.ZRing givZZ
    cdef linbox.SparseMatrix_integer * M = new_linbox_matrix_integer_sparse(givZZ, self)
    cdef size_t r = 0

    sig_on()
    linbox.rank(r, M[0])
    sig_off()

    del M

    return PyLong_FromSize_t(r)


def _det_linbox(Matrix_integer_sparse self):
    r"""
    Return the determinant computed with LinBox.

    .. NOTE::

        This method is much slower than converting to a dense matrix and
        computing the determinant there. There is not much point in making
        it available. See :issue:`28318`.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_sparse_linbox import _det_linbox
        sage: M = MatrixSpace(ZZ, 2, 2, sparse=True)
        sage: _det_linbox(M([2,0,1,1]))
        2

    TESTS::

        sage: _det_linbox(MatrixSpace(ZZ, 0, 0, sparse=True)())
        1
        sage: _det_linbox(MatrixSpace(ZZ, 1, 1, sparse=True)())
        0

        sage: m = diagonal_matrix(ZZ, [2] * 46)
        sage: _det_linbox(m) == 2**46
        True

        sage: m = diagonal_matrix(ZZ, [3] * 100)
        sage: _det_linbox(m) == 3**100
        True
    """
    if self._nrows != self._ncols:
        raise ValueError("non square matrix")

    if self._nrows == 0:
        return Integer(1)

    cdef givaro.ZRing givZZ
    cdef linbox.SparseMatrix_integer * M = new_linbox_matrix_integer_sparse(givZZ, self)
    cdef givaro.Integer D

    sig_on()
    linbox.det(D, M[0])
    sig_off()

    cdef Integer d = PY_NEW(Integer)
    mpz_set(d.value, D.get_mpz_const())

    del M

    return d


def _charpoly_linbox(Matrix_integer_sparse self, var='x'):
    r"""
    Compute the charpoly using LinBox.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_sparse_linbox import _charpoly_linbox
        sage: m = matrix(ZZ, 2, [2,1,1,1], sparse=True)
        sage: _charpoly_linbox(m)
        x^2 - 3*x + 1

    TESTS::

        sage: _charpoly_linbox(matrix(ZZ, 0, 0, sparse=True))
        1
        sage: _charpoly_linbox(matrix(ZZ, 1, 1, sparse=True))
        x
    """
    cdef mpz_t tmp
    if self._nrows != self._ncols:
        raise ArithmeticError('only valid for square matrix')

    from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
    R = PolynomialRing(ZZ, names=var)

    # TODO: bug in LinBox (got SIGSEGV)
    if self._nrows == 0:
        return R.one()

    cdef givaro.ZRing givZZ
    cdef linbox.SparseMatrix_integer * M = new_linbox_matrix_integer_sparse(givZZ, self)
    cdef linbox.DensePolynomial_integer * p = new linbox.DensePolynomial_integer(givZZ, <size_t> self._nrows)
    cdef Polynomial_integer_dense_flint g = (<Polynomial_integer_dense_flint> R.gen())._new()

    sig_on()
    linbox.charpoly(p[0], M[0])
    sig_off()

    cdef size_t i
    fmpz_poly_fit_length(g._poly, p.size())
    for i in range(p.size()):
        tmp = p[0][i].get_mpz_const()
        fmpz_poly_set_coeff_mpz(g._poly, i, tmp)
    _fmpz_poly_set_length(g._poly, p.size())

    del M
    del p

    return g


def _minpoly_linbox(Matrix_integer_sparse self, var='x'):
    r"""
    Compute the minpoly using LinBox.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_sparse_linbox import _minpoly_linbox
        sage: m = matrix(ZZ, 2, [2,1,1,1], sparse=True)
        sage: _minpoly_linbox(m)
        x^2 - 3*x + 1

    TESTS::

        sage: _minpoly_linbox(matrix(ZZ, 0, 0, sparse=True))
        1
        sage: _minpoly_linbox(matrix(ZZ, 1, 1, sparse=True))
        x
    """
    if self._nrows != self._ncols:
        raise ArithmeticError('only valid for square matrix')

    from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing
    R = PolynomialRing(ZZ, names=var)

    # TODO: bug in LinBox (got SIGSEGV)
    if self._nrows == 0:
        return R.one()

    cdef givaro.ZRing givZZ
    cdef linbox.SparseMatrix_integer * M = new_linbox_matrix_integer_sparse(givZZ, self)
    cdef linbox.DensePolynomial_integer * p = new linbox.DensePolynomial_integer(givZZ, <size_t> self._nrows)
    cdef Polynomial_integer_dense_flint g = (<Polynomial_integer_dense_flint> R.gen())._new()

    sig_on()
    linbox.minpoly(p[0], M[0])
    sig_off()

    cdef size_t i
    cdef mpz_t tmp
    fmpz_poly_fit_length(g._poly, p.size())
    for i in range(p.size()):
        tmp = p[0][i].get_mpz_const()
        fmpz_poly_set_coeff_mpz(g._poly, i, tmp)
    _fmpz_poly_set_length(g._poly, p.size())

    del M
    del p

    return g


def _solve_vector_linbox(Matrix_integer_sparse self, v, algorithm=None):
    r"""
    Return a pair ``(a, d)`` so that ``d * b = m * a``.

    If there is no solution a :exc:`ValueError` is raised.

    INPUT:

    - ``b`` -- dense integer vector

    - ``algorithm`` -- (optional) either ``None``, ``'dense_elimination'``,
      ``'sparse_elimination'``, ``'wiedemann'`` or ``'blackbox'``

    OUTPUT: a pair ``(a, d)`` consisting of

    - ``a`` -- dense integer vector

    - ``d`` -- integer

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_sparse_linbox import _solve_vector_linbox
        sage: m = matrix(ZZ, 4, sparse=True)
        sage: m[0,0] = m[1,2] = m[2,0] = m[3,3] = 2
        sage: m[0,2] = m[1,1] = -1
        sage: m[2,3] = m[3,0] = -3

        sage: b0 = vector((1,1,1,1))
        sage: _solve_vector_linbox(m, b0)
        ((-1, -7, -3, -1), 1)
        sage: _solve_vector_linbox(m, b0, 'dense_elimination')
        ((-1, -7, -3, -1), 1)
        sage: _solve_vector_linbox(m, b0, 'sparse_elimination')
        ((-1, -7, -3, -1), 1)
        sage: _solve_vector_linbox(m, b0, 'wiedemann')
        ((-1, -7, -3, -1), 1)
        sage: _solve_vector_linbox(m, b0, 'blackbox')
        ((-1, -7, -3, -1), 1)

        sage: b1 = vector((1,2,3,4))
        sage: _solve_vector_linbox(m, b1)
        ((-18, -92, -41, -17), 5)
        sage: _solve_vector_linbox(m, b1, 'dense_elimination')
        ((-18, -92, -41, -17), 5)
        sage: _solve_vector_linbox(m, b1, 'sparse_elimination')
        ((-18, -92, -41, -17), 5)
        sage: _solve_vector_linbox(m, b1, 'wiedemann')
        ((-18, -92, -41, -17), 5)
        sage: _solve_vector_linbox(m, b1, 'blackbox')
        ((-18, -92, -41, -17), 5)

        sage: a1, d1 = _solve_vector_linbox(m, b1)
        sage: d1 * b1 == m * a1
        True

    TESTS::

        sage: algos = ["default", "dense_elimination", "sparse_elimination",
        ....:          "blackbox", "wiedemann"]
        sage: for i in range(20):
        ....:     dim = randint(1, 30)
        ....:     M = MatrixSpace(ZZ, dim, sparse=True)
        ....:     density = min(1, 4/dim)
        ....:     m = M.random_element(density=density)
        ....:     while m.rank() != dim:
        ....:         m = M.random_element(density=density)
        ....:     U = m.column_space().dense_module()
        ....:     for algo in algos:
        ....:         u, d = _solve_vector_linbox(m, U.zero(), algorithm=algo)
        ....:         assert u.is_zero()
        ....:         b = U.random_element()
        ....:         x, d = _solve_vector_linbox(m, b, algorithm=algo)
        ....:         assert m * x == d * b
    """
    Vin = self.column_ambient_module(base_ring=None, sparse=False)
    v = Vin(v)

    if self._nrows == 0 or self._ncols == 0:
        raise ValueError("not implemented for nrows=0 or ncols=0")

    # LinBox "solve" is mostly broken for nonsquare or singular matrices.
    # The conditions below could be removed once all LinBox issues has
    # been solved.
    if self._nrows != self._ncols or self.rank() != self._nrows:
        raise ValueError("only available for full rank square matrices")

    cdef givaro.ZRing givZZ
    cdef linbox.SparseMatrix_integer * A = new_linbox_matrix_integer_sparse(givZZ, self)
    cdef linbox.DenseVector_integer * b = new_linbox_vector_integer_dense(givZZ, v)
    cdef linbox.DenseVector_integer * res = new linbox.DenseVector_integer(givZZ, <size_t> self._ncols)
    cdef givaro.Integer D

    method = get_method(algorithm)

    sig_on()
    if method == METHOD_DEFAULT:
        linbox.solve(res[0], D, A[0], b[0])
    elif method == METHOD_WIEDEMANN:
        linbox.solve(res[0], D, A[0], b[0], linbox.Method.Wiedemann())
    elif method == METHOD_DENSE_ELIMINATION:
        linbox.solve(res[0], D, A[0], b[0], linbox.Method.DenseElimination())
    elif method == METHOD_SPARSE_ELIMINATION:
        linbox.solve(res[0], D, A[0], b[0], linbox.Method.SparseElimination())
    elif method == METHOD_BLACKBOX:
        linbox.solve(res[0], D, A[0], b[0], linbox.Method.Blackbox())
    sig_off()

    Vout = self.row_ambient_module(base_ring=None, sparse=False)
    res_sage = new_sage_vector_integer_dense(Vout, res[0])
    cdef Integer d = PY_NEW(Integer)
    mpz_set(d.value, D.get_mpz_const())

    del A
    del b
    del res

    return (res_sage, d)


def _solve_matrix_linbox(Matrix_integer_sparse self, mat, algorithm=None):
    r"""
    Solve the equation ``A x = mat`` where ``A`` is this matrix.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_sparse_linbox import _solve_matrix_linbox
        sage: m = matrix(ZZ, [[1,2],[1,0]], sparse=True)
        sage: b = matrix(ZZ, 2, 4, [1,0,2,0,1,1,2,0], sparse=False)
        sage: u, d = _solve_matrix_linbox(m, b)
        sage: u
        [ 1  2  2  0]
        [ 0 -1  0  0]
        sage: m * u == b * diagonal_matrix(d)
        True

        sage: u, d = _solve_matrix_linbox(m, [[1,3,4],[0,1,0]])
        sage: u
        [0 1 0]
        [1 1 2]
        sage: d
        (2, 1, 1)

    Test input::

        sage: m = matrix(ZZ, [[1,2],[1,0]], sparse=True)
        sage: b = matrix(ZZ, 3, 3, range(9))
        sage: _solve_matrix_linbox(m, b)
        Traceback (most recent call last):
        ...
        ValueError: wrong matrix dimension

        sage: _solve_matrix_linbox(m, [[1,1],[2,3]], algorithm='hop')
        Traceback (most recent call last):
        ...
        ValueError: unknown algorithm

    TESTS::

        sage: algos = ["default", "dense_elimination", "sparse_elimination",
        ....:          "blackbox", "wiedemann"]

        sage: for _ in range(10):
        ....:     dim = randint(2, 10)
        ....:     M = MatrixSpace(ZZ, dim, sparse=True)
        ....:     m = M.random_element(density=min(1,10/dim))
        ....:     while m.rank() != dim:
        ....:         m = M.random_element(density=min(1,10/dim))
        ....:     b = random_matrix(ZZ, dim, 7)
        ....:     Mb = b.parent()
        ....:     for algo in algos:
        ....:         u, d = _solve_matrix_linbox(m, b, algo)
        ....:         assert m * u == b * diagonal_matrix(d)
    """
    if self._nrows == 0 or self._ncols == 0:
        raise ValueError("not implemented for nrows=0 or ncols=0")

    from sage.matrix.constructor import matrix
    from sage.modules.free_module_element import vector

    cdef Matrix_integer_dense B
    if not isinstance(mat, Matrix):
        B = <Matrix_integer_dense?> matrix(ZZ, mat, sparse=False)
    else:
        B = <Matrix_integer_dense?> mat.change_ring(ZZ).dense_matrix()
    if B._nrows != self._nrows:
        raise ValueError("wrong matrix dimension")

    # LinBox "solve" is mostly broken for singular matrices. The
    # conditions below could be removed once all LinBox issues
    # have been solved.
    if self._nrows != self._ncols or self.rank() != self._nrows:
        raise ValueError("only available for full rank square matrices")

    cdef givaro.ZRing givZZ
    cdef linbox.SparseMatrix_integer * A = new_linbox_matrix_integer_sparse(givZZ, self)
    cdef linbox.DenseVector_integer * b = new linbox.DenseVector_integer(givZZ, <size_t> self._nrows)
    cdef linbox.DenseVector_integer * res = new linbox.DenseVector_integer(givZZ, <size_t> self._ncols)
    cdef givaro.Integer D

    cdef int algo = get_method(algorithm)

    cdef Matrix_integer_dense X = matrix(ZZ, A.coldim(), B.ncols(), sparse=False)  # solution
    cdef Vector_integer_dense d = vector(ZZ, X.ncols(), sparse=False)  # multipliers

    sig_on()
    cdef size_t i, j
    for i in range(X.ncols()):
        # set b to the i-th column of B
        for j in range(A.coldim()):
            fmpz_get_mpz(<mpz_t> b.getEntry(j).get_mpz(), fmpz_mat_entry(B._matrix, j, i))

        # solve the current row
        if algo == METHOD_DEFAULT:
            linbox.solve(res[0], D, A[0], b[0])
        elif algo == METHOD_DENSE_ELIMINATION:
            linbox.solve(res[0], D, A[0], b[0], linbox.Method.DenseElimination())
        elif algo == METHOD_SPARSE_ELIMINATION:
            linbox.solve(res[0], D, A[0], b[0], linbox.Method.SparseElimination())
        elif algo == METHOD_BLACKBOX:
            linbox.solve(res[0], D, A[0], b[0], linbox.Method.Blackbox())
        elif algo == METHOD_WIEDEMANN:
            linbox.solve(res[0], D, A[0], b[0], linbox.Method.Wiedemann())

        # set i-th column of X to be res
        for j in range(A.coldim()):
            fmpz_set_mpz(fmpz_mat_entry(X._matrix, j, i), res[0].getEntry(j).get_mpz())

        # compute common gcd
        mpz_set(d._entries[i], D.get_mpz_const())
    sig_off()

    del A
    del b
    del res

    return X, d
