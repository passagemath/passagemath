# sage_setup: distribution = sagemath-modules

from sage.rings.polynomial.all__sagemath_categories import *

from sage.misc.lazy_import import lazy_import

# Ore Polynomial Rings
lazy_import('sage.rings.polynomial.ore_polynomial_ring', 'OrePolynomialRing')
SkewPolynomialRing = OrePolynomialRing
del lazy_import
