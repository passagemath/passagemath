# sage_setup: distribution = sagemath-linbox
# sage.doctest: needs sage.libs.flint sage.libs.linbox

from cysignals.signals cimport sig_check, sig_on, sig_str, sig_off
from cysignals.memory cimport sig_malloc, sig_free, check_allocarray

import sage.matrix.matrix_space as matrix_space

from sage.arith.multi_modular cimport MultiModularBasis
from sage.ext.mod_int cimport *
from sage.ext.stdsage cimport PY_NEW
from sage.libs.flint.fmpz cimport *
from sage.libs.flint.fmpz_mat cimport *
from sage.libs.gmp.mpz cimport *
from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense
from sage.matrix.matrix_modn_dense_float cimport Matrix_modn_dense_template
from sage.matrix.matrix_modn_dense_float cimport Matrix_modn_dense_float
from sage.matrix.matrix_modn_dense_double cimport Matrix_modn_dense_double
from sage.misc.timing import cputime
from sage.misc.verbose import verbose
from sage.rings.finite_rings.integer_mod_ring import IntegerModRing
from sage.rings.integer cimport Integer
from sage.rings.integer_ring import ZZ
from sage.rings.polynomial.polynomial_integer_dense_flint cimport Polynomial_integer_dense_flint
from sage.rings.polynomial.polynomial_ring_constructor import PolynomialRing

######### linbox interface ##########
from sage.libs.linbox.linbox_flint_interface cimport *


def _multiply_linbox(Matrix_integer_dense self, Matrix_integer_dense right):
    """
    Multiply matrices over ZZ using linbox.

    .. WARNING::

       This is very slow right now, i.e., linbox is very slow.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_linbox import _multiply_linbox
        sage: A = matrix(ZZ, 2, 3, range(6))
        sage: A * A.transpose()
        [ 5 14]
        [14 50]
        sage: _multiply_linbox(A, A.transpose())
        [ 5 14]
        [14 50]

    TESTS:

    This fixes a bug found in :issue:`17094`::

        sage: A = identity_matrix(ZZ, 3)
        sage: _multiply_linbox(A, A)
        [1 0 0]
        [0 1 0]
        [0 0 1]
    """
    cdef Matrix_integer_dense ans
    cdef Matrix_integer_dense left = <Matrix_integer_dense> self

    ans = self._new(left._nrows, right._ncols)

    sig_on()
    linbox_fmpz_mat_mul(ans._matrix, left._matrix, right._matrix)
    sig_off()

    return ans


def _charpoly_linbox(Matrix_integer_dense self, var):
    g = (<Polynomial_integer_dense_flint> PolynomialRing(ZZ, names=var).gen())._new()
    sig_on()
    linbox_fmpz_mat_charpoly(g._poly, self._matrix)
    sig_off()
    return g


def _minpoly_linbox(Matrix_integer_dense self, var):
    g = (<Polynomial_integer_dense_flint> PolynomialRing(ZZ, names=var).gen())._new()
    sig_on()
    linbox_fmpz_mat_minpoly(g._poly, self._matrix)
    sig_off()
    return g


def _rank_linbox(Matrix_integer_dense self):
    """
    Compute the rank of this matrix using Linbox.

    TESTS::

        sage: from sage.matrix.matrix_integer_linbox import _rank_linbox
        sage: _rank_linbox(matrix(ZZ, 4, 6, 0))
        0
        sage: _rank_linbox(matrix(ZZ, 3, 4, range(12)))
        2
        sage: _rank_linbox(matrix(ZZ, 5, 10, [1+i+i^2 for i in range(50)]))
        3
    """
    sig_on()
    cdef size_t r = linbox_fmpz_mat_rank(self._matrix)
    sig_off()
    return Integer(r)


def _det_linbox(Matrix_integer_dense self):
    """
    Compute the determinant of this matrix using Linbox.

    TESTS::

        sage: from sage.matrix.matrix_integer_linbox import _det_linbox
        sage: _det_linbox(matrix(ZZ, 0))
        1
    """
    if self._nrows != self._ncols:
        raise ArithmeticError("self must be a square matrix")
    if self._nrows == 0:
        return ZZ.one()

    cdef fmpz_t tmp
    fmpz_init(tmp)
    sig_on()
    linbox_fmpz_mat_det(tmp, self._matrix)
    sig_off()

    cdef Integer ans = PY_NEW(Integer)
    fmpz_get_mpz(ans.value, tmp)
    fmpz_clear(tmp)
    return ans


