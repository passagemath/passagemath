# sage_setup: distribution = sagemath-pari

from cypari2.gen cimport Gen
from sage.rings.complex_double cimport ComplexDoubleElement

cpdef ComplexDoubleElement pari_to_cdf(Gen g) noexcept

cpdef Gen new_gen_from_complex_double_element(ComplexDoubleElement self) noexcept

cpdef ComplexDoubleElement complex_double_element_eta(ComplexDoubleElement self, int flag) noexcept
cpdef ComplexDoubleElement complex_double_element_agm(ComplexDoubleElement self, right) noexcept
cpdef ComplexDoubleElement complex_double_element_dilog(ComplexDoubleElement self) noexcept
cpdef ComplexDoubleElement complex_double_element_gamma(ComplexDoubleElement self) noexcept
cpdef ComplexDoubleElement complex_double_element_gamma_inc(ComplexDoubleElement self, t) noexcept
cpdef ComplexDoubleElement complex_double_element_zeta(ComplexDoubleElement self) noexcept
