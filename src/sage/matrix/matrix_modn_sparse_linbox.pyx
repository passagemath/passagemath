# sage_setup: distribution = sagemath-linbox
# sage.doctest: needs sage.libs.linbox

from libc.stdint cimport uint64_t
from libc.limits cimport UINT_MAX

cimport sage.libs.linbox.givaro as givaro
cimport sage.libs.linbox.linbox as linbox

from sage.arith.misc import is_prime
from sage.libs.linbox.conversion cimport (METHOD_DEFAULT,
                                          METHOD_DENSE_ELIMINATION,
                                          METHOD_SPARSE_ELIMINATION,
                                          METHOD_BLACKBOX,
                                          METHOD_WIEDEMANN,
                                          new_linbox_matrix_modn_sparse)
from sage.matrix.matrix_modn_sparse cimport Matrix_modn_sparse


def _rank_det_linbox(Matrix_modn_sparse self):
    """
    Return the rank and determinant using linbox.

    .. NOTE::

        This method does not perform any caching contrarily to
        :meth:`determinant` and :meth:`rank`.

    EXAMPLES::

        sage: from sage.matrix.matrix_modn_sparse_linbox import _rank_det_linbox
        sage: m = matrix(Zmod(13), 1, sparse=True)
        sage: m[0,0] = 0
        sage: m._rank_det_linbox()
        (0, 0)
        sage: for i in range(1, 13):
        ....:     m[0,0] = i
        ....:     assert m._rank_det_linbox() == (1, i)

        sage: m = matrix(GF(5), 2, sparse=True)
        sage: m[0,0] = 1
        sage: m[0,1] = 2
        sage: m[1,0] = 1
        sage: m[1,1] = 3
        sage: m._rank_det_linbox()
        (2, 1)
        sage: m
        [1 2]
        [1 3]

    TESTS::

        sage: matrix(Zmod(3), 0, sparse=True)._rank_det_linbox()
        (0, 1)
    """
    if self._nrows == 0 or self._ncols == 0:
        # TODO: bug in linbox (gives segfault)
        return 0, self.base_ring().one()

    cdef size_t A_rank = 0
    cdef uint64_t A_det = 0

    if not is_prime(self.p):
        raise TypeError("only GF(p) supported via LinBox")

    cdef givaro.Modular_uint64 * F = new givaro.Modular_uint64(<uint64_t> self.p)
    cdef linbox.SparseMatrix_Modular_uint64 * A
    A = new_linbox_matrix_modn_sparse(F[0], self)

    cdef linbox.GaussDomain_Modular_uint64 * dom = new linbox.GaussDomain_Modular_uint64(F[0])

    # NOTE: see above for the reason of casting...
    if A.rowdim() >= <size_t> UINT_MAX or A.coldim() >= <size_t> UINT_MAX:
        raise ValueError("row/column size unsupported in LinBox")

    dom.InPlaceLinearPivoting(A_rank, A_det, A[0], A.rowdim(), A.coldim())

    del A
    del F
    del dom

    return <long> A_rank, self.base_ring()(A_det)
