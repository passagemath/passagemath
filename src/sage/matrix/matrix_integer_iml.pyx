# sage_setup: distribution = sagemath-linbox
# distutils: libraries = iml
# sage.doctest: needs sage.libs.flint sage.libs.linbox

from cysignals.signals cimport sig_check, sig_on, sig_str, sig_off
from cysignals.memory cimport sig_malloc, sig_free, check_allocarray

from sage.libs.flint.fmpz cimport *
from sage.libs.flint.fmpz_mat cimport *
from sage.libs.gmp.mpz cimport *
from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense
from sage.misc.verbose import verbose
from sage.rings.integer cimport Integer


########## iml -- integer matrix library ###########
from sage.libs.iml cimport *


def _rational_kernel_iml(Matrix_integer_dense self):
    """
    Return the rational (left) kernel of this matrix.

    OUTPUT:

    A matrix ``K`` such that ``self * K = 0``, and the number of columns of
    K equals the nullity of ``self``.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_iml import _rational_kernel_iml
        sage: m = matrix(ZZ, 5, 5, [1+i+i^2 for i in range(25)])
        sage: _rational_kernel_iml(m)
        [ 1  3]
        [-3 -8]
        [ 3  6]
        [-1  0]
        [ 0 -1]

        sage: V1 = _rational_kernel_iml(m).column_space().change_ring(QQ)
        sage: V2 = m._rational_kernel_flint().column_space().change_ring(QQ)
        sage: assert V1 == V2
    """
    if self._nrows == 0 or self._ncols == 0:
        return self.matrix_space(self._ncols, 0).zero_matrix()

    cdef long dim
    cdef unsigned long i,j,k
    cdef mpz_t *mp_N
    time = verbose('computing null space of %s x %s matrix using IML'%(self._nrows, self._ncols))
    cdef mpz_t * m = fmpz_mat_to_mpz_array(self._matrix)
    sig_on()
    dim = nullspaceMP(self._nrows, self._ncols, m, &mp_N)
    sig_off()
    # Now read the answer as a matrix.
    cdef Matrix_integer_dense M
    M = self._new(self._ncols, dim)
    k = 0
    for i in range(self._ncols):
        for j in range(dim):
            fmpz_set_mpz(fmpz_mat_entry(M._matrix, i, j), mp_N[k])
            k += 1
    mpz_array_clear(m, self._nrows * self._ncols)
    mpz_array_clear(mp_N, dim * self._ncols)
    verbose("finished computing null space", time)
    return M


def _invert_iml(Matrix_integer_dense self, use_nullspace=False, check_invertible=True):
    """
    Invert this matrix using IML. The output matrix is an integer
    matrix and a denominator.

    INPUT:

    - ``self`` -- an invertible matrix

    - ``use_nullspace`` -- boolean (default: ``False``); whether to
      use nullspace algorithm, which is slower, but doesn't require
      checking that the matrix is invertible as a precondition

    - ``check_invertible`` -- boolean (default: ``True``); whether to
      check that the matrix is invertible

    OUTPUT: `A`, `d` such that ``A*self == d``

    - ``A`` -- a matrix over ZZ

    - ``d`` -- integer

    ALGORITHM: Uses IML's `p`-adic nullspace function.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_iml import _invert_iml
        sage: a = matrix(ZZ,3,[1,2,5, 3,7,8, 2,2,1])
        sage: b, d = _invert_iml(a); b,d
        (
        [  9  -8  19]
        [-13   9  -7]
        [  8  -2  -1], 23
        )
        sage: a*b
        [23  0  0]
        [ 0 23  0]
        [ 0  0 23]

    AUTHORS:

    - William Stein
    """
    if self._nrows != self._ncols:
        raise TypeError("self must be a square matrix.")

    P = self.parent()
    time = verbose('computing inverse of %s x %s matrix using IML'%(self._nrows, self._ncols))
    if use_nullspace:
        A = self.augment(P.identity_matrix())
        K = A._rational_kernel_iml()
        d = -K[self._nrows,0]
        if K.ncols() != self._ncols or d == 0:
            raise ZeroDivisionError("input matrix must be nonsingular")
        B = K[:self._nrows]
        verbose("finished computing inverse using IML", time)
        return B, d
    else:
        if check_invertible and self.rank() != self._nrows:
            raise ZeroDivisionError("input matrix must be nonsingular")
        return _solve_iml(self, P.identity_matrix(), right=True)


