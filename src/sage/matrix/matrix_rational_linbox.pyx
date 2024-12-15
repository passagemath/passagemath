# sage_setup: distribution = sagemath-linbox

from sage.arith.rational_reconstruction cimport mpq_rational_reconstruction
from sage.libs.flint.fmpq cimport fmpq_is_zero, fmpq_set_mpq, fmpq_canonicalise
from sage.libs.flint.fmpq_mat cimport fmpq_mat_entry_num, fmpq_mat_entry_den, fmpq_mat_entry
from sage.libs.flint.fmpz cimport fmpz_init, fmpz_clear, fmpz_set_mpz, fmpz_one, fmpz_get_mpz, fmpz_add, fmpz_mul, fmpz_sub, fmpz_mul_si, fmpz_mul_si, fmpz_mul_si, fmpz_divexact, fmpz_lcm
from sage.libs.flint.fmpz_mat cimport *
from sage.libs.gmp.mpz cimport mpz_init, mpz_clear, mpz_cmp_si
from sage.libs.gmp.mpq cimport mpq_init, mpq_clear, mpq_set_si, mpq_mul, mpq_add, mpq_set
from sage.libs.gmp.types cimport mpz_t, mpq_t
from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense
from sage.matrix.matrix_rational_dense cimport Matrix_rational_dense
from sage.matrix.matrix_integer_linbox cimport _lift_crt
from sage.rings.integer cimport Integer


def _lift_crt_rr(Matrix_rational_dense self, res, mm):
    cdef Integer m
    cdef Matrix_integer_dense ZA
    cdef Matrix_rational_dense QA
    cdef Py_ssize_t i, j
    cdef mpz_t tmp
    cdef mpq_t tmp2
    mpz_init(tmp)
    mpq_init(tmp2)
    ZA = _lift_crt(res, mm)
    QA = Matrix_rational_dense.__new__(Matrix_rational_dense, self.parent(), None, None, None)
    m = mm.prod()
    for i in range(ZA._nrows):
        for j in range(ZA._ncols):
            fmpz_get_mpz(tmp, fmpz_mat_entry(ZA._matrix,i,j))
            mpq_rational_reconstruction(tmp2, tmp, m.value)
            fmpq_set_mpq(fmpq_mat_entry(QA._matrix, i, j), tmp2)
    mpz_clear(tmp)
    mpq_clear(tmp2)
    return QA
