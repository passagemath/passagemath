# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/nf_elem.h

################################################################################
# This file is auto-generated by the script
#   SAGE_ROOT/src/sage_setup/autogen/flint_autogen.py.
# From the commit 3e2c3a3e091106a25ca9c6fba28e02f2cbcd654a
# Do not modify by hand! Fix and rerun the script instead.
################################################################################

from libc.stdio cimport FILE
from sage.libs.gmp.types cimport *
from sage.libs.mpfr.types cimport *
from sage.libs.flint.types cimport *

cdef extern from "flint_wrap.h":
    void nf_elem_init(nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_clear(nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_randtest(nf_elem_t a, flint_rand_t state, mp_bitcnt_t bits, const nf_t nf) noexcept
    void nf_elem_canonicalise(nf_elem_t a, const nf_t nf) noexcept
    void _nf_elem_reduce(nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_reduce(nf_elem_t a, const nf_t nf) noexcept
    int _nf_elem_invertible_check(nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_set_fmpz_mat_row(nf_elem_t b, const fmpz_mat_t M, const slong i, fmpz_t den, const nf_t nf) noexcept
    void nf_elem_get_fmpz_mat_row(fmpz_mat_t M, const slong i, fmpz_t den, const nf_elem_t b, const nf_t nf) noexcept
    void nf_elem_set_fmpq_poly(nf_elem_t a, const fmpq_poly_t pol, const nf_t nf) noexcept
    void nf_elem_get_fmpq_poly(fmpq_poly_t pol, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_get_nmod_poly_den(nmod_poly_t pol, const nf_elem_t a, const nf_t nf, int den) noexcept
    void nf_elem_get_nmod_poly(nmod_poly_t pol, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_get_fmpz_mod_poly_den(fmpz_mod_poly_t pol, const nf_elem_t a, const nf_t nf, int den, const fmpz_mod_ctx_t ctx) noexcept
    void nf_elem_get_fmpz_mod_poly(fmpz_mod_poly_t pol, const nf_elem_t a, const nf_t nf, const fmpz_mod_ctx_t ctx) noexcept
    void nf_elem_set_den(nf_elem_t b, fmpz_t d, const nf_t nf) noexcept
    void nf_elem_get_den(fmpz_t d, const nf_elem_t b, const nf_t nf) noexcept
    void _nf_elem_set_coeff_num_fmpz(nf_elem_t a, slong i, const fmpz_t d, const nf_t nf) noexcept
    bint _nf_elem_equal(const nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    bint nf_elem_equal(const nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    bint nf_elem_is_zero(const nf_elem_t a, const nf_t nf) noexcept
    bint nf_elem_is_one(const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_print_pretty(const nf_elem_t a, const nf_t nf, const char * var) noexcept
    void nf_elem_zero(nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_one(nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_set(nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void nf_elem_neg(nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void nf_elem_swap(nf_elem_t a, nf_elem_t b, const nf_t nf) noexcept
    void nf_elem_mul_gen(nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void _nf_elem_add(nf_elem_t r, const nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void nf_elem_add(nf_elem_t r, const nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void _nf_elem_sub(nf_elem_t r, const nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void nf_elem_sub(nf_elem_t r, const nf_elem_t a, const nf_elem_t b, const nf_t nf) noexcept
    void _nf_elem_mul(nf_elem_t a, const nf_elem_t b, const nf_elem_t c, const nf_t nf) noexcept
    void _nf_elem_mul_red(nf_elem_t a, const nf_elem_t b, const nf_elem_t c, const nf_t nf, int red) noexcept
    void nf_elem_mul(nf_elem_t a, const nf_elem_t b, const nf_elem_t c, const nf_t nf) noexcept
    void nf_elem_mul_red(nf_elem_t a, const nf_elem_t b, const nf_elem_t c, const nf_t nf, int red) noexcept
    void _nf_elem_inv(nf_elem_t r, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_inv(nf_elem_t r, const nf_elem_t a, const nf_t nf) noexcept
    void _nf_elem_div(nf_elem_t a, const nf_elem_t b, const nf_elem_t c, const nf_t nf) noexcept
    void nf_elem_div(nf_elem_t a, const nf_elem_t b, const nf_elem_t c, const nf_t nf) noexcept
    void _nf_elem_pow(nf_elem_t res, const nf_elem_t a, ulong e, const nf_t nf) noexcept
    void nf_elem_pow(nf_elem_t res, const nf_elem_t a, ulong e, const nf_t nf) noexcept
    void _nf_elem_norm(fmpz_t rnum, fmpz_t rden, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_norm(fmpq_t res, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_norm_div(fmpq_t res, const nf_elem_t a, const nf_t nf, const fmpz_t div, slong nbits) noexcept
    void _nf_elem_norm_div(fmpz_t rnum, fmpz_t rden, const nf_elem_t a, const nf_t nf, const fmpz_t divisor, slong nbits) noexcept
    void _nf_elem_trace(fmpz_t rnum, fmpz_t rden, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_trace(fmpq_t res, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_rep_mat(fmpq_mat_t res, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_rep_mat_fmpz_mat_den(fmpz_mat_t res, fmpz_t den, const nf_elem_t a, const nf_t nf) noexcept
    void nf_elem_mod_fmpz_den(nf_elem_t z, const nf_elem_t a, const fmpz_t mod, const nf_t nf, int den) noexcept
    void nf_elem_smod_fmpz_den(nf_elem_t z, const nf_elem_t a, const fmpz_t mod, const nf_t nf, int den) noexcept
    void nf_elem_mod_fmpz(nf_elem_t res, const nf_elem_t a, const fmpz_t mod, const nf_t nf) noexcept
    void nf_elem_smod_fmpz(nf_elem_t res, const nf_elem_t a, const fmpz_t mod, const nf_t nf) noexcept
    void nf_elem_coprime_den(nf_elem_t res, const nf_elem_t a, const fmpz_t mod, const nf_t nf) noexcept
    void nf_elem_coprime_den_signed(nf_elem_t res, const nf_elem_t a, const fmpz_t mod, const nf_t nf) noexcept
