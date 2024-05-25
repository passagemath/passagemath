# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/fmpq_poly.h

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
    void fmpq_poly_init(fmpq_poly_t poly) noexcept
    void fmpq_poly_init2(fmpq_poly_t poly, slong alloc) noexcept
    void fmpq_poly_realloc(fmpq_poly_t poly, slong alloc) noexcept
    void fmpq_poly_fit_length(fmpq_poly_t poly, slong len) noexcept
    void _fmpq_poly_set_length(fmpq_poly_t poly, slong len) noexcept
    void fmpq_poly_clear(fmpq_poly_t poly) noexcept
    void _fmpq_poly_normalise(fmpq_poly_t poly) noexcept
    void _fmpq_poly_canonicalise(fmpz * poly, fmpz_t den, slong len) noexcept
    void fmpq_poly_canonicalise(fmpq_poly_t poly) noexcept
    bint _fmpq_poly_is_canonical(const fmpz * poly, const fmpz_t den, slong len) noexcept
    bint fmpq_poly_is_canonical(const fmpq_poly_t poly) noexcept
    slong fmpq_poly_degree(const fmpq_poly_t poly) noexcept
    slong fmpq_poly_length(const fmpq_poly_t poly) noexcept
    fmpz * fmpq_poly_numref(fmpq_poly_t poly) noexcept
    fmpz_t fmpq_poly_denref(fmpq_poly_t poly) noexcept
    void fmpq_poly_get_numerator(fmpz_poly_t res, const fmpq_poly_t poly) noexcept
    void fmpq_poly_get_denominator(fmpz_t den, const fmpq_poly_t poly) noexcept
    void fmpq_poly_randtest(fmpq_poly_t f, flint_rand_t state, slong len, flint_bitcnt_t bits) noexcept
    void fmpq_poly_randtest_unsigned(fmpq_poly_t f, flint_rand_t state, slong len, flint_bitcnt_t bits) noexcept
    void fmpq_poly_randtest_not_zero(fmpq_poly_t f, flint_rand_t state, slong len, flint_bitcnt_t bits) noexcept
    void fmpq_poly_set(fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void fmpq_poly_set_si(fmpq_poly_t poly, slong x) noexcept
    void fmpq_poly_set_ui(fmpq_poly_t poly, ulong x) noexcept
    void fmpq_poly_set_fmpz(fmpq_poly_t poly, const fmpz_t x) noexcept
    void fmpq_poly_set_fmpq(fmpq_poly_t poly, const fmpq_t x) noexcept
    void fmpq_poly_set_fmpz_poly(fmpq_poly_t rop, const fmpz_poly_t op) noexcept
    void fmpq_poly_set_nmod_poly(fmpq_poly_t rop, const nmod_poly_t op) noexcept
    void fmpq_poly_get_nmod_poly(nmod_poly_t rop, const fmpq_poly_t op) noexcept
    void fmpq_poly_get_nmod_poly_den(nmod_poly_t rop, const fmpq_poly_t op, int den) noexcept
    int _fmpq_poly_set_str(fmpz * poly, fmpz_t den, const char * str, slong len) noexcept
    int fmpq_poly_set_str(fmpq_poly_t poly, const char * str) noexcept
    char * fmpq_poly_get_str(const fmpq_poly_t poly) noexcept
    char * fmpq_poly_get_str_pretty(const fmpq_poly_t poly, const char * var) noexcept
    void fmpq_poly_zero(fmpq_poly_t poly) noexcept
    void fmpq_poly_one(fmpq_poly_t poly) noexcept
    void fmpq_poly_neg(fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void fmpq_poly_inv(fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void fmpq_poly_swap(fmpq_poly_t poly1, fmpq_poly_t poly2) noexcept
    void fmpq_poly_truncate(fmpq_poly_t poly, slong n) noexcept
    void fmpq_poly_set_trunc(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void fmpq_poly_get_slice(fmpq_poly_t rop, const fmpq_poly_t op, slong i, slong j) noexcept
    void fmpq_poly_reverse(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void fmpq_poly_get_coeff_fmpz(fmpz_t x, const fmpq_poly_t poly, slong n) noexcept
    void fmpq_poly_get_coeff_fmpq(fmpq_t x, const fmpq_poly_t poly, slong n) noexcept
    void fmpq_poly_set_coeff_si(fmpq_poly_t poly, slong n, slong x) noexcept
    void fmpq_poly_set_coeff_ui(fmpq_poly_t poly, slong n, ulong x) noexcept
    void fmpq_poly_set_coeff_fmpz(fmpq_poly_t poly, slong n, const fmpz_t x) noexcept
    void fmpq_poly_set_coeff_fmpq(fmpq_poly_t poly, slong n, const fmpq_t x) noexcept
    bint fmpq_poly_equal(const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    bint _fmpq_poly_equal_trunc(const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    bint fmpq_poly_equal_trunc(const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    int _fmpq_poly_cmp(const fmpz * lpoly, const fmpz_t lden, const fmpz * rpoly, const fmpz_t rden, slong len) noexcept
    int fmpq_poly_cmp(const fmpq_poly_t left, const fmpq_poly_t right) noexcept
    bint fmpq_poly_is_one(const fmpq_poly_t poly) noexcept
    bint fmpq_poly_is_zero(const fmpq_poly_t poly) noexcept
    bint fmpq_poly_is_gen(const fmpq_poly_t poly) noexcept
    void _fmpq_poly_add(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2) noexcept
    void _fmpq_poly_add_can(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, int can) noexcept
    void fmpq_poly_add(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void fmpq_poly_add_can(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, int can) noexcept
    void _fmpq_poly_add_series(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    void _fmpq_poly_add_series_can(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n, int can) noexcept
    void fmpq_poly_add_series(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    void fmpq_poly_add_series_can(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n, int can) noexcept
    void _fmpq_poly_sub(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2) noexcept
    void _fmpq_poly_sub_can(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, int can) noexcept
    void fmpq_poly_sub(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void fmpq_poly_sub_can(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, int can) noexcept
    void _fmpq_poly_sub_series(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    void _fmpq_poly_sub_series_can(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n, int can) noexcept
    void fmpq_poly_sub_series(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    void fmpq_poly_sub_series_can(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n, int can) noexcept
    void _fmpq_poly_scalar_mul_si(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, slong c) noexcept
    void _fmpq_poly_scalar_mul_ui(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, ulong c) noexcept
    void _fmpq_poly_scalar_mul_fmpz(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t c) noexcept
    void _fmpq_poly_scalar_mul_fmpq(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t r, const fmpz_t s) noexcept
    void fmpq_poly_scalar_mul_fmpq(fmpq_poly_t rop, const fmpq_poly_t op, const fmpq_t c) noexcept
    void fmpq_poly_scalar_mul_si(fmpq_poly_t rop, const fmpq_poly_t op, slong c) noexcept
    void fmpq_poly_scalar_mul_ui(fmpq_poly_t rop, const fmpq_poly_t op, ulong c) noexcept
    void fmpq_poly_scalar_mul_fmpz(fmpq_poly_t rop, const fmpq_poly_t op, const fmpz_t c) noexcept
    void _fmpq_poly_scalar_div_fmpz(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t c) noexcept
    void _fmpq_poly_scalar_div_si(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, slong c) noexcept
    void _fmpq_poly_scalar_div_ui(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, ulong c) noexcept
    void _fmpq_poly_scalar_div_fmpq(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t r, const fmpz_t s) noexcept
    void fmpq_poly_scalar_div_si(fmpq_poly_t rop, const fmpq_poly_t op, slong c) noexcept
    void fmpq_poly_scalar_div_ui(fmpq_poly_t rop, const fmpq_poly_t op, ulong c) noexcept
    void fmpq_poly_scalar_div_fmpz(fmpq_poly_t rop, const fmpq_poly_t op, const fmpz_t c) noexcept
    void fmpq_poly_scalar_div_fmpq(fmpq_poly_t rop, const fmpq_poly_t op, const fmpq_t c) noexcept
    void _fmpq_poly_mul(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2) noexcept
    void fmpq_poly_mul(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void _fmpq_poly_mullow(fmpz * rpoly, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    void fmpq_poly_mullow(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    void fmpq_poly_addmul(fmpq_poly_t rop, const fmpq_poly_t op1, const fmpq_poly_t op2) noexcept
    void fmpq_poly_submul(fmpq_poly_t rop, const fmpq_poly_t op1, const fmpq_poly_t op2) noexcept
    void _fmpq_poly_pow(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, ulong e) noexcept
    void fmpq_poly_pow(fmpq_poly_t res, const fmpq_poly_t poly, ulong e) noexcept
    void _fmpq_poly_pow_trunc(fmpz * res, fmpz_t rden, const fmpz * f, const fmpz_t fden, slong flen, ulong exp, slong len) noexcept
    void fmpq_poly_pow_trunc(fmpq_poly_t res, const fmpq_poly_t poly, ulong e, slong n) noexcept
    void fmpq_poly_shift_left(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void fmpq_poly_shift_right(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_divrem(fmpz * Q, fmpz_t q, fmpz * R, fmpz_t r, const fmpz * A, const fmpz_t a, slong lenA, const fmpz * B, const fmpz_t b, slong lenB, const fmpz_preinvn_t inv) noexcept
    void fmpq_poly_divrem(fmpq_poly_t Q, fmpq_poly_t R, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void _fmpq_poly_div(fmpz * Q, fmpz_t q, const fmpz * A, const fmpz_t a, slong lenA, const fmpz * B, const fmpz_t b, slong lenB, const fmpz_preinvn_t inv) noexcept
    void fmpq_poly_div(fmpq_poly_t Q, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void _fmpq_poly_rem(fmpz * R, fmpz_t r, const fmpz * A, const fmpz_t a, slong lenA, const fmpz * B, const fmpz_t b, slong lenB, const fmpz_preinvn_t inv) noexcept
    void fmpq_poly_rem(fmpq_poly_t R, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    fmpq_poly_struct * _fmpq_poly_powers_precompute(const fmpz * B, const fmpz_t denB, slong len) noexcept
    void fmpq_poly_powers_precompute(fmpq_poly_powers_precomp_t pinv, fmpq_poly_t poly) noexcept
    void _fmpq_poly_powers_clear(fmpq_poly_struct * powers, slong len) noexcept
    void fmpq_poly_powers_clear(fmpq_poly_powers_precomp_t pinv) noexcept
    void _fmpq_poly_rem_powers_precomp(fmpz * A, fmpz_t denA, slong m, const fmpz * B, const fmpz_t denB, slong n, fmpq_poly_struct * const powers) noexcept
    void fmpq_poly_rem_powers_precomp(fmpq_poly_t R, const fmpq_poly_t A, const fmpq_poly_t B, const fmpq_poly_powers_precomp_t B_inv) noexcept
    int _fmpq_poly_divides(fmpz * qpoly, fmpz_t qden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2) noexcept
    int fmpq_poly_divides(fmpq_poly_t q, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    slong fmpq_poly_remove(fmpq_poly_t q, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void _fmpq_poly_inv_series_newton(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, slong n) noexcept
    void fmpq_poly_inv_series_newton(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_inv_series(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong den_len, slong n) noexcept
    void fmpq_poly_inv_series(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_div_series(fmpz * Q, fmpz_t denQ, const fmpz * A, const fmpz_t denA, slong lenA, const fmpz * B, const fmpz_t denB, slong lenB, slong n) noexcept
    void fmpq_poly_div_series(fmpq_poly_t Q, const fmpq_poly_t A, const fmpq_poly_t B, slong n) noexcept
    void _fmpq_poly_gcd(fmpz * G, fmpz_t denG, const fmpz * A, slong lenA, const fmpz * B, slong lenB) noexcept
    void fmpq_poly_gcd(fmpq_poly_t G, const fmpq_poly_t A, const fmpq_poly_t B) noexcept
    void _fmpq_poly_xgcd(fmpz * G, fmpz_t denG, fmpz * S, fmpz_t denS, fmpz * T, fmpz_t denT, const fmpz * A, const fmpz_t denA, slong lenA, const fmpz * B, const fmpz_t denB, slong lenB) noexcept
    void fmpq_poly_xgcd(fmpq_poly_t G, fmpq_poly_t S, fmpq_poly_t T, const fmpq_poly_t A, const fmpq_poly_t B) noexcept
    void _fmpq_poly_lcm(fmpz * L, fmpz_t denL, const fmpz * A, slong lenA, const fmpz * B, slong lenB) noexcept
    void fmpq_poly_lcm(fmpq_poly_t L, const fmpq_poly_t A, const fmpq_poly_t B) noexcept
    void _fmpq_poly_resultant(fmpz_t rnum, fmpz_t rden, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2) noexcept
    void fmpq_poly_resultant(fmpq_t r, const fmpq_poly_t f, const fmpq_poly_t g) noexcept
    void fmpq_poly_resultant_div(fmpq_t r, const fmpq_poly_t f, const fmpq_poly_t g, const fmpz_t div, slong nbits) noexcept
    void _fmpq_poly_derivative(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len) noexcept
    void fmpq_poly_derivative(fmpq_poly_t res, const fmpq_poly_t poly) noexcept
    void _fmpq_poly_nth_derivative(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, ulong n, slong len) noexcept
    void fmpq_poly_nth_derivative(fmpq_poly_t res, const fmpq_poly_t poly, ulong n) noexcept
    void _fmpq_poly_integral(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len) noexcept
    void fmpq_poly_integral(fmpq_poly_t res, const fmpq_poly_t poly) noexcept
    void _fmpq_poly_sqrt_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_sqrt_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_invsqrt_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_invsqrt_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_power_sums(fmpz * res, fmpz_t rden, const fmpz * poly, slong len, slong n) noexcept
    void fmpq_poly_power_sums(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_power_sums_to_poly(fmpz * res, const fmpz * poly, const fmpz_t den, slong len) noexcept
    void fmpq_poly_power_sums_to_fmpz_poly(fmpz_poly_t res, const fmpq_poly_t Q) noexcept
    void fmpq_poly_power_sums_to_poly(fmpq_poly_t res, const fmpq_poly_t Q) noexcept
    void _fmpq_poly_log_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_log_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_exp_series(fmpz * g, fmpz_t gden, const fmpz * h, const fmpz_t hden, slong hlen, slong n) noexcept
    void fmpq_poly_exp_series(fmpq_poly_t res, const fmpq_poly_t h, slong n) noexcept
    void _fmpq_poly_exp_expinv_series(fmpz * res1, fmpz_t res1den, fmpz * res2, fmpz_t res2den, const fmpz * h, const fmpz_t hden, slong hlen, slong n) noexcept
    void fmpq_poly_exp_expinv_series(fmpq_poly_t res1, fmpq_poly_t res2, const fmpq_poly_t h, slong n) noexcept
    void _fmpq_poly_atan_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_atan_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_atanh_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_atanh_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_asin_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_asin_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_asinh_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_asinh_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_tan_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_tan_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_sin_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_sin_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_cos_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_cos_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_sin_cos_series(fmpz * s, fmpz_t sden, fmpz * c, fmpz_t cden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_sin_cos_series(fmpq_poly_t res1, fmpq_poly_t res2, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_sinh_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_sinh_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_cosh_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_cosh_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_sinh_cosh_series(fmpz * s, fmpz_t sden, fmpz * c, fmpz_t cden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_sinh_cosh_series(fmpq_poly_t res1, fmpq_poly_t res2, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_tanh_series(fmpz * g, fmpz_t gden, const fmpz * f, const fmpz_t fden, slong flen, slong n) noexcept
    void fmpq_poly_tanh_series(fmpq_poly_t res, const fmpq_poly_t f, slong n) noexcept
    void _fmpq_poly_legendre_p(fmpz * coeffs, fmpz_t den, ulong n) noexcept
    void fmpq_poly_legendre_p(fmpq_poly_t poly, ulong n) noexcept
    void _fmpq_poly_laguerre_l(fmpz * coeffs, fmpz_t den, ulong n) noexcept
    void fmpq_poly_laguerre_l(fmpq_poly_t poly, ulong n) noexcept
    void _fmpq_poly_gegenbauer_c(fmpz * coeffs, fmpz_t den, ulong n, const fmpq_t a) noexcept
    void fmpq_poly_gegenbauer_c(fmpq_poly_t poly, ulong n, const fmpq_t a) noexcept
    void _fmpq_poly_evaluate_fmpz(fmpz_t rnum, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t a) noexcept
    void fmpq_poly_evaluate_fmpz(fmpq_t res, const fmpq_poly_t poly, const fmpz_t a) noexcept
    void _fmpq_poly_evaluate_fmpq(fmpz_t rnum, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t anum, const fmpz_t aden) noexcept
    void fmpq_poly_evaluate_fmpq(fmpq_t res, const fmpq_poly_t poly, const fmpq_t a) noexcept
    void _fmpq_poly_interpolate_fmpz_vec(fmpz * poly, fmpz_t den, const fmpz * xs, const fmpz * ys, slong n) noexcept
    void fmpq_poly_interpolate_fmpz_vec(fmpq_poly_t poly, const fmpz * xs, const fmpz * ys, slong n) noexcept
    void _fmpq_poly_compose(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2) noexcept
    void fmpq_poly_compose(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2) noexcept
    void _fmpq_poly_rescale(fmpz * res, fmpz_t denr, const fmpz * poly, const fmpz_t den, slong len, const fmpz_t anum, const fmpz_t aden) noexcept
    void fmpq_poly_rescale(fmpq_poly_t res, const fmpq_poly_t poly, const fmpq_t a) noexcept
    void _fmpq_poly_compose_series_horner(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    void fmpq_poly_compose_series_horner(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    void _fmpq_poly_compose_series_brent_kung(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    void fmpq_poly_compose_series_brent_kung(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    void _fmpq_poly_compose_series(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, const fmpz * poly2, const fmpz_t den2, slong len2, slong n) noexcept
    void fmpq_poly_compose_series(fmpq_poly_t res, const fmpq_poly_t poly1, const fmpq_poly_t poly2, slong n) noexcept
    void _fmpq_poly_revert_series_lagrange(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, slong n) noexcept
    void fmpq_poly_revert_series_lagrange(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_revert_series_lagrange_fast(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, slong n) noexcept
    void fmpq_poly_revert_series_lagrange_fast(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_revert_series_newton(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, slong n) noexcept
    void fmpq_poly_revert_series_newton(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_revert_series(fmpz * res, fmpz_t den, const fmpz * poly1, const fmpz_t den1, slong len1, slong n) noexcept
    void fmpq_poly_revert_series(fmpq_poly_t res, const fmpq_poly_t poly, slong n) noexcept
    void _fmpq_poly_content(fmpq_t res, const fmpz * poly, const fmpz_t den, slong len) noexcept
    void fmpq_poly_content(fmpq_t res, const fmpq_poly_t poly) noexcept
    void _fmpq_poly_primitive_part(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len) noexcept
    void fmpq_poly_primitive_part(fmpq_poly_t res, const fmpq_poly_t poly) noexcept
    bint _fmpq_poly_is_monic(const fmpz * poly, const fmpz_t den, slong len) noexcept
    bint fmpq_poly_is_monic(const fmpq_poly_t poly) noexcept
    void _fmpq_poly_make_monic(fmpz * rpoly, fmpz_t rden, const fmpz * poly, const fmpz_t den, slong len) noexcept
    void fmpq_poly_make_monic(fmpq_poly_t res, const fmpq_poly_t poly) noexcept
    bint fmpq_poly_is_squarefree(const fmpq_poly_t poly) noexcept
    int _fmpq_poly_print(const fmpz * poly, const fmpz_t den, slong len) noexcept
    int fmpq_poly_print(const fmpq_poly_t poly) noexcept
    int _fmpq_poly_print_pretty(const fmpz * poly, const fmpz_t den, slong len, const char * x) noexcept
    int fmpq_poly_print_pretty(const fmpq_poly_t poly, const char * var) noexcept
    int _fmpq_poly_fprint(FILE * file, const fmpz * poly, const fmpz_t den, slong len) noexcept
    int fmpq_poly_fprint(FILE * file, const fmpq_poly_t poly) noexcept
    int _fmpq_poly_fprint_pretty(FILE * file, const fmpz * poly, const fmpz_t den, slong len, const char * x) noexcept
    int fmpq_poly_fprint_pretty(FILE * file, const fmpq_poly_t poly, const char * var) noexcept
    int fmpq_poly_read(fmpq_poly_t poly) noexcept
    int fmpq_poly_fread(FILE * file, fmpq_poly_t poly) noexcept