def _Matrix_modn_dense_float(Matrix_integer_dense self, mod_int p):
    cdef Py_ssize_t i, j

    cdef float* res_row_f
    cdef Matrix_modn_dense_float res_f

    res_f = Matrix_modn_dense_float.__new__(Matrix_modn_dense_float,
                                            matrix_space.MatrixSpace(IntegerModRing(p), self._nrows, self._ncols, sparse=False), None, None, None, zeroed_alloc=False)
    for i from 0 <= i < self._nrows:
        res_row_f = res_f._matrix[i]
        for j from 0 <= j < self._ncols:
            res_row_f[j] = <float>fmpz_fdiv_ui(fmpz_mat_entry(self._matrix,i,j), p)
    return res_f


def _Matrix_modn_dense_double(Matrix_integer_dense self, mod_int p):
    cdef Py_ssize_t i, j

    cdef double* res_row_d
    cdef Matrix_modn_dense_double res_d

    res_d = Matrix_modn_dense_double.__new__(Matrix_modn_dense_double,
                                             matrix_space.MatrixSpace(IntegerModRing(p), self._nrows, self._ncols, sparse=False), None, None, None, zeroed_alloc=False)
    for i from 0 <= i < self._nrows:
        res_row_d = res_d._matrix[i]
        for j from 0 <= j < self._ncols:
            res_row_d[j] = <double>fmpz_fdiv_ui(fmpz_mat_entry(self._matrix,i,j), p)
    return res_d


def _multiply_multi_modular(Matrix_integer_dense self, Matrix_integer_dense right):
    """
    Multiply this matrix by ``left`` using a multi modular algorithm.

    EXAMPLES::

        sage: M = Matrix(ZZ, 2, 3, range(5,11))
        sage: N = Matrix(ZZ, 3, 2, range(15,21))
        sage: M._multiply_multi_modular(N)
        [310 328]
        [463 490]
        sage: M._multiply_multi_modular(-N)
        [-310 -328]
        [-463 -490]
    """
    cdef Integer h
    cdef Matrix_integer_dense left = <Matrix_integer_dense>self
    cdef Py_ssize_t i, k

    nr = left._nrows
    nc = right._ncols

    cdef Matrix_integer_dense result

    h = left.height() * right.height() * left.ncols()
    verbose('multiplying matrices of height %s and %s' % (left.height(),
                                                          right.height()))
    mm = MultiModularBasis(h)
    res = left._reduce(mm)
    res_right = right._reduce(mm)
    k = len(mm)
    for i in range(k):  # yes, I could do this with zip, but to conserve memory...
        t = cputime()
        res[i] *= res_right[i]
        verbose('multiplied matrices modulo a prime (%s/%s)' % (i+1, k), t)
    result = left.new_matrix(nr,nc)
    _lift_crt(result, res, mm)  # changes result
    return result


def _reduce(Matrix_integer_dense self, moduli):
    from sage.matrix.matrix_modn_dense_float import MAX_MODULUS as MAX_MODULUS_FLOAT
    from sage.matrix.matrix_modn_dense_double import MAX_MODULUS as MAX_MODULUS_DOUBLE

    if isinstance(moduli, (int, Integer)):
        return self._mod_int(moduli)
    elif isinstance(moduli, list):
        moduli = MultiModularBasis(moduli)

    cdef MultiModularBasis mm
    mm = moduli

    res = []
    for p in mm:
        if p < MAX_MODULUS_FLOAT:
            res.append( Matrix_modn_dense_float.__new__(Matrix_modn_dense_float,
                                                        matrix_space.MatrixSpace(IntegerModRing(p), self._nrows, self._ncols, sparse=False),
                                                        None, None, None, zeroed_alloc=False) )
        elif p < MAX_MODULUS_DOUBLE:
            res.append( Matrix_modn_dense_double.__new__(Matrix_modn_dense_double,
                                                         matrix_space.MatrixSpace(IntegerModRing(p), self._nrows, self._ncols, sparse=False),
                                                         None, None, None, zeroed_alloc=False) )
        else:
            raise ValueError("p=%d too big." % p)

    cdef size_t i, k, n
    cdef Py_ssize_t nr, nc
    cdef mpz_t tmp
    mpz_init(tmp)
    n = len(mm)
    nr = self._nrows
    nc = self._ncols

    cdef mod_int *entry_list
    entry_list = <mod_int*>sig_malloc(sizeof(mod_int) * n)
    if entry_list == NULL:
        raise MemoryError("out of memory allocating multi-modular coefficient list")

    sig_on()
    for i from 0 <= i < nr:
        for j from 0 <= j < nc:
            self.get_unsafe_mpz(i,j,tmp)
            mm.mpz_reduce(tmp, entry_list)
            for k from 0 <= k < n:
                if isinstance(res[k], Matrix_modn_dense_float):
                    (<Matrix_modn_dense_float>res[k])._matrix[i][j] = (<float>entry_list[k]) % (<Matrix_modn_dense_float>res[k]).p
                else:
                    (<Matrix_modn_dense_double>res[k])._matrix[i][j] = (<double>entry_list[k]) % (<Matrix_modn_dense_double>res[k]).p
    sig_off()
    mpz_clear(tmp)
    sig_free(entry_list)
    return res


