# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/flint.h

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
    mp_limb_t FLINT_BIT_COUNT(mp_limb_t x) noexcept
    void * flint_malloc(size_t size) noexcept
    void * flint_realloc(void * ptr, size_t size) noexcept
    void * flint_calloc(size_t num, size_t size) noexcept
    void flint_free(void * ptr) noexcept
    flint_rand_s * flint_rand_alloc() noexcept
    void flint_rand_free(flint_rand_s * state) noexcept
    void flint_randinit(flint_rand_t state) noexcept
    void flint_randclear(flint_rand_t state) noexcept
    void flint_set_num_threads(int num_threads) noexcept
    int flint_get_num_threads() noexcept
    int flint_set_num_workers(int num_workers) noexcept
    void flint_reset_num_workers(int num_workers) noexcept
    int flint_printf(const char * str, ...) noexcept
    int flint_fprintf(FILE * f, const char * str, ...) noexcept
    int flint_sprintf(char * s, const char * str, ...) noexcept
    int flint_scanf(const char * str, ...) noexcept
    int flint_fscanf(FILE * f, const char * str, ...) noexcept
    int flint_sscanf(const char * s, const char * str, ...) noexcept
