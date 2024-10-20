# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/fq_nmod_mpoly_factor.h

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
    void fq_nmod_mpoly_factor_init(fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_ctx_t ctx) noexcept
    void fq_nmod_mpoly_factor_clear(fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_ctx_t ctx) noexcept
    void fq_nmod_mpoly_factor_swap(fq_nmod_mpoly_factor_t f, fq_nmod_mpoly_factor_t g, const fq_nmod_mpoly_ctx_t ctx) noexcept
    slong fq_nmod_mpoly_factor_length(const fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_ctx_t ctx) noexcept
    void fq_nmod_mpoly_factor_get_constant_fq_nmod(fq_nmod_t c, const fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_ctx_t ctx) noexcept
    void fq_nmod_mpoly_factor_get_base(fq_nmod_mpoly_t p, const fq_nmod_mpoly_factor_t f, slong i, const fq_nmod_mpoly_ctx_t ctx) noexcept
    void fq_nmod_mpoly_factor_swap_base(fq_nmod_mpoly_t p, const fq_nmod_mpoly_factor_t f, slong i, const fq_nmod_mpoly_ctx_t ctx) noexcept
    slong fq_nmod_mpoly_factor_get_exp_si(fq_nmod_mpoly_factor_t f, slong i, const fq_nmod_mpoly_ctx_t ctx) noexcept
    void fq_nmod_mpoly_factor_sort(fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_ctx_t ctx) noexcept
    int fq_nmod_mpoly_factor_squarefree(fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_t A, const fq_nmod_mpoly_ctx_t ctx) noexcept
    int fq_nmod_mpoly_factor(fq_nmod_mpoly_factor_t f, const fq_nmod_mpoly_t A, const fq_nmod_mpoly_ctx_t ctx) noexcept
