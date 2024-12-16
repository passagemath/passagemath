# sage_setup: distribution = sagemath-pari

from sage.libs.flint.fmpz_poly cimport fmpz_poly_t
from sage.rings.padics.pow_computer_flint cimport PowComputer_flint_unram
cdef class PowComputer_(PowComputer_flint_unram):
    pass
ctypedef fmpz_poly_t celement

include "FP_template_header.pxi"

cdef class qAdicFloatingPointElement(FPElement):
    pass
