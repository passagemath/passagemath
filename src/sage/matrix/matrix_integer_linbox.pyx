# sage_setup: distribution = sagemath-linbox

from cysignals.signals cimport sig_check, sig_on, sig_str, sig_off

from sage.ext.stdsage cimport PY_NEW
from sage.libs.flint.fmpz cimport *
from sage.libs.flint.fmpz_mat cimport *
from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense
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
