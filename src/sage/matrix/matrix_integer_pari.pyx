# sage_setup: distribution = sagemath-pari
# sage.doctest: needs sage.libs.flint sage.libs.pari sage.modules

from cysignals.signals cimport sig_check, sig_on, sig_str, sig_off

from sage.libs.flint.fmpz cimport *
from sage.libs.flint.fmpz_mat cimport *
from sage.libs.gmp.mpz cimport *
from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense
from sage.rings.integer cimport Integer
from sage.rings.integer_ring import ZZ

# PARI C library
from cypari2.gen cimport Gen
from cypari2.stack cimport clear_stack, new_gen
from cypari2.paridecl cimport *
from sage.libs.pari import pari
from sage.libs.pari.convert_gmp cimport INT_to_mpz
from sage.libs.pari.convert_flint cimport (_new_GEN_from_fmpz_mat_t,
           _new_GEN_from_fmpz_mat_t_rotate90, integer_matrix)
from sage.libs.pari.convert_sage_matrix import gen_to_sage_matrix


def _pari(Matrix_integer_dense self):
    return integer_matrix(self._matrix, 0)


def _det_pari(Matrix_integer_dense self, int flag=0):
    """
    Determinant of this matrix using Gauss-Bareiss. If (optional)
    flag is set to 1, use classical Gaussian elimination.

    For efficiency purposes, this det is computed entirely on the
    PARI stack then the PARI stack is cleared. This function is
    most useful for very small matrices.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_pari import _det_pari
        sage: _det_pari(matrix(ZZ, 0))
        1
        sage: _det_pari(matrix(ZZ, 0), 1)
        1
        sage: _det_pari(matrix(ZZ, 3, [1..9]))
        0
        sage: _det_pari(matrix(ZZ, 3, [1..9]), 1)
        0
    """
    sig_on()
    cdef GEN d = det0(pari_GEN(self), flag)
    # now convert d to a Sage integer e
    cdef Integer e = Integer.__new__(Integer)
    INT_to_mpz(e.value, d)
    clear_stack()
    return e


def _lll_pari(Matrix_integer_dense self):
    # call pari with flag=4: kernel+image
    # pari uses column convention: need to transpose the matrices
    A = integer_matrix(self._matrix, 1)
    K, T = A.qflll(4)
    r = ZZ(T.length())
    # TODO: there is no optimized matrix converter pari -> sage
    U = gen_to_sage_matrix(pari.matconcat([K, T]).mattranspose())
    R = U * self
    return R, U, r


def _rank_pari(Matrix_integer_dense self):
    """
    Rank of this matrix, computed using PARI.  The computation is
    done entirely on the PARI stack, then the PARI stack is
    cleared.  This function is most useful for very small
    matrices.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_pari import _rank_pari
        sage: _rank_pari(matrix(ZZ,3,[1..9]))
        2
    """
    sig_on()
    cdef long r = rank(pari_GEN(self))
    clear_stack()
    return r


def _hnf_pari(Matrix_integer_dense self, int flag=0, bint include_zero_rows=True):
    """
    Hermite normal form of this matrix, computed using PARI.

    INPUT:

    - ``flag`` -- 0 (default), 1, 3 or 4 (see docstring for
      ``pari.mathnf``)

    - ``include_zero_rows`` -- boolean; if ``False``, do not include
      any of the zero rows at the bottom of the matrix in the output

    .. NOTE::

        In no cases is the transformation matrix returned by this
        function.

    EXAMPLES::

        sage: from sage.matrix.matrix_integer_pari import _hnf_pari
        sage: _hnf_pari(matrix(ZZ,3,[1..9]))
        [1 2 3]
        [0 3 6]
        [0 0 0]
        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 1)
        [1 2 3]
        [0 3 6]
        [0 0 0]
        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 3)
        [1 2 3]
        [0 3 6]
        [0 0 0]
        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 4)
        [1 2 3]
        [0 3 6]
        [0 0 0]

    Check that ``include_zero_rows=False`` works correctly::

        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 0, include_zero_rows=False)
        [1 2 3]
        [0 3 6]
        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 1, include_zero_rows=False)
        [1 2 3]
        [0 3 6]
        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 3, include_zero_rows=False)
        [1 2 3]
        [0 3 6]
        sage: _hnf_pari(matrix(ZZ,3,[1..9]), 4, include_zero_rows=False)
        [1 2 3]
        [0 3 6]

    Check that :issue:`12346` is fixed::

        sage: pari('mathnf(Mat([0,1]), 4)')
        [Mat(1), [1, 0; 0, 1]]
    """
    sig_on()
    A = _new_GEN_from_fmpz_mat_t_rotate90(self._matrix)
    H = mathnf0(A, flag)
    if typ(H) == t_VEC:
        H = gel(H, 1)
    GenH = new_gen(H)
    return extract_hnf_from_pari_matrix(self, GenH, include_zero_rows)


cdef inline GEN pari_GEN(Matrix_integer_dense B) noexcept:
    r"""
    Create the PARI GEN object on the stack defined by the integer
    matrix B. This is used internally by the function for conversion
    of matrices to PARI.

    For internal use only; this directly uses the PARI stack.
    One should call ``sig_on()`` before and ``sig_off()`` after.
    """
    cdef GEN A = _new_GEN_from_fmpz_mat_t(B._matrix)
    return A


cdef extract_hnf_from_pari_matrix(Matrix_integer_dense self, Gen H, bint include_zero_rows):
    cdef mpz_t tmp
    mpz_init(tmp)

    # Figure out how many columns we got back.
    cdef long H_nc = glength(H.g)  # number of columns
    # Now get the resulting Hermite form matrix back to Sage, suitably re-arranged.
    cdef Matrix_integer_dense B
    if include_zero_rows:
        B = self.new_matrix()
    else:
        B = self.new_matrix(nrows=H_nc)
    cdef long i, j
    for i in range(self._ncols):
        for j in range(H_nc):
            sig_check()
            INT_to_mpz(tmp, gcoeff(H.g, i+1, H_nc-j))
            fmpz_set_mpz(fmpz_mat_entry(B._matrix,j,self._ncols-i-1),tmp)
    mpz_clear(tmp)
    return B
