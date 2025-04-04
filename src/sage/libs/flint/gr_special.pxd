# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/gr_special.h

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
    int gr_pi(gr_ptr res, gr_ctx_t ctx) noexcept
    int gr_euler(gr_ptr res, gr_ctx_t ctx) noexcept
    int gr_catalan(gr_ptr res, gr_ctx_t ctx) noexcept
    int gr_khinchin(gr_ptr res, gr_ctx_t ctx) noexcept
    int gr_glaisher(gr_ptr res, gr_ctx_t ctx) noexcept
    int gr_exp(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_expm1(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_exp2(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_exp10(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_exp_pi_i(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log1p(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log2(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log10(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log_pi_i(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sin(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cos(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sin_cos(gr_ptr res1, gr_ptr res2, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_tan(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cot(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sec(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_csc(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sin_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cos_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sin_cos_pi(gr_ptr res1, gr_ptr res2, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_tan_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cot_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sec_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_csc_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sinc(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sinc_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sinh(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cosh(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sinh_cosh(gr_ptr res1, gr_ptr res2, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_tanh(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_coth(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sech(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_csch(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_asin(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acos(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_atan(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_atan2(gr_ptr res, gr_srcptr y, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acot(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_asec(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acsc(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_asin_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acos_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_atan_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acot_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_asec_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acsc_pi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_asinh(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acosh(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_atanh(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acoth(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_asech(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_acsch(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_lambertw(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_lambertw_fmpz(gr_ptr res, gr_srcptr x, const fmpz_t k, gr_ctx_t ctx) noexcept
    int gr_fac(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_fac_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_fac_fmpz(gr_ptr res, const fmpz_t x, gr_ctx_t ctx) noexcept
    int gr_fac_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_rfac(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_rfac_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_rfac_fmpz(gr_ptr res, const fmpz_t x, gr_ctx_t ctx) noexcept
    int gr_rfac_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_bin(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bin_ui(gr_ptr res, gr_srcptr x, ulong y, gr_ctx_t ctx) noexcept
    int gr_bin_uiui(gr_ptr res, ulong x, ulong y, gr_ctx_t ctx) noexcept
    int gr_bin_vec(gr_ptr res, gr_srcptr x, slong len, gr_ctx_t ctx) noexcept
    int gr_bin_ui_vec(gr_ptr res, ulong x, slong len, gr_ctx_t ctx) noexcept
    int gr_rising(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_rising_ui(gr_ptr res, gr_srcptr x, ulong y, gr_ctx_t ctx) noexcept
    int gr_falling(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_falling_ui(gr_ptr res, gr_srcptr x, ulong y, gr_ctx_t ctx) noexcept
    int gr_gamma(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_gamma_fmpz(gr_ptr res, const fmpz_t x, gr_ctx_t ctx) noexcept
    int gr_gamma_fmpq(gr_ptr res, const fmpq_t x, gr_ctx_t ctx) noexcept
    int gr_rgamma(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_lgamma(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_digamma(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_barnes_g(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log_barnes_g(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_beta(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_doublefac(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_doublefac_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_harmonic(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_harmonic_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_bernoulli_ui(gr_ptr res, ulong n, gr_ctx_t ctx) noexcept
    int gr_bernoulli_fmpz(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_bernoulli_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_eulernum_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_eulernum_fmpz(gr_ptr res, const fmpz_t x, gr_ctx_t ctx) noexcept
    int gr_eulernum_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_fib_ui(gr_ptr res, ulong n, gr_ctx_t ctx) noexcept
    int gr_fib_fmpz(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_fib_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_stirling_s1u_uiui(gr_ptr res, ulong x, ulong y, gr_ctx_t ctx) noexcept
    int gr_stirling_s1_uiui(gr_ptr res, ulong x, ulong y, gr_ctx_t ctx) noexcept
    int gr_stirling_s2_uiui(gr_ptr res, ulong x, ulong y, gr_ctx_t ctx) noexcept
    int gr_stirling_s1u_ui_vec(gr_ptr res, ulong x, slong len, gr_ctx_t ctx) noexcept
    int gr_stirling_s1_ui_vec(gr_ptr res, ulong x, slong len, gr_ctx_t ctx) noexcept
    int gr_stirling_s2_ui_vec(gr_ptr res, ulong x, slong len, gr_ctx_t ctx) noexcept
    int gr_bellnum_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_bellnum_fmpz(gr_ptr res, const fmpz_t x, gr_ctx_t ctx) noexcept
    int gr_bellnum_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_partitions_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_partitions_fmpz(gr_ptr res, const fmpz_t x, gr_ctx_t ctx) noexcept
    int gr_partitions_vec(gr_ptr res, slong len, gr_ctx_t ctx) noexcept
    int gr_erf(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_erfc(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_erfcx(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_erfi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_erfinv(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_erfcinv(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_fresnel_s(gr_ptr res, gr_srcptr x, int normalized, gr_ctx_t ctx) noexcept
    int gr_fresnel_c(gr_ptr res, gr_srcptr x, int normalized, gr_ctx_t ctx) noexcept
    int gr_fresnel(gr_ptr res1, gr_ptr res2, gr_srcptr x, int normalized, gr_ctx_t ctx) noexcept
    int gr_gamma_upper(gr_ptr res, gr_srcptr x, gr_srcptr y, int regularized, gr_ctx_t ctx) noexcept
    int gr_gamma_lower(gr_ptr res, gr_srcptr x, gr_srcptr y, int regularized, gr_ctx_t ctx) noexcept
    int gr_beta_lower(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, int regularized, gr_ctx_t ctx) noexcept
    int gr_exp_integral(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_exp_integral_ei(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sin_integral(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cos_integral(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_sinh_integral(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_cosh_integral(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_log_integral(gr_ptr res, gr_srcptr x, int offset, gr_ctx_t ctx) noexcept
    int gr_dilog(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_chebyshev_t_fmpz(gr_ptr res, const fmpz_t n, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_chebyshev_t(gr_ptr res, gr_srcptr n, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_chebyshev_u_fmpz(gr_ptr res, const fmpz_t n, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_chebyshev_u(gr_ptr res, gr_srcptr n, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_jacobi_p(gr_ptr res, gr_srcptr n, gr_srcptr a, gr_srcptr b, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_gegenbauer_c(gr_ptr res, gr_srcptr n, gr_srcptr m, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_laguerre_l(gr_ptr res, gr_srcptr n, gr_srcptr m, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_hermite_h(gr_ptr res, gr_srcptr n, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_legendre_p(gr_ptr res, gr_srcptr n, gr_srcptr m, gr_srcptr z, int type, gr_ctx_t ctx) noexcept
    int gr_legendre_q(gr_ptr res, gr_srcptr n, gr_srcptr m, gr_srcptr z, int type, gr_ctx_t ctx) noexcept
    int gr_spherical_y_si(gr_ptr res, slong n, slong m, gr_srcptr theta, gr_srcptr phi, gr_ctx_t ctx) noexcept
    int gr_legendre_p_root_ui(gr_ptr root, gr_ptr weight, ulong n, ulong k, gr_ctx_t ctx) noexcept
    int gr_bessel_j(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bessel_y(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bessel_i(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bessel_k(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bessel_j_y(gr_ptr res1, gr_ptr res2, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bessel_i_scaled(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_bessel_k_scaled(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_airy(gr_ptr res1, gr_ptr res2, gr_ptr res3, gr_ptr res4, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_airy_ai(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_airy_bi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_airy_ai_prime(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_airy_bi_prime(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_airy_ai_zero(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_airy_bi_zero(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_airy_ai_prime_zero(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_airy_bi_prime_zero(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_coulomb(gr_ptr res1, gr_ptr res2, gr_ptr res3, gr_ptr res4, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_coulomb_f(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_coulomb_g(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_coulomb_hpos(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_coulomb_hneg(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_hypgeom_0f1(gr_ptr res, gr_srcptr a, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_hypgeom_1f1(gr_ptr res, gr_srcptr a, gr_srcptr b, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_hypgeom_u(gr_ptr res, gr_srcptr a, gr_srcptr b, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_hypgeom_2f1(gr_ptr res, gr_srcptr a, gr_srcptr b, gr_srcptr c, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_hypgeom_pfq(gr_ptr res, const gr_vec_t a, const gr_vec_t b, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_zeta(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_zeta_ui(gr_ptr res, ulong x, gr_ctx_t ctx) noexcept
    int gr_hurwitz_zeta(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_polygamma(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_polylog(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_lerch_phi(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_ctx_t ctx) noexcept
    int gr_stieltjes(gr_ptr res, const fmpz_t x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_dirichlet_eta(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_riemann_xi(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_zeta_zero(gr_ptr res, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_zeta_zero_vec(gr_ptr res, const fmpz_t n, slong len, gr_ctx_t ctx) noexcept
    int gr_zeta_nzeros(gr_ptr res, gr_srcptr t, gr_ctx_t ctx) noexcept
    int gr_dirichlet_chi_fmpz(gr_ptr res, const dirichlet_group_t G, const dirichlet_char_t chi, const fmpz_t n, gr_ctx_t ctx) noexcept
    int gr_dirichlet_chi_vec(gr_ptr res, const dirichlet_group_t G, const dirichlet_char_t chi, slong len, gr_ctx_t ctx) noexcept
    int gr_dirichlet_l(gr_ptr res, const dirichlet_group_t G, const dirichlet_char_t chi, gr_srcptr s, gr_ctx_t ctx) noexcept
    int gr_dirichlet_l_all(gr_vec_t res, const dirichlet_group_t G, gr_srcptr s, gr_ctx_t ctx) noexcept
    int gr_dirichlet_hardy_theta(gr_ptr res, const dirichlet_group_t G, const dirichlet_char_t chi, gr_srcptr t, gr_ctx_t ctx) noexcept
    int gr_dirichlet_hardy_z(gr_ptr res, const dirichlet_group_t G, const dirichlet_char_t chi, gr_srcptr t, gr_ctx_t ctx) noexcept
    int gr_agm1(gr_ptr res, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_agm(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_ctx_t ctx) noexcept
    int gr_elliptic_k(gr_ptr res, gr_srcptr m, gr_ctx_t ctx) noexcept
    int gr_elliptic_e(gr_ptr res, gr_srcptr m, gr_ctx_t ctx) noexcept
    int gr_elliptic_pi(gr_ptr res, gr_srcptr n, gr_srcptr m, gr_ctx_t ctx) noexcept
    int gr_elliptic_f(gr_ptr res, gr_srcptr phi, gr_srcptr m, int pi, gr_ctx_t ctx) noexcept
    int gr_elliptic_e_inc(gr_ptr res, gr_srcptr phi, gr_srcptr m, int pi, gr_ctx_t ctx) noexcept
    int gr_elliptic_pi_inc(gr_ptr res, gr_srcptr n, gr_srcptr phi, gr_srcptr m, int pi, gr_ctx_t ctx) noexcept
    int gr_carlson_rc(gr_ptr res, gr_srcptr x, gr_srcptr y, int flags, gr_ctx_t ctx) noexcept
    int gr_carlson_rf(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_carlson_rd(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_carlson_rg(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, int flags, gr_ctx_t ctx) noexcept
    int gr_carlson_rj(gr_ptr res, gr_srcptr x, gr_srcptr y, gr_srcptr z, gr_srcptr w, int flags, gr_ctx_t ctx) noexcept
    int gr_jacobi_theta(gr_ptr res1, gr_ptr res2, gr_ptr res3, gr_ptr res4, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_jacobi_theta_1(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_jacobi_theta_2(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_jacobi_theta_3(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_jacobi_theta_4(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_dedekind_eta(gr_ptr res, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_dedekind_eta_q(gr_ptr res, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_modular_j(gr_ptr res, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_modular_lambda(gr_ptr res, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_modular_delta(gr_ptr res, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_hilbert_class_poly(gr_ptr res, slong D, gr_srcptr x, gr_ctx_t ctx) noexcept
    int gr_eisenstein_e(gr_ptr res, ulong n, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_eisenstein_g(gr_ptr res, ulong n, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_eisenstein_g_vec(gr_ptr res, gr_srcptr tau, slong len, gr_ctx_t ctx) noexcept
    int gr_elliptic_invariants(gr_ptr res1, gr_ptr res2, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_elliptic_roots(gr_ptr res1, gr_ptr res2, gr_ptr res3, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_weierstrass_p(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_weierstrass_p_prime(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_weierstrass_p_inv(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_weierstrass_zeta(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
    int gr_weierstrass_sigma(gr_ptr res, gr_srcptr z, gr_srcptr tau, gr_ctx_t ctx) noexcept
