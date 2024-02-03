# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/nmod_poly.h

################################################################################
# This file is auto-generated by the script
#   SAGE_ROOT/src/sage_setup/autogen/flint_autogen.py.
# Do not modify by hand! Fix and rerun the script instead.
################################################################################

from libc.stdio cimport FILE
from sage.libs.gmp.types cimport *
from sage.libs.mpfr.types cimport *
from sage.libs.flint.types cimport *

cdef extern from "flint_wrap.h":
    int signed_mpn_sub_n(mp_ptr res, mp_srcptr op1, mp_srcptr op2, slong n) noexcept
    void nmod_poly_init(nmod_poly_t poly, mp_limb_t n) noexcept
    void nmod_poly_init_preinv(nmod_poly_t poly, mp_limb_t n, mp_limb_t ninv) noexcept
    void nmod_poly_init_mod(nmod_poly_t poly, const nmod_t mod) noexcept
    void nmod_poly_init2(nmod_poly_t poly, mp_limb_t n, slong alloc) noexcept
    void nmod_poly_init2_preinv(nmod_poly_t poly, mp_limb_t n, mp_limb_t ninv, slong alloc) noexcept
    void nmod_poly_realloc(nmod_poly_t poly, slong alloc) noexcept
    void nmod_poly_clear(nmod_poly_t poly) noexcept
    void nmod_poly_fit_length(nmod_poly_t poly, slong alloc) noexcept
    void _nmod_poly_normalise(nmod_poly_t poly) noexcept
    slong nmod_poly_length(const nmod_poly_t poly) noexcept
    slong nmod_poly_degree(const nmod_poly_t poly) noexcept
    mp_limb_t nmod_poly_modulus(const nmod_poly_t poly) noexcept
    flint_bitcnt_t nmod_poly_max_bits(const nmod_poly_t poly) noexcept
    bint nmod_poly_is_unit(const nmod_poly_t poly) noexcept
    bint nmod_poly_is_monic(const nmod_poly_t poly) noexcept
    void nmod_poly_set(nmod_poly_t a, const nmod_poly_t b) noexcept
    void nmod_poly_swap(nmod_poly_t poly1, nmod_poly_t poly2) noexcept
    void nmod_poly_zero(nmod_poly_t res) noexcept
    void nmod_poly_truncate(nmod_poly_t poly, slong len) noexcept
    void nmod_poly_set_trunc(nmod_poly_t res, const nmod_poly_t poly, slong len) noexcept
    void _nmod_poly_reverse(mp_ptr output, mp_srcptr input, slong len, slong m) noexcept
    void nmod_poly_reverse(nmod_poly_t output, const nmod_poly_t input, slong m) noexcept
    void nmod_poly_randtest(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    void nmod_poly_randtest_irreducible(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    void nmod_poly_randtest_monic(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    void nmod_poly_randtest_monic_irreducible(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    void nmod_poly_randtest_monic_primitive(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    void nmod_poly_randtest_trinomial(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    int nmod_poly_randtest_trinomial_irreducible(nmod_poly_t poly, flint_rand_t state, slong len, slong max_attempts) noexcept
    void nmod_poly_randtest_pentomial(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    int nmod_poly_randtest_pentomial_irreducible(nmod_poly_t poly, flint_rand_t state, slong len, slong max_attempts) noexcept
    void nmod_poly_randtest_sparse_irreducible(nmod_poly_t poly, flint_rand_t state, slong len) noexcept
    ulong nmod_poly_get_coeff_ui(const nmod_poly_t poly, slong j) noexcept
    void nmod_poly_set_coeff_ui(nmod_poly_t poly, slong j, ulong c) noexcept
    char * nmod_poly_get_str(const nmod_poly_t poly) noexcept
    char * nmod_poly_get_str_pretty(const nmod_poly_t poly, const char * x) noexcept
    int nmod_poly_set_str(nmod_poly_t poly, const char * s) noexcept
    int nmod_poly_print(const nmod_poly_t a) noexcept
    int nmod_poly_print_pretty(const nmod_poly_t a, const char * x) noexcept
    int nmod_poly_fread(FILE * f, nmod_poly_t poly) noexcept
    int nmod_poly_fprint(FILE * f, const nmod_poly_t poly) noexcept
    int nmod_poly_fprint_pretty(FILE * f, const nmod_poly_t poly, const char * x) noexcept
    int nmod_poly_read(nmod_poly_t poly) noexcept
    bint nmod_poly_equal(const nmod_poly_t a, const nmod_poly_t b) noexcept
    bint nmod_poly_equal_nmod(const nmod_poly_t poly, ulong cst) noexcept
    bint nmod_poly_equal_ui(const nmod_poly_t poly, ulong cst) noexcept
    bint nmod_poly_equal_trunc(const nmod_poly_t poly1, const nmod_poly_t poly2, slong n) noexcept
    bint nmod_poly_is_zero(const nmod_poly_t poly) noexcept
    bint nmod_poly_is_one(const nmod_poly_t poly) noexcept
    bint nmod_poly_is_gen(const nmod_poly_t poly) noexcept
    void _nmod_poly_shift_left(mp_ptr res, mp_srcptr poly, slong len, slong k) noexcept
    void nmod_poly_shift_left(nmod_poly_t res, const nmod_poly_t poly, slong k) noexcept
    void _nmod_poly_shift_right(mp_ptr res, mp_srcptr poly, slong len, slong k) noexcept
    void nmod_poly_shift_right(nmod_poly_t res, const nmod_poly_t poly, slong k) noexcept
    void _nmod_poly_add(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_add(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void nmod_poly_add_series(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong n) noexcept
    void _nmod_poly_sub(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_sub(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void nmod_poly_sub_series(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong n) noexcept
    void nmod_poly_neg(nmod_poly_t res, const nmod_poly_t poly) noexcept
    void nmod_poly_scalar_mul_nmod(nmod_poly_t res, const nmod_poly_t poly, ulong c) noexcept
    void nmod_poly_scalar_addmul_nmod(nmod_poly_t res, const nmod_poly_t poly, ulong c) noexcept
    void _nmod_poly_make_monic(mp_ptr output, mp_srcptr input, slong len, nmod_t mod) noexcept
    void nmod_poly_make_monic(nmod_poly_t output, const nmod_poly_t input) noexcept
    void _nmod_poly_bit_pack(mp_ptr res, mp_srcptr poly, slong len, flint_bitcnt_t bits) noexcept
    void _nmod_poly_bit_unpack(mp_ptr res, slong len, mp_srcptr mpn, ulong bits, nmod_t mod) noexcept
    void nmod_poly_bit_pack(fmpz_t f, const nmod_poly_t poly, flint_bitcnt_t bit_size) noexcept
    void nmod_poly_bit_unpack(nmod_poly_t poly, const fmpz_t f, flint_bitcnt_t bit_size) noexcept
    void _nmod_poly_KS2_pack1(mp_ptr res, mp_srcptr op, slong n, slong s, ulong b, ulong k, slong r) noexcept
    void _nmod_poly_KS2_pack(mp_ptr res, mp_srcptr op, slong n, slong s, ulong b, ulong k, slong r) noexcept
    void _nmod_poly_KS2_unpack1(mp_ptr res, mp_srcptr op, slong n, ulong b, ulong k) noexcept
    void _nmod_poly_KS2_unpack2(mp_ptr res, mp_srcptr op, slong n, ulong b, ulong k) noexcept
    void _nmod_poly_KS2_unpack3(mp_ptr res, mp_srcptr op, slong n, ulong b, ulong k) noexcept
    void _nmod_poly_KS2_unpack(mp_ptr res, mp_srcptr op, slong n, ulong b, ulong k) noexcept
    void _nmod_poly_KS2_reduce(mp_ptr res, slong s, mp_srcptr op, slong n, ulong w, nmod_t mod) noexcept
    void _nmod_poly_KS2_recover_reduce1(mp_ptr res, slong s, mp_srcptr op1, mp_srcptr op2, slong n, ulong b, nmod_t mod) noexcept
    void _nmod_poly_KS2_recover_reduce2(mp_ptr res, slong s, mp_srcptr op1, mp_srcptr op2, slong n, ulong b, nmod_t mod) noexcept
    void _nmod_poly_KS2_recover_reduce2b(mp_ptr res, slong s, mp_srcptr op1, mp_srcptr op2, slong n, ulong b, nmod_t mod) noexcept
    void _nmod_poly_KS2_recover_reduce3(mp_ptr res, slong s, mp_srcptr op1, mp_srcptr op2, slong n, ulong b, nmod_t mod) noexcept
    void _nmod_poly_KS2_recover_reduce(mp_ptr res, slong s, mp_srcptr op1, mp_srcptr op2, slong n, ulong b, nmod_t mod) noexcept
    void _nmod_poly_mul_classical(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_mul_classical(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void _nmod_poly_mullow_classical(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, slong trunc, nmod_t mod) noexcept
    void nmod_poly_mullow_classical(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong trunc) noexcept
    void _nmod_poly_mulhigh_classical(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, slong start, nmod_t mod) noexcept
    void nmod_poly_mulhigh_classical(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong start) noexcept
    void _nmod_poly_mul_KS(mp_ptr out, mp_srcptr in1, slong len1, mp_srcptr in2, slong len2, flint_bitcnt_t bits, nmod_t mod) noexcept
    void nmod_poly_mul_KS(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, flint_bitcnt_t bits) noexcept
    void _nmod_poly_mul_KS2(mp_ptr res, mp_srcptr op1, slong n1, mp_srcptr op2, slong n2, nmod_t mod) noexcept
    void nmod_poly_mul_KS2(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void _nmod_poly_mul_KS4(mp_ptr res, mp_srcptr op1, slong n1, mp_srcptr op2, slong n2, nmod_t mod) noexcept
    void nmod_poly_mul_KS4(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void _nmod_poly_mullow_KS(mp_ptr out, mp_srcptr in1, slong len1, mp_srcptr in2, slong len2, flint_bitcnt_t bits, slong n, nmod_t mod) noexcept
    void nmod_poly_mullow_KS(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, flint_bitcnt_t bits, slong n) noexcept
    void _nmod_poly_mul(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_mul(nmod_poly_t res, const nmod_poly_t poly, const nmod_poly_t poly2) noexcept
    void _nmod_poly_mullow(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, slong n, nmod_t mod) noexcept
    void nmod_poly_mullow(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong trunc) noexcept
    void _nmod_poly_mulhigh(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, slong n, nmod_t mod) noexcept
    void nmod_poly_mulhigh(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong n) noexcept
    void _nmod_poly_mulmod(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, mp_srcptr f, slong lenf, nmod_t mod) noexcept
    void nmod_poly_mulmod(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, const nmod_poly_t f) noexcept
    void _nmod_poly_mulmod_preinv(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, mp_srcptr f, slong lenf, mp_srcptr finv, slong lenfinv, nmod_t mod) noexcept
    void nmod_poly_mulmod_preinv(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, const nmod_poly_t f, const nmod_poly_t finv) noexcept
    void _nmod_poly_pow_binexp(mp_ptr res, mp_srcptr poly, slong len, ulong e, nmod_t mod) noexcept
    void nmod_poly_pow_binexp(nmod_poly_t res, const nmod_poly_t poly, ulong e) noexcept
    void _nmod_poly_pow(mp_ptr res, mp_srcptr poly, slong len, ulong e, nmod_t mod) noexcept
    void nmod_poly_pow(nmod_poly_t res, const nmod_poly_t poly, ulong e) noexcept
    void _nmod_poly_pow_trunc_binexp(mp_ptr res, mp_srcptr poly, ulong e, slong trunc, nmod_t mod) noexcept
    void nmod_poly_pow_trunc_binexp(nmod_poly_t res, const nmod_poly_t poly, ulong e, slong trunc) noexcept
    void _nmod_poly_pow_trunc(mp_ptr res, mp_srcptr poly, ulong e, slong trunc, nmod_t mod) noexcept
    void nmod_poly_pow_trunc(nmod_poly_t res, const nmod_poly_t poly, ulong e, slong trunc) noexcept
    void _nmod_poly_powmod_ui_binexp(mp_ptr res, mp_srcptr poly, ulong e, mp_srcptr f, slong lenf, nmod_t mod) noexcept
    void nmod_poly_powmod_ui_binexp(nmod_poly_t res, const nmod_poly_t poly, ulong e, const nmod_poly_t f) noexcept
    void _nmod_poly_powmod_fmpz_binexp(mp_ptr res, mp_srcptr poly, fmpz_t e, mp_srcptr f, slong lenf, nmod_t mod) noexcept
    void nmod_poly_powmod_fmpz_binexp(nmod_poly_t res, const nmod_poly_t poly, fmpz_t e, const nmod_poly_t f) noexcept
    void _nmod_poly_powmod_ui_binexp_preinv (mp_ptr res, mp_srcptr poly, ulong e, mp_srcptr f, slong lenf, mp_srcptr finv, slong lenfinv, nmod_t mod) noexcept
    void nmod_poly_powmod_ui_binexp_preinv(nmod_poly_t res, const nmod_poly_t poly, ulong e, const nmod_poly_t f, const nmod_poly_t finv) noexcept
    void _nmod_poly_powmod_fmpz_binexp_preinv (mp_ptr res, mp_srcptr poly, fmpz_t e, mp_srcptr f, slong lenf, mp_srcptr finv, slong lenfinv, nmod_t mod) noexcept
    void nmod_poly_powmod_fmpz_binexp_preinv(nmod_poly_t res, const nmod_poly_t poly, fmpz_t e, const nmod_poly_t f, const nmod_poly_t finv) noexcept
    void _nmod_poly_powmod_x_ui_preinv (mp_ptr res, ulong e, mp_srcptr f, slong lenf, mp_srcptr finv, slong lenfinv, nmod_t mod) noexcept
    void nmod_poly_powmod_x_ui_preinv(nmod_poly_t res, ulong e, const nmod_poly_t f, const nmod_poly_t finv) noexcept
    void _nmod_poly_powmod_x_fmpz_preinv (mp_ptr res, fmpz_t e, mp_srcptr f, slong lenf, mp_srcptr finv, slong lenfinv, nmod_t mod) noexcept
    void nmod_poly_powmod_x_fmpz_preinv(nmod_poly_t res, fmpz_t e, const nmod_poly_t f, const nmod_poly_t finv) noexcept
    void _nmod_poly_powers_mod_preinv_naive(mp_ptr * res, mp_srcptr f, slong flen, slong n, mp_srcptr g, slong glen, mp_srcptr ginv, slong ginvlen, const nmod_t mod) noexcept
    void nmod_poly_powers_mod_naive(nmod_poly_struct * res, const nmod_poly_t f, slong n, const nmod_poly_t g) noexcept
    void _nmod_poly_powers_mod_preinv_threaded_pool(mp_ptr * res, mp_srcptr f, slong flen, slong n, mp_srcptr g, slong glen, mp_srcptr ginv, slong ginvlen, const nmod_t mod, thread_pool_handle * threads, slong num_threads) noexcept
    void _nmod_poly_powers_mod_preinv_threaded(mp_ptr * res, mp_srcptr f, slong flen, slong n, mp_srcptr g, slong glen, mp_srcptr ginv, slong ginvlen, const nmod_t mod) noexcept
    void nmod_poly_powers_mod_bsgs(nmod_poly_struct * res, const nmod_poly_t f, slong n, const nmod_poly_t g) noexcept
    void _nmod_poly_divrem_basecase(mp_ptr Q, mp_ptr R, mp_srcptr A, slong A_len, mp_srcptr B, slong B_len, nmod_t mod) noexcept
    void nmod_poly_divrem_basecase(nmod_poly_t Q, nmod_poly_t R, const nmod_poly_t A, const nmod_poly_t B) noexcept
    void _nmod_poly_divrem(mp_ptr Q, mp_ptr R, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_divrem(nmod_poly_t Q, nmod_poly_t R, const nmod_poly_t A, const nmod_poly_t B) noexcept
    void _nmod_poly_div(mp_ptr Q, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_div(nmod_poly_t Q, const nmod_poly_t A, const nmod_poly_t B) noexcept
    void _nmod_poly_rem_q1(mp_ptr R, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void _nmod_poly_rem(mp_ptr R, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_rem(nmod_poly_t R, const nmod_poly_t A, const nmod_poly_t B) noexcept
    void _nmod_poly_inv_series_basecase(mp_ptr Qinv, mp_srcptr Q, slong Qlen, slong n, nmod_t mod) noexcept
    void nmod_poly_inv_series_basecase(nmod_poly_t Qinv, const nmod_poly_t Q, slong n) noexcept
    void _nmod_poly_inv_series_newton(mp_ptr Qinv, mp_srcptr Q, slong Qlen, slong n, nmod_t mod) noexcept
    void nmod_poly_inv_series_newton(nmod_poly_t Qinv, const nmod_poly_t Q, slong n) noexcept
    void _nmod_poly_inv_series(mp_ptr Qinv, mp_srcptr Q, slong Qlen, slong n, nmod_t mod) noexcept
    void nmod_poly_inv_series(nmod_poly_t Qinv, const nmod_poly_t Q, slong n) noexcept
    void _nmod_poly_div_series_basecase(mp_ptr Q, mp_srcptr A, slong Alen, mp_srcptr B, slong Blen, slong n, nmod_t mod) noexcept
    void nmod_poly_div_series_basecase(nmod_poly_t Q, const nmod_poly_t A, const nmod_poly_t B, slong n) noexcept
    void _nmod_poly_div_series(mp_ptr Q, mp_srcptr A, slong Alen, mp_srcptr B, slong Blen, slong n, nmod_t mod) noexcept
    void nmod_poly_div_series(nmod_poly_t Q, const nmod_poly_t A, const nmod_poly_t B, slong n) noexcept
    void _nmod_poly_div_newton_n_preinv (mp_ptr Q, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, mp_srcptr Binv, slong lenBinv, nmod_t mod) noexcept
    void nmod_poly_div_newton_n_preinv (nmod_poly_t Q, const nmod_poly_t A, const nmod_poly_t B, const nmod_poly_t Binv) noexcept
    void _nmod_poly_divrem_newton_n_preinv (mp_ptr Q, mp_ptr R, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, mp_srcptr Binv, slong lenBinv, nmod_t mod) noexcept
    void nmod_poly_divrem_newton_n_preinv(nmod_poly_t Q, nmod_poly_t R, const nmod_poly_t A, const nmod_poly_t B, const nmod_poly_t Binv) noexcept
    mp_limb_t _nmod_poly_div_root(mp_ptr Q, mp_srcptr A, slong len, mp_limb_t c, nmod_t mod) noexcept
    mp_limb_t nmod_poly_div_root(nmod_poly_t Q, const nmod_poly_t A, mp_limb_t c) noexcept
    int _nmod_poly_divides_classical(mp_ptr Q, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    int nmod_poly_divides_classical(nmod_poly_t Q, const nmod_poly_t A, const nmod_poly_t B) noexcept
    int _nmod_poly_divides(mp_ptr Q, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    int nmod_poly_divides(nmod_poly_t Q, const nmod_poly_t A, const nmod_poly_t B) noexcept
    ulong nmod_poly_remove(nmod_poly_t f, const nmod_poly_t p) noexcept
    void _nmod_poly_derivative(mp_ptr x_prime, mp_srcptr x, slong len, nmod_t mod) noexcept
    void nmod_poly_derivative(nmod_poly_t x_prime, const nmod_poly_t x) noexcept
    void _nmod_poly_integral(mp_ptr x_int, mp_srcptr x, slong len, nmod_t mod) noexcept
    void nmod_poly_integral(nmod_poly_t x_int, const nmod_poly_t x) noexcept
    mp_limb_t _nmod_poly_evaluate_nmod(mp_srcptr poly, slong len, mp_limb_t c, nmod_t mod) noexcept
    mp_limb_t nmod_poly_evaluate_nmod(const nmod_poly_t poly, mp_limb_t c) noexcept
    void nmod_poly_evaluate_mat_horner(nmod_mat_t dest, const nmod_poly_t poly, const nmod_mat_t c) noexcept
    void nmod_poly_evaluate_mat_paterson_stockmeyer(nmod_mat_t dest, const nmod_poly_t poly, const nmod_mat_t c) noexcept
    void nmod_poly_evaluate_mat(nmod_mat_t dest, const nmod_poly_t poly, const nmod_mat_t c) noexcept
    void _nmod_poly_evaluate_nmod_vec_iter(mp_ptr ys, mp_srcptr poly, slong len, mp_srcptr xs, slong n, nmod_t mod) noexcept
    void nmod_poly_evaluate_nmod_vec_iter(mp_ptr ys, const nmod_poly_t poly, mp_srcptr xs, slong n) noexcept
    void _nmod_poly_evaluate_nmod_vec_fast_precomp(mp_ptr vs, mp_srcptr poly, slong plen, const mp_ptr * tree, slong len, nmod_t mod) noexcept
    void _nmod_poly_evaluate_nmod_vec_fast(mp_ptr ys, mp_srcptr poly, slong len, mp_srcptr xs, slong n, nmod_t mod) noexcept
    void nmod_poly_evaluate_nmod_vec_fast(mp_ptr ys, const nmod_poly_t poly, mp_srcptr xs, slong n) noexcept
    void _nmod_poly_evaluate_nmod_vec(mp_ptr ys, mp_srcptr poly, slong len, mp_srcptr xs, slong n, nmod_t mod) noexcept
    void nmod_poly_evaluate_nmod_vec(mp_ptr ys, const nmod_poly_t poly, mp_srcptr xs, slong n) noexcept
    void _nmod_poly_interpolate_nmod_vec(mp_ptr poly, mp_srcptr xs, mp_srcptr ys, slong n, nmod_t mod) noexcept
    void nmod_poly_interpolate_nmod_vec(nmod_poly_t poly, mp_srcptr xs, mp_srcptr ys, slong n) noexcept
    void _nmod_poly_interpolation_weights(mp_ptr w, const mp_ptr * tree, slong len, nmod_t mod) noexcept
    void _nmod_poly_interpolate_nmod_vec_fast_precomp(mp_ptr poly, mp_srcptr ys, const mp_ptr * tree, mp_srcptr weights, slong len, nmod_t mod) noexcept
    void _nmod_poly_interpolate_nmod_vec_fast(mp_ptr poly, mp_srcptr xs, mp_srcptr ys, slong n, nmod_t mod) noexcept
    void nmod_poly_interpolate_nmod_vec_fast(nmod_poly_t poly, mp_srcptr xs, mp_srcptr ys, slong n) noexcept
    void _nmod_poly_interpolate_nmod_vec_newton(mp_ptr poly, mp_srcptr xs, mp_srcptr ys, slong n, nmod_t mod) noexcept
    void nmod_poly_interpolate_nmod_vec_newton(nmod_poly_t poly, mp_srcptr xs, mp_srcptr ys, slong n) noexcept
    void _nmod_poly_interpolate_nmod_vec_barycentric(mp_ptr poly, mp_srcptr xs, mp_srcptr ys, slong n, nmod_t mod) noexcept
    void nmod_poly_interpolate_nmod_vec_barycentric(nmod_poly_t poly, mp_srcptr xs, mp_srcptr ys, slong n) noexcept
    void _nmod_poly_compose_horner(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_compose_horner(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void _nmod_poly_compose_divconquer(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_compose_divconquer(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void _nmod_poly_compose(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    void nmod_poly_compose(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2) noexcept
    void _nmod_poly_taylor_shift_horner(mp_ptr poly, mp_limb_t c, slong len, nmod_t mod) noexcept
    void nmod_poly_taylor_shift_horner(nmod_poly_t g, const nmod_poly_t f, mp_limb_t c) noexcept
    void _nmod_poly_taylor_shift_convolution(mp_ptr poly, mp_limb_t c, slong len, nmod_t mod) noexcept
    void nmod_poly_taylor_shift_convolution(nmod_poly_t g, const nmod_poly_t f, mp_limb_t c) noexcept
    void _nmod_poly_taylor_shift(mp_ptr poly, mp_limb_t c, slong len, nmod_t mod) noexcept
    void nmod_poly_taylor_shift(nmod_poly_t g, const nmod_poly_t f, mp_limb_t c) noexcept
    void _nmod_poly_compose_mod_horner(mp_ptr res, mp_srcptr f, slong lenf, mp_srcptr g, mp_srcptr h, slong lenh, nmod_t mod) noexcept
    void nmod_poly_compose_mod_horner(nmod_poly_t res, const nmod_poly_t f, const nmod_poly_t g, const nmod_poly_t h) noexcept
    void _nmod_poly_compose_mod_brent_kung(mp_ptr res, mp_srcptr f, slong lenf, mp_srcptr g, mp_srcptr h, slong lenh, nmod_t mod) noexcept
    void nmod_poly_compose_mod_brent_kung(nmod_poly_t res, const nmod_poly_t f, const nmod_poly_t g, const nmod_poly_t h) noexcept
    void _nmod_poly_compose_mod_brent_kung_preinv(mp_ptr res, mp_srcptr f, slong lenf, mp_srcptr g, mp_srcptr h, slong lenh, mp_srcptr hinv, slong lenhinv, nmod_t mod) noexcept
    void nmod_poly_compose_mod_brent_kung_preinv(nmod_poly_t res, const nmod_poly_t f, const nmod_poly_t g, const nmod_poly_t h, const nmod_poly_t hinv) noexcept
    void _nmod_poly_reduce_matrix_mod_poly (nmod_mat_t A, const nmod_mat_t B, const nmod_poly_t f) noexcept
    void _nmod_poly_precompute_matrix_worker (void * arg_ptr) noexcept
    void _nmod_poly_precompute_matrix (nmod_mat_t A, mp_srcptr f, mp_srcptr g, slong leng, mp_srcptr ginv, slong lenginv, nmod_t mod) noexcept
    void nmod_poly_precompute_matrix (nmod_mat_t A, const nmod_poly_t f, const nmod_poly_t g, const nmod_poly_t ginv) noexcept
    void _nmod_poly_compose_mod_brent_kung_precomp_preinv_worker(void * arg_ptr) noexcept
    void _nmod_poly_compose_mod_brent_kung_precomp_preinv(mp_ptr res, mp_srcptr f, slong lenf, const nmod_mat_t A, mp_srcptr h, slong lenh, mp_srcptr hinv, slong lenhinv, nmod_t mod) noexcept
    void nmod_poly_compose_mod_brent_kung_precomp_preinv(nmod_poly_t res, const nmod_poly_t f, const nmod_mat_t A, const nmod_poly_t h, const nmod_poly_t hinv) noexcept
    void _nmod_poly_compose_mod_brent_kung_vec_preinv(nmod_poly_struct * res, const nmod_poly_struct * polys, slong len1, slong l, mp_srcptr g, slong leng, mp_srcptr h, slong lenh, mp_srcptr hinv, slong lenhinv, nmod_t mod) noexcept
    void nmod_poly_compose_mod_brent_kung_vec_preinv(nmod_poly_struct * res, const nmod_poly_struct * polys, slong len1, slong n, const nmod_poly_t g, const nmod_poly_t h, const nmod_poly_t hinv) noexcept
    void _nmod_poly_compose_mod_brent_kung_vec_preinv_threaded_pool(nmod_poly_struct * res, const nmod_poly_struct * polys, slong lenpolys, slong l, mp_srcptr g, slong glen, mp_srcptr poly, slong len, mp_srcptr polyinv, slong leninv, nmod_t mod, thread_pool_handle * threads, slong num_threads) noexcept
    void nmod_poly_compose_mod_brent_kung_vec_preinv_threaded_pool(nmod_poly_struct * res, const nmod_poly_struct * polys, slong len1, slong n, const nmod_poly_t g, const nmod_poly_t poly, const nmod_poly_t polyinv, thread_pool_handle * threads, slong num_threads) noexcept
    void nmod_poly_compose_mod_brent_kung_vec_preinv_threaded(nmod_poly_struct * res, const nmod_poly_struct * polys, slong len1, slong n, const nmod_poly_t g, const nmod_poly_t poly, const nmod_poly_t polyinv) noexcept
    void _nmod_poly_compose_mod(mp_ptr res, mp_srcptr f, slong lenf, mp_srcptr g, mp_srcptr h, slong lenh, nmod_t mod) noexcept
    void nmod_poly_compose_mod(nmod_poly_t res, const nmod_poly_t f, const nmod_poly_t g, const nmod_poly_t h) noexcept
    slong _nmod_poly_gcd_euclidean(mp_ptr G, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_gcd_euclidean(nmod_poly_t G, const nmod_poly_t A, const nmod_poly_t B) noexcept
    slong _nmod_poly_hgcd(mp_ptr * M, slong * lenM, mp_ptr A, slong * lenA, mp_ptr B, slong * lenB, mp_srcptr a, slong lena, mp_srcptr b, slong lenb, nmod_t mod) noexcept
    slong _nmod_poly_gcd_hgcd(mp_ptr G, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_gcd_hgcd(nmod_poly_t G, const nmod_poly_t A, const nmod_poly_t B) noexcept
    slong _nmod_poly_gcd(mp_ptr G, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_gcd(nmod_poly_t G, const nmod_poly_t A, const nmod_poly_t B) noexcept
    slong _nmod_poly_xgcd_euclidean(mp_ptr G, mp_ptr S, mp_ptr T, mp_srcptr A, slong A_len, mp_srcptr B, slong B_len, nmod_t mod) noexcept
    void nmod_poly_xgcd_euclidean(nmod_poly_t G, nmod_poly_t S, nmod_poly_t T, const nmod_poly_t A, const nmod_poly_t B) noexcept
    slong _nmod_poly_xgcd_hgcd(mp_ptr G, mp_ptr S, mp_ptr T, mp_srcptr A, slong A_len, mp_srcptr B, slong B_len, nmod_t mod) noexcept
    void nmod_poly_xgcd_hgcd(nmod_poly_t G, nmod_poly_t S, nmod_poly_t T, const nmod_poly_t A, const nmod_poly_t B) noexcept
    slong _nmod_poly_xgcd(mp_ptr G, mp_ptr S, mp_ptr T, mp_srcptr A, slong lenA, mp_srcptr B, slong lenB, nmod_t mod) noexcept
    void nmod_poly_xgcd(nmod_poly_t G, nmod_poly_t S, nmod_poly_t T, const nmod_poly_t A, const nmod_poly_t B) noexcept
    mp_limb_t _nmod_poly_resultant_euclidean(mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    mp_limb_t nmod_poly_resultant_euclidean(const nmod_poly_t f, const nmod_poly_t g) noexcept
    mp_limb_t _nmod_poly_resultant_hgcd(mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    mp_limb_t nmod_poly_resultant_hgcd(const nmod_poly_t f, const nmod_poly_t g) noexcept
    mp_limb_t _nmod_poly_resultant(mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, nmod_t mod) noexcept
    mp_limb_t nmod_poly_resultant(const nmod_poly_t f, const nmod_poly_t g) noexcept
    slong _nmod_poly_gcdinv(mp_limb_t * G, mp_limb_t * S, const mp_limb_t * A, slong lenA, const mp_limb_t * B, slong lenB, const nmod_t mod) noexcept
    void nmod_poly_gcdinv(nmod_poly_t G, nmod_poly_t S, const nmod_poly_t A, const nmod_poly_t B) noexcept
    int _nmod_poly_invmod(mp_limb_t * A, const mp_limb_t * B, slong lenB, const mp_limb_t * P, slong lenP, const nmod_t mod) noexcept
    int nmod_poly_invmod(nmod_poly_t A, const nmod_poly_t B, const nmod_poly_t P) noexcept
    mp_limb_t _nmod_poly_discriminant(mp_srcptr poly, slong len, nmod_t mod) noexcept
    mp_limb_t nmod_poly_discriminant(const nmod_poly_t f) noexcept
    void _nmod_poly_compose_series(mp_ptr res, mp_srcptr poly1, slong len1, mp_srcptr poly2, slong len2, slong n, nmod_t mod) noexcept
    void nmod_poly_compose_series(nmod_poly_t res, const nmod_poly_t poly1, const nmod_poly_t poly2, slong n) noexcept
    void _nmod_poly_revert_series(mp_ptr Qinv, mp_srcptr Q, slong Qlen, slong n, nmod_t mod) noexcept
    void nmod_poly_revert_series(nmod_poly_t Qinv, const nmod_poly_t Q, slong n) noexcept
    void _nmod_poly_invsqrt_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_invsqrt_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_sqrt_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_sqrt_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    int _nmod_poly_sqrt(mp_ptr s, mp_srcptr p, slong n, nmod_t mod) noexcept
    int nmod_poly_sqrt(nmod_poly_t s, const nmod_poly_t p) noexcept
    void _nmod_poly_power_sums_naive(mp_ptr res, mp_srcptr poly, slong len, slong n, nmod_t mod) noexcept
    void nmod_poly_power_sums_naive(nmod_poly_t res, const nmod_poly_t poly, slong n) noexcept
    void _nmod_poly_power_sums_schoenhage(mp_ptr res, mp_srcptr poly, slong len, slong n, nmod_t mod) noexcept
    void nmod_poly_power_sums_schoenhage(nmod_poly_t res, const nmod_poly_t poly, slong n) noexcept
    void _nmod_poly_power_sums(mp_ptr res, mp_srcptr poly, slong len, slong n, nmod_t mod) noexcept
    void nmod_poly_power_sums(nmod_poly_t res, const nmod_poly_t poly, slong n) noexcept
    void _nmod_poly_power_sums_to_poly_naive(mp_ptr res, mp_srcptr poly, slong len, nmod_t mod) noexcept
    void nmod_poly_power_sums_to_poly_naive(nmod_poly_t res, const nmod_poly_t Q) noexcept
    void _nmod_poly_power_sums_to_poly_schoenhage(mp_ptr res, mp_srcptr poly, slong len, nmod_t mod) noexcept
    void nmod_poly_power_sums_to_poly_schoenhage(nmod_poly_t res, const nmod_poly_t Q) noexcept
    void _nmod_poly_power_sums_to_poly(mp_ptr res, mp_srcptr poly, slong len, nmod_t mod) noexcept
    void nmod_poly_power_sums_to_poly(nmod_poly_t res, const nmod_poly_t Q) noexcept
    void _nmod_poly_log_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_log_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_exp_series(mp_ptr f, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void  _nmod_poly_exp_expinv_series(mp_ptr f, mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_exp_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_atan_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_atan_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_atanh_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_atanh_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_asin_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_asin_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_asinh_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_asinh_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_sin_series(mp_ptr g, mp_srcptr h, slong n, nmod_t mod) noexcept
    void nmod_poly_sin_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_cos_series(mp_ptr g, mp_srcptr h, slong n, nmod_t mod) noexcept
    void nmod_poly_cos_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_tan_series(mp_ptr g, mp_srcptr h, slong hlen, slong n, nmod_t mod) noexcept
    void nmod_poly_tan_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_sinh_series(mp_ptr g, mp_srcptr h, slong n, nmod_t mod) noexcept
    void nmod_poly_sinh_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_cosh_series(mp_ptr g, mp_srcptr h, slong n, nmod_t mod) noexcept
    void nmod_poly_cosh_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_tanh_series(mp_ptr g, mp_srcptr h, slong n, nmod_t mod) noexcept
    void nmod_poly_tanh_series(nmod_poly_t g, const nmod_poly_t h, slong n) noexcept
    void _nmod_poly_product_roots_nmod_vec(mp_ptr poly, mp_srcptr xs, slong n, nmod_t mod) noexcept
    void nmod_poly_product_roots_nmod_vec(nmod_poly_t poly, mp_srcptr xs, slong n) noexcept
    int nmod_poly_find_distinct_nonzero_roots(mp_limb_t * roots, const nmod_poly_t A) noexcept
    mp_ptr * _nmod_poly_tree_alloc(slong len) noexcept
    void _nmod_poly_tree_free(mp_ptr * tree, slong len) noexcept
    void _nmod_poly_tree_build(mp_ptr * tree, mp_srcptr roots, slong len, nmod_t mod) noexcept
    void nmod_poly_inflate(nmod_poly_t result, const nmod_poly_t input, ulong inflation) noexcept
    void nmod_poly_deflate(nmod_poly_t result, const nmod_poly_t input, ulong deflation) noexcept
    ulong nmod_poly_deflation(const nmod_poly_t input) noexcept
    void nmod_poly_multi_crt_init(nmod_poly_multi_crt_t CRT) noexcept
    int nmod_poly_multi_crt_precompute(nmod_poly_multi_crt_t CRT, const nmod_poly_struct * moduli, slong len) noexcept
    int nmod_poly_multi_crt_precompute_p(nmod_poly_multi_crt_t CRT, const nmod_poly_struct * const * moduli, slong len) noexcept
    void nmod_poly_multi_crt_precomp(nmod_poly_t output, const nmod_poly_multi_crt_t CRT, const nmod_poly_struct * values) noexcept
    void nmod_poly_multi_crt_precomp_p(nmod_poly_t output, const nmod_poly_multi_crt_t CRT, const nmod_poly_struct * const * values) noexcept
    int nmod_poly_multi_crt(nmod_poly_t output, const nmod_poly_struct * moduli, const nmod_poly_struct * values, slong len) noexcept
    void nmod_poly_multi_crt_clear(nmod_poly_multi_crt_t CRT) noexcept
    slong _nmod_poly_multi_crt_local_size(const nmod_poly_multi_crt_t CRT) noexcept
    void _nmod_poly_multi_crt_run(nmod_poly_struct * outputs, const nmod_poly_multi_crt_t CRT, const nmod_poly_struct * inputs) noexcept
    void _nmod_poly_multi_crt_run_p(nmod_poly_struct * outputs, const nmod_poly_multi_crt_t CRT, const nmod_poly_struct * const * inputs) noexcept
    void nmod_berlekamp_massey_init(nmod_berlekamp_massey_t B, mp_limb_t p) noexcept
    void nmod_berlekamp_massey_clear(nmod_berlekamp_massey_t B) noexcept
    void nmod_berlekamp_massey_start_over(nmod_berlekamp_massey_t B) noexcept
    void nmod_berlekamp_massey_set_prime(nmod_berlekamp_massey_t B, mp_limb_t p) noexcept
    void nmod_berlekamp_massey_add_points(nmod_berlekamp_massey_t B, const mp_limb_t * a, slong count) noexcept
    void nmod_berlekamp_massey_add_zeros(nmod_berlekamp_massey_t B, slong count) noexcept
    void nmod_berlekamp_massey_add_point(nmod_berlekamp_massey_t B, mp_limb_t a) noexcept
    int nmod_berlekamp_massey_reduce(nmod_berlekamp_massey_t B) noexcept
    slong nmod_berlekamp_massey_point_count(const nmod_berlekamp_massey_t B) noexcept
    const mp_limb_t * nmod_berlekamp_massey_points(const nmod_berlekamp_massey_t B) noexcept
    const nmod_poly_struct * nmod_berlekamp_massey_V_poly(const nmod_berlekamp_massey_t B) noexcept
    const nmod_poly_struct * nmod_berlekamp_massey_R_poly(const nmod_berlekamp_massey_t B) noexcept
