# sage_setup: distribution = sagemath-flint
from .types cimport *

cdef fmpz_factor_to_pairlist(const fmpz_factor_t factors)
