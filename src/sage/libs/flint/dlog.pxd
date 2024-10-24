# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/dlog.h

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
    ulong dlog_once(ulong b, ulong a, const nmod_t mod, ulong n) noexcept
    void dlog_precomp_n_init(dlog_precomp_t pre, ulong a, ulong mod, ulong n, ulong num) noexcept
    ulong dlog_precomp(const dlog_precomp_t pre, ulong b) noexcept
    void dlog_precomp_clear(dlog_precomp_t pre) noexcept
    void dlog_precomp_modpe_init(dlog_precomp_t pre, ulong a, ulong p, ulong e, ulong pe, ulong num) noexcept
    void dlog_precomp_p_init(dlog_precomp_t pre, ulong a, ulong mod, ulong p, ulong num) noexcept
    void dlog_precomp_pe_init(dlog_precomp_t pre, ulong a, ulong mod, ulong p, ulong e, ulong pe, ulong num) noexcept
    void dlog_precomp_small_init(dlog_precomp_t pre, ulong a, ulong mod, ulong n, ulong num) noexcept
    void dlog_vec_fill(ulong * v, ulong nv, ulong x) noexcept
    void dlog_vec_set_not_found(ulong * v, ulong nv, nmod_t mod) noexcept
    void dlog_vec(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_loop(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_loop_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_eratos(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_eratos_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_sieve_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    void dlog_vec_sieve(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order) noexcept
    ulong dlog_table_init(dlog_table_t t, ulong a, ulong mod) noexcept
    void dlog_table_clear(dlog_table_t t) noexcept
    ulong dlog_table(const dlog_table_t t, ulong b) noexcept
    ulong dlog_bsgs_init(dlog_bsgs_t t, ulong a, ulong mod, ulong n, ulong m) noexcept
    void dlog_bsgs_clear(dlog_bsgs_t t) noexcept
    ulong dlog_bsgs(const dlog_bsgs_t t, ulong b) noexcept
    ulong dlog_modpe_init(dlog_modpe_t t, ulong a, ulong p, ulong e, ulong pe, ulong num) noexcept
    void dlog_modpe_clear(dlog_modpe_t t) noexcept
    ulong dlog_modpe(const dlog_modpe_t t, ulong b) noexcept
    ulong dlog_crt_init(dlog_crt_t t, ulong a, ulong mod, ulong n, ulong num) noexcept
    void dlog_crt_clear(dlog_crt_t t) noexcept
    ulong dlog_crt(const dlog_crt_t t, ulong b) noexcept
    ulong dlog_power_init(dlog_power_t t, ulong a, ulong mod, ulong p, ulong e, ulong num) noexcept
    void dlog_power_clear(dlog_power_t t) noexcept
    ulong dlog_power(const dlog_power_t t, ulong b) noexcept
    void dlog_rho_init(dlog_rho_t t, ulong a, ulong mod, ulong n) noexcept
    void dlog_rho_clear(dlog_rho_t t) noexcept
    ulong dlog_rho(const dlog_rho_t t, ulong b) noexcept
