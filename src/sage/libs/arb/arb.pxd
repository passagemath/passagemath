# sage_setup: distribution = sagemath-flint
# Deprecated header file; use sage/libs/flint/arb.pxd instead
# See https://github.com/sagemath/sage/pull/36449

from sage.libs.flint.types cimport arb_struct, arb_t, arb_ptr, arb_srcptr

from sage.libs.flint.arb cimport (
    arb_midref,
    arb_radref,
    arb_init,
    arb_clear,
    arb_swap,
    arb_set,
    arb_set_arf,
    arb_set_si,
    arb_set_ui,
    arb_set_fmpz,
    arb_set_fmpz_2exp,
    arb_set_round,
    arb_set_round_fmpz,
    arb_set_round_fmpz_2exp,
    arb_set_fmpq,
    arb_set_str,
    arb_get_str,
    arb_zero,
    arb_one,
    arb_dump_str,
    arb_pos_inf,
    arb_neg_inf,
    arb_zero_pm_inf,
    arb_indeterminate,
    arb_print,
    arb_printd,
    arb_printn,
    arb_load_str,
    arb_randtest,
    arb_randtest_exact,
    arb_randtest_precise,
    arb_randtest_wide,
    arb_randtest_special,
    arb_get_rand_fmpq,
    arb_add_error_arf,
    arb_add_error_2exp_si,
    arb_add_error_2exp_fmpz,
    arb_add_error,
    arb_union,
    arb_get_abs_ubound_arf,
    arb_get_abs_lbound_arf,
    arb_get_mag,
    arb_get_mag_lower,
    arb_get_mag_lower_nonnegative,
    arb_get_interval_fmpz_2exp,
    arb_set_interval_arf,
    arb_set_interval_mpfr,
    arb_get_interval_arf,
    arb_get_interval_mpfr,
    arb_rel_error_bits,
    arb_rel_accuracy_bits,
    arb_bits,
    arb_trim,
    arb_get_unique_fmpz,
    arb_floor,
    arb_ceil,
    arb_get_fmpz_mid_rad_10exp,
    arb_is_zero,
    arb_is_nonzero,
    arb_is_one,
    arb_is_finite,
    arb_is_exact,
    arb_is_int,
    arb_equal,
    arb_is_positive,
    arb_is_nonnegative,
    arb_is_negative,
    arb_is_nonpositive,
    arb_overlaps,
    arb_contains_arf,
    arb_contains_fmpq,
    arb_contains_fmpz,
    arb_contains_si,
    arb_contains_mpfr,
    arb_contains,
    arb_contains_zero,
    arb_contains_negative,
    arb_contains_nonpositive,
    arb_contains_positive,
    arb_contains_nonnegative,
    arb_contains_int,
    arb_eq,
    arb_ne,
    arb_le,
    arb_ge,
    arb_lt,
    arb_gt,
    arb_neg,
    arb_neg_round,
    arb_abs,
    arb_min,
    arb_max,
    arb_add,
    arb_add_arf,
    arb_add_ui,
    arb_add_si,
    arb_add_fmpz,
    arb_add_fmpz_2exp,
    arb_sub,
    arb_sub_arf,
    arb_sub_ui,
    arb_sub_si,
    arb_sub_fmpz,
    arb_mul,
    arb_mul_arf,
    arb_mul_si,
    arb_mul_ui,
    arb_mul_fmpz,
    arb_mul_2exp_si,
    arb_mul_2exp_fmpz,
    arb_addmul,
    arb_addmul_arf,
    arb_addmul_si,
    arb_addmul_ui,
    arb_addmul_fmpz,
    arb_submul,
    arb_submul_arf,
    arb_submul_si,
    arb_submul_ui,
    arb_submul_fmpz,
    arb_inv,
    arb_div,
    arb_div_arf,
    arb_div_si,
    arb_div_ui,
    arb_div_fmpz,
    arb_fmpz_div_fmpz,
    arb_ui_div,
    arb_div_2expm1_ui,
    arb_sqrt,
    arb_sqrt_arf,
    arb_sqrt_fmpz,
    arb_sqrt_ui,
    arb_sqrtpos,
    arb_hypot,
    arb_rsqrt,
    arb_rsqrt_ui,
    arb_sqrt1pm1,
    arb_root,
    arb_pow_fmpz_binexp,
    arb_pow_fmpz,
    arb_pow_ui,
    arb_ui_pow_ui,
    arb_si_pow_ui,
    arb_pow_fmpq,
    arb_pow,
    arb_log_ui,
    arb_log_fmpz,
    arb_log_arf,
    arb_log,
    arb_log_ui_from_prev,
    arb_log1p,
    arb_exp,
    arb_expm1,
    arb_sin,
    arb_cos,
    arb_sin_cos,
    arb_sin_pi,
    arb_cos_pi,
    arb_sin_cos_pi,
    arb_tan,
    arb_cot,
    arb_sin_cos_pi_fmpq,
    arb_sin_pi_fmpq,
    arb_cos_pi_fmpq,
    arb_tan_pi,
    arb_cot_pi,
    arb_sec,
    arb_csc,
    arb_atan_arf,
    arb_atan,
    arb_atan2,
    arb_asin,
    arb_acos,
    arb_sinh,
    arb_cosh,
    arb_sinh_cosh,
    arb_tanh,
    arb_coth,
    arb_sech,
    arb_csch,
    arb_asinh,
    arb_acosh,
    arb_atanh,
    arb_const_pi,
    arb_const_sqrt_pi,
    arb_const_log_sqrt2pi,
    arb_const_log2,
    arb_const_log10,
    arb_const_euler,
    arb_const_catalan,
    arb_const_e,
    arb_const_khinchin,
    arb_const_glaisher,
    arb_const_apery,
    arb_lambertw,
    arb_rising_ui,
    arb_rising,
    arb_rising_fmpq_ui,
    arb_fac_ui,
    arb_bin_ui,
    arb_bin_uiui,
    arb_gamma,
    arb_gamma_fmpq,
    arb_gamma_fmpz,
    arb_lgamma,
    arb_rgamma,
    arb_digamma,
    arb_zeta_ui_vec_borwein,
    arb_zeta_ui_asymp,
    arb_zeta_ui_euler_product,
    arb_zeta_ui_bernoulli,
    arb_zeta_ui_borwein_bsplit,
    arb_zeta_ui_vec,
    arb_zeta_ui_vec_even,
    arb_zeta_ui_vec_odd,
    arb_zeta_ui,
    arb_zeta,
    arb_hurwitz_zeta,
    arb_bernoulli_ui,
    arb_bernoulli_ui_zeta,
    arb_polylog,
    arb_polylog_si,
    arb_fib_fmpz,
    arb_fib_ui,
    arb_agm,
    arb_chebyshev_t_ui,
    arb_chebyshev_u_ui,
    arb_chebyshev_t2_ui,
    arb_chebyshev_u2_ui,
    arb_bell_fmpz,
    arb_bell_ui,
    arb_doublefac_ui)
