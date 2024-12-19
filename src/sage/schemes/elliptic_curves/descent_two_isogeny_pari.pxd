# sage_setup: distribution = sagemath-flint

from sage.libs.gmp.mpz cimport mpz_t

cdef bint ratpoints_mpz_exists_only(mpz_t *coeffs, long degree, long H) except -1
