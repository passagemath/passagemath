# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/fmpz_poly_factor.h

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
    void fmpz_poly_factor_init(fmpz_poly_factor_t fac) noexcept
    void fmpz_poly_factor_init2(fmpz_poly_factor_t fac, slong alloc) noexcept
    void fmpz_poly_factor_realloc(fmpz_poly_factor_t fac, slong alloc) noexcept
    void fmpz_poly_factor_fit_length(fmpz_poly_factor_t fac, slong len) noexcept
    void fmpz_poly_factor_clear(fmpz_poly_factor_t fac) noexcept
    void fmpz_poly_factor_set(fmpz_poly_factor_t res, const fmpz_poly_factor_t fac) noexcept
    void fmpz_poly_factor_insert(fmpz_poly_factor_t fac, const fmpz_poly_t p, slong e) noexcept
    void fmpz_poly_factor_concat(fmpz_poly_factor_t res, const fmpz_poly_factor_t fac) noexcept
    void fmpz_poly_factor_print(const fmpz_poly_factor_t fac) noexcept
    void fmpz_poly_factor_squarefree(fmpz_poly_factor_t fac, const fmpz_poly_t F) noexcept
    void fmpz_poly_factor_zassenhaus_recombination(fmpz_poly_factor_t final_fac, const fmpz_poly_factor_t lifted_fac, const fmpz_poly_t F, const fmpz_t P, slong exp) noexcept
    void _fmpz_poly_factor_zassenhaus(fmpz_poly_factor_t final_fac, slong exp, const fmpz_poly_t f, slong cutoff, int use_van_hoeij) noexcept
    void fmpz_poly_factor_zassenhaus(fmpz_poly_factor_t final_fac, const fmpz_poly_t F) noexcept
    void _fmpz_poly_factor_quadratic(fmpz_poly_factor_t fac, const fmpz_poly_t f, slong exp) noexcept
    void _fmpz_poly_factor_cubic(fmpz_poly_factor_t fac, const fmpz_poly_t f, slong exp) noexcept
    void fmpz_poly_factor(fmpz_poly_factor_t final_fac, const fmpz_poly_t F) noexcept
