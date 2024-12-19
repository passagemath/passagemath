# sage_setup: distribution = sagemath-pari
# sage.doctest: needs sage.libs.flint sage.libs.pari sage.modules

from cysignals.signals cimport sig_on, sig_off
from cysignals.memory cimport sig_malloc, sig_free

from sage.libs.flint.fmpq cimport *
from sage.libs.flint.fmpq_mat cimport *
from sage.libs.gmp.mpq cimport mpq_init, mpq_clear, mpq_set_si, mpq_mul, mpq_add, mpq_set
from sage.matrix.matrix_rational_dense cimport Matrix_rational_dense
from sage.modules.vector_rational_dense cimport Vector_rational_dense
from sage.rings.rational cimport Rational

# ########################################################
# PARI C library
from sage.libs.pari.all import PariError
from sage.libs.pari.convert_gmp cimport INTFRAC_to_mpq
from sage.libs.pari.convert_flint cimport rational_matrix, _new_GEN_from_fmpq_mat_t
from cypari2.stack cimport clear_stack
from cypari2.paridecl cimport *
# ########################################################


def _pari(Matrix_rational_dense self):
    """
    Return pari version of this matrix.

    EXAMPLES::

        sage: matrix(QQ,2,[1/5,-2/3,3/4,4/9]).__pari__()
        [1/5, -2/3; 3/4, 4/9]
    """
    return rational_matrix(self._matrix, False)


def _det_pari(Matrix_rational_dense self, int flag=0):
    """
    Return the determinant of this matrix computed using pari.

    EXAMPLES::

        sage: from sage.matrix.matrix_rational_pari import _det_pari
        sage: _det_pari(matrix(QQ, 3, [1..9]))
        0
        sage: _det_pari(matrix(QQ, 3, [1..9]), 1)
        0
        sage: _det_pari(matrix(QQ, 3, [0] + [2..9]))
        3
    """
    sig_on()
    cdef GEN d = det0(_new_GEN_from_fmpq_mat_t(self._matrix), flag)
    # now convert d to a Sage rational
    cdef Rational e = <Rational> Rational.__new__(Rational)
    INTFRAC_to_mpq(e.value, d)
    clear_stack()
    return e


def _rank_pari(Matrix_rational_dense self):
    """
    Return the rank of this matrix computed using pari.

    EXAMPLES::

        sage: from sage.matrix.matrix_rational_pari import _rank_pari
        sage: _rank_pari(matrix(QQ, 3, [1..9]))
        2
        sage: _rank_pari(matrix(QQ, 0, 0))
        0
    """
    sig_on()
    cdef long r = rank(_new_GEN_from_fmpq_mat_t(self._matrix))
    clear_stack()
    return r


def _multiply_pari(Matrix_rational_dense self, Matrix_rational_dense right):
    """
    Return the product of ``self`` and ``right``, computed using PARI.

    EXAMPLES::

        sage: from sage.matrix.matrix_rational_pari import _multiply_pari
        sage: _multiply_pari(matrix(QQ,2,[1/5,-2/3,3/4,4/9]), matrix(QQ,2,[1,2,3,4]))
        [  -9/5 -34/15]
        [ 25/12  59/18]

    We verify that 0 rows or columns works::

        sage: x = matrix(QQ,2,0); y = matrix(QQ,0,2); x*y
        [0 0]
        [0 0]
        sage: matrix(ZZ, 0, 0) * matrix(QQ, 0, 5)
        []
    """
    if self._ncols != right._nrows:
        raise ArithmeticError("self must be a square matrix")
    if not self._ncols*self._nrows or not right._ncols*right._nrows:
        # pari doesn't work in case of 0 rows or columns
        # This case is easy, since the answer must be the 0 matrix.
        return self.matrix_space(self._nrows, right._ncols).zero_matrix().__copy__()
    sig_on()
    cdef GEN M = gmul(_new_GEN_from_fmpq_mat_t(self._matrix),
                      _new_GEN_from_fmpq_mat_t(right._matrix))
    A = new_matrix_from_pari_GEN(self.matrix_space(self._nrows, right._ncols), M)
    clear_stack()
    return A


def _invert_pari(Matrix_rational_dense self):
    """
    Return the inverse of this matrix computed using PARI.

    EXAMPLES::

        sage: from sage.matrix.matrix_rational_pari import _invert_pari
        sage: _invert_pari(matrix(QQ, 2, [1,2,3,4]))
        [  -2    1]
        [ 3/2 -1/2]
        sage: _invert_pari(matrix(QQ, 2, [1,2,2,4]))
        Traceback (most recent call last):
        ...
        PariError: impossible inverse in ginv: [1, 2; 2, 4]
    """
    if self._nrows != self._ncols:
        raise ValueError("self must be a square matrix")
    cdef GEN M, d

    sig_on()
    M = _new_GEN_from_fmpq_mat_t(self._matrix)
    d = ginv(M)
    # Convert matrix back to Sage.
    A = new_matrix_from_pari_GEN(self._parent, d)
    clear_stack()
    return A


cdef new_matrix_from_pari_GEN(parent, GEN d):
    """
    Given a PARI GEN with ``t_INT`` or ``t_FRAC entries, create a
    :class:`Matrix_rational_dense` from it.

    EXAMPLES::

        sage: from sage.matrix.matrix_rational_pari import _multiply_pari
        sage: _multiply_pari(matrix(QQ, 2, [1..4]), matrix(QQ, 2, [2..5]))  # indirect doctest
        [10 13]
        [22 29]
    """
    cdef Py_ssize_t i, j
    cdef Matrix_rational_dense B = Matrix_rational_dense.__new__(
        Matrix_rational_dense, parent, None, None, None)
    cdef mpq_t tmp
    mpq_init(tmp)
    for i in range(B._nrows):
        for j in range(B._ncols):
            INTFRAC_to_mpq(tmp, gcoeff(d, i+1, j+1))
            fmpq_set_mpq(fmpq_mat_entry(B._matrix, i, j), tmp)
    mpq_clear(tmp)
    return B
