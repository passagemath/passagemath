# sage_setup: distribution = sagemath-linbox

from cysignals.signals cimport sig_on, sig_off

cimport sage.libs.linbox.givaro as givaro
cimport sage.libs.linbox.linbox as linbox
import sage.matrix.matrix_space

from sage.libs.gmp.mpq cimport *
from sage.libs.linbox.conversion cimport new_linbox_matrix_rational_sparse
from sage.matrix.matrix_rational_sparse cimport Matrix_rational_sparse
from sage.modules.vector_rational_sparse cimport *
from sage.rings.rational_field import QQ


def _right_kernel_matrix_linbox(Matrix_rational_sparse self):
    r"""
    Return a pair that includes a matrix of basis vectors
    for the right kernel of ``self``.

    OUTPUT:

    Returns a pair.  First item is the string 'computed-linbox-rational'
    that identifies the nature of the basis vectors.

    Second item is a matrix whose rows are a basis for the right kernel,
    over the rationals, as computed by the LinBox library.
    """
    # NOTE: Degenerate cases (0 rows or columns) are handled by right_kernel_matrix.

    cdef givaro.QField givQQ
    cdef linbox.SparseMatrix_rational * M = new_linbox_matrix_rational_sparse(givQQ, self)

    MQ = sage.matrix.matrix_space.MatrixSpace(QQ, self._ncols, self._ncols, sparse=True)
    A = MQ.zero_matrix().__copy__()

    cdef linbox.SparseMatrix_rational * N = new_linbox_matrix_rational_sparse(givQQ, A)

    cdef linbox.GaussDomain_rational * dom = new linbox.GaussDomain_rational(givQQ)

    cdef Matrix_rational_sparse ans
    cdef mpq_t s

    try:
        sig_on()
        dom.nullspacebasisin(N[0], M[0])
        sig_off()
    except KeyboardInterrupt:
        del N
        raise
    finally:
        del M, dom

    ans = self.new_matrix(N.coldim(), N.rowdim()) # NOTE: Transposing.
    cdef size_t i, k
    cdef Py_ssize_t j
    mpq_init(s)
    for i in range(N.rowdim()):
        for k in range(N.getRow(i).size()):
            j = <Py_ssize_t> N.getRow(i)[k].first
            entry = N.getRow(i)[k].second
            mpq_set_num(s, entry.nume().get_mpz())
            mpq_set_den(s, entry.deno().get_mpz())
            mpq_vector_set_entry(&ans._matrix[j], i, s) # NOTE: Transposing.
    mpq_clear(s)

    del N

    # Remove zero rows, if any.
    if ans.nrows() > 0:
        r = ans.nrows() - 1
        while r >= 0 and ans.row(r) == 0:
            r -= 1
        ans = ans.submatrix(0, 0, r + 1)

    return 'computed-linbox-rational', ans
