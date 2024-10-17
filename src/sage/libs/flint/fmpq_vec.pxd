# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/fmpq_vec.h

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
    fmpq * _fmpq_vec_init(slong n) noexcept
    void _fmpq_vec_clear(fmpq * vec, slong n) noexcept
    void _fmpq_vec_randtest(fmpq * f, flint_rand_t state, slong len, flint_bitcnt_t bits) noexcept
    void _fmpq_vec_randtest_uniq_sorted(fmpq * vec, flint_rand_t state, slong len, flint_bitcnt_t bits) noexcept
    void _fmpq_vec_sort(fmpq * vec, slong len) noexcept
    void _fmpq_vec_set_fmpz_vec(fmpq * res, const fmpz * vec, slong len) noexcept
    void _fmpq_vec_get_fmpz_vec_fmpz(fmpz * num, fmpz_t den, const fmpq * a, slong len) noexcept
    void _fmpq_vec_dot(fmpq_t res, const fmpq * vec1, const fmpq * vec2, slong len) noexcept
    int _fmpq_vec_fprint(FILE * file, const fmpq * vec, slong len) noexcept
    int _fmpq_vec_print(const fmpq * vec, slong len) noexcept
