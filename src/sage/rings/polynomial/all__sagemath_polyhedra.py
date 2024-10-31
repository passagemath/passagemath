# sage_setup: distribution = sagemath-polyhedra

from sage.rings.polynomial.all__sagemath_modules import *

from sage.misc.lazy_import import lazy_import

# Laurent Polynomial Rings
lazy_import('sage.rings.polynomial.omega', 'MacMahonOmega')

del lazy_import
