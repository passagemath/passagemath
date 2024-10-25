# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/mpn_extras.h

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
    void flint_mpn_debug(mp_srcptr x, mp_size_t xsize) noexcept
    int flint_mpn_zero_p(mp_srcptr x, mp_size_t xsize) noexcept
    mp_limb_t flint_mpn_mul(mp_ptr z, mp_srcptr x, mp_size_t xn, mp_srcptr y, mp_size_t yn) noexcept
    void flint_mpn_mul_n(mp_ptr z, mp_srcptr x, mp_srcptr y, mp_size_t n) noexcept
    void flint_mpn_sqr(mp_ptr z, mp_srcptr x, mp_size_t n) noexcept
    mp_size_t flint_mpn_fmms1(mp_ptr y, mp_limb_t a1, mp_srcptr x1, mp_limb_t a2, mp_srcptr x2, mp_size_t n) noexcept
    int flint_mpn_divisible_1_odd(mp_srcptr x, mp_size_t xsize, mp_limb_t d) noexcept
    mp_size_t flint_mpn_divexact_1(mp_ptr x, mp_size_t xsize, mp_limb_t d) noexcept
    mp_size_t flint_mpn_remove_2exp(mp_ptr x, mp_size_t xsize, flint_bitcnt_t * bits) noexcept
    mp_size_t flint_mpn_remove_power_ascending(mp_ptr x, mp_size_t xsize, mp_ptr p, mp_size_t psize, ulong * exp) noexcept
    int flint_mpn_factor_trial(mp_srcptr x, mp_size_t xsize, slong start, slong stop) noexcept
    int flint_mpn_factor_trial_tree(slong * factors, mp_srcptr x, mp_size_t xsize, slong num_primes) noexcept
    int flint_mpn_divides(mp_ptr q, mp_srcptr array1, mp_size_t limbs1, mp_srcptr arrayg, mp_size_t limbsg, mp_ptr temp) noexcept
    mp_limb_t flint_mpn_preinv1(mp_limb_t d, mp_limb_t d2) noexcept
    mp_limb_t flint_mpn_divrem_preinv1(mp_ptr q, mp_ptr a, mp_size_t m, mp_srcptr b, mp_size_t n, mp_limb_t dinv) noexcept
    void flint_mpn_mulmod_preinv1(mp_ptr r, mp_srcptr a, mp_srcptr b, mp_size_t n, mp_srcptr d, mp_limb_t dinv, ulong norm) noexcept
    void flint_mpn_preinvn(mp_ptr dinv, mp_srcptr d, mp_size_t n) noexcept
    void flint_mpn_mod_preinvn(mp_ptr r, mp_srcptr a, mp_size_t m, mp_srcptr d, mp_size_t n, mp_srcptr dinv) noexcept
    mp_limb_t flint_mpn_divrem_preinvn(mp_ptr q, mp_ptr r, mp_srcptr a, mp_size_t m, mp_srcptr d, mp_size_t n, mp_srcptr dinv) noexcept
    void flint_mpn_mulmod_preinvn(mp_ptr r, mp_srcptr a, mp_srcptr b, mp_size_t n, mp_srcptr d, mp_srcptr dinv, ulong norm) noexcept
    mp_size_t flint_mpn_gcd_full2(mp_ptr arrayg, mp_srcptr array1, mp_size_t limbs1, mp_srcptr array2, mp_size_t limbs2, mp_ptr temp) noexcept
    mp_size_t flint_mpn_gcd_full(mp_ptr arrayg, mp_srcptr array1, mp_size_t limbs1, mp_srcptr array2, mp_size_t limbs2) noexcept
    void flint_mpn_rrandom(mp_limb_t * rp, gmp_randstate_t state, mp_size_t n) noexcept
    void flint_mpn_urandomb(mp_limb_t * rp, gmp_randstate_t state, flint_bitcnt_t n) noexcept