def _solve_iml(Matrix_integer_dense self, Matrix_integer_dense B, right=True):
    """
    Let A equal ``self`` be a square matrix. Given B return an integer
    matrix C and an integer d such that ``self`` ``C*A == d*B`` if right is
    False or ``A*C == d*B`` if right is True.

    OUTPUT:

    - ``C`` -- integer matrix

    - ``d`` -- integer denominator

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_iml import _solve_iml
        sage: A = matrix(ZZ,4,4,[0, 1, -2, -1, -1, 1, 0, 2, 2, 2, 2, -1, 0, 2, 2, 1])
        sage: B = matrix(ZZ,3,4, [-1, 1, 1, 0, 2, 0, -2, -1, 0, -2, -2, -2])
        sage: C, d = _solve_iml(A, B, right=False); C
        [  6 -18 -15  27]
        [  0  24  24 -36]
        [  4 -12  -6  -2]

    ::

        sage: d
        12

    ::

        sage: C*A == d*B
        True

    ::

        sage: A = matrix(ZZ,4,4,[0, 1, -2, -1, -1, 1, 0, 2, 2, 2, 2, -1, 0, 2, 2, 1])
        sage: B = matrix(ZZ,4,3, [-1, 1, 1, 0, 2, 0, -2, -1, 0, -2, -2, -2])
        sage: C, d = _solve_iml(A, B)
        sage: C
        [ 12  40  28]
        [-12  -4  -4]
        [ -6 -25 -16]
        [ 12  34  16]

    ::

        sage: d
        12

    ::

        sage: A*C == d*B
        True

    Test wrong dimensions::

        sage: A = random_matrix(ZZ, 4, 4)
        sage: B = random_matrix(ZZ, 2, 3)
        sage: _solve_iml(B, A)
        Traceback (most recent call last):
        ...
        ValueError: self must be a square matrix
        sage: _solve_iml(A, B, right=False)
        Traceback (most recent call last):
        ...
        ArithmeticError: B's number of columns must match self's number of rows
        sage: _solve_iml(A, B, right=True)
        Traceback (most recent call last):
        ...
        ArithmeticError: B's number of rows must match self's number of columns

    Check that this can be interrupted properly (:issue:`15453`)::

        sage: A = random_matrix(ZZ, 2000, 2000)
        sage: B = random_matrix(ZZ, 2000, 2000)
        sage: t0 = walltime()
        sage: alarm(2); _solve_iml(A, B)  # long time
        Traceback (most recent call last):
        ...
        AlarmInterrupt
        sage: t = walltime(t0)
        sage: t < 10 or t
        True

    ALGORITHM: Uses IML.

    AUTHORS:

    - Martin Albrecht
    """
    cdef unsigned long i, j, k
    cdef mpz_t *mp_N
    cdef mpz_t mp_D
    cdef Matrix_integer_dense M
    cdef Integer D

    if self._nrows != self._ncols:
        # This is *required* by the IML function we call below.
        raise ValueError("self must be a square matrix")

    if self._nrows == 1:
        return B, self[0,0]

    cdef SOLU_POS solu_pos

    if right:
        if self._ncols != B._nrows:
            raise ArithmeticError("B's number of rows must match self's number of columns")

        n = self._ncols
        m = B._ncols

        P = self.matrix_space(n, m)
        if self._nrows == 0 or self._ncols == 0:
            return P.zero_matrix(), Integer(1)

        if m == 0 or n == 0:
            return self.new_matrix(nrows = n, ncols = m), Integer(1)

        solu_pos = RightSolu

    else: # left
        if self._nrows != B._ncols:
            raise ArithmeticError("B's number of columns must match self's number of rows")

        n = self._ncols
        m = B._nrows

        P = self.matrix_space(m, n)
        if self._nrows == 0 or self._ncols == 0:
            return P.zero_matrix(), Integer(1)

        if m == 0 or n == 0:
            return self.new_matrix(nrows = m, ncols = n), Integer(1)

        solu_pos = LeftSolu

    sig_check()
    verbose("Initializing mp_N and mp_D")
    mp_N = <mpz_t *> sig_malloc( n * m * sizeof(mpz_t) )
    for i in range(n * m):
        mpz_init(mp_N[i])
    mpz_init(mp_D)
    verbose("Done with initializing mp_N and mp_D")
    cdef mpz_t * mself = fmpz_mat_to_mpz_array(self._matrix)
    cdef mpz_t * mB = fmpz_mat_to_mpz_array(B._matrix)
    try:
        verbose('Calling solver n = %s, m = %s'%(n,m))
        sig_on()
        nonsingSolvLlhsMM(solu_pos, n, m, mself, mB, mp_N, mp_D)
        sig_off()
        M = self._new(P.nrows(), P.ncols())
        k = 0
        for i from 0 <= i < M._nrows:
            for j from 0 <= j < M._ncols:
                fmpz_set_mpz(fmpz_mat_entry(M._matrix,i,j), mp_N[k])
                k += 1
        D = Integer.__new__(Integer)
        mpz_set(D.value, mp_D)
        return M, D
    finally:
        mpz_clear(mp_D)
        mpz_array_clear(mself, self.nrows() * self.ncols())
        mpz_array_clear(mB, B.nrows() * B.ncols())
        mpz_array_clear(mp_N, n*m)


cdef inline mpz_t * fmpz_mat_to_mpz_array(fmpz_mat_t m) except? NULL:
    cdef mpz_t * entries = <mpz_t *>check_allocarray(fmpz_mat_nrows(m), sizeof(mpz_t) * fmpz_mat_ncols(m))
    cdef size_t i, j
    cdef size_t k = 0
    sig_on()
    for i in range(fmpz_mat_nrows(m)):
        for j in range(fmpz_mat_ncols(m)):
            mpz_init(entries[k])
            fmpz_get_mpz(entries[k], fmpz_mat_entry(m, i, j))
            k += 1
    sig_off()
    return entries


cdef inline void mpz_array_clear(mpz_t * a, size_t length) noexcept:
    cdef size_t i
    for i in range(length):
        mpz_clear(a[i])
    sig_free(a)