cpdef _lift_crt(Matrix_integer_dense M, residues, moduli=None):
    """
    INPUT:

    - ``M`` -- a ``Matrix_integer_dense``; will be modified to hold
      the output

    - ``residues`` -- list of ``Matrix_modn_dense_template``; the
      matrix to reconstruct modulo primes

    OUTPUT: the matrix whose reductions modulo primes are the input ``residues``

    TESTS::

        sage: from sage.matrix.matrix_integer_linbox import _lift_crt
        sage: T1 = Matrix(Zmod(5), 4, 4, [1, 4, 4, 0, 2, 0, 1, 4, 2, 0, 4, 1, 1, 4, 0, 3])
        sage: T2 = Matrix(Zmod(7), 4, 4, [1, 4, 6, 0, 2, 0, 1, 2, 4, 0, 6, 6, 1, 6, 0, 5])
        sage: T3 = Matrix(Zmod(11), 4, 4, [1, 4, 10, 0, 2, 0, 1, 9, 8, 0, 10, 6, 1, 10, 0, 9])
        sage: _lift_crt(Matrix(ZZ, 4, 4), [T1, T2, T3])
        [ 1  4 -1  0]
        [ 2  0  1  9]
        [-3  0 -1  6]
        [ 1 -1  0 -2]

        sage: from sage.arith.multi_modular import MultiModularBasis
        sage: mm = MultiModularBasis([5,7,11])
        sage: _lift_crt(Matrix(ZZ, 4, 4), [T1, T2, T3], mm)
        [ 1  4 -1  0]
        [ 2  0  1  9]
        [-3  0 -1  6]
        [ 1 -1  0 -2]

    The modulus must be smaller than the maximum for the multi-modular
    reconstruction (using ``mod_int``) and also smaller than the limit
    for ``Matrix_modn_dense_double`` to be able to represent the
    ``residues`` ::

        sage: from sage.arith.multi_modular import MAX_MODULUS as MAX_multi_modular
        sage: from sage.matrix.matrix_modn_dense_double import MAX_MODULUS as MAX_modn_dense_double
        sage: MAX_MODULUS = min(MAX_multi_modular, MAX_modn_dense_double)
        sage: p0 = previous_prime(MAX_MODULUS)
        sage: p1 = previous_prime(p0)
        sage: mmod = [matrix(GF(p0), [[-1, 0, 1, 0, 0, 1, 1, 0, 0, 0, p0-1, p0-2]]),
        ....:         matrix(GF(p1), [[-1, 0, 1, 0, 0, 1, 1, 0, 0, 0, p1-1, p1-2]])]
        sage: _lift_crt(Matrix(ZZ, 1, 12), mmod)
        [-1  0  1  0  0  1  1  0  0  0 -1 -2]
    """

    cdef size_t i, j, k
    cdef Py_ssize_t nr, n
    cdef mpz_t *tmp = <mpz_t *>sig_malloc(sizeof(mpz_t) * M._ncols)
    n = len(residues)
    if n == 0:   # special case: obviously residues[0] wouldn't make sense here.
        return M
    nr = residues[0].nrows()
    nc = residues[0].ncols()

    if moduli is None:
        moduli = MultiModularBasis([m.base_ring().order() for m in residues])
    else:
        if len(residues) != len(moduli):
            raise IndexError("Number of residues (%s) does not match number of moduli (%s)" % (len(residues), len(moduli)))

    cdef MultiModularBasis mm
    mm = moduli

    for b in residues:
        if not (isinstance(b, Matrix_modn_dense_float) or
                isinstance(b, Matrix_modn_dense_double)):
            raise TypeError("Can only perform CRT on list of matrices mod n.")

    cdef mod_int **row_list
    row_list = <mod_int**>sig_malloc(sizeof(mod_int*) * n)
    if row_list == NULL:
        raise MemoryError("out of memory allocating multi-modular coefficient list")

    sig_on()
    for k in range(n):
        row_list[k] = <mod_int *>sig_malloc(sizeof(mod_int) * nc)
        if row_list[k] == NULL:
            raise MemoryError("out of memory allocating multi-modular coefficient list")

    for j in range(M._ncols):
        mpz_init(tmp[j])

    for i in range(nr):
        for k in range(n):
            (<Matrix_modn_dense_template>residues[k])._copy_row_to_mod_int_array(row_list[k],i)
        mm.mpz_crt_vec(tmp, row_list, nc)
        for j in range(nc):
            M.set_unsafe_mpz(i,j,tmp[j])

    for k in range(n):
        sig_free(row_list[k])
    for j in range(M._ncols):
        mpz_clear(tmp[j])
    sig_free(row_list)
    sig_free(tmp)
    sig_off()
    return M
