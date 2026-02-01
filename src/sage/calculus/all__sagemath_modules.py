# sage_setup: distribution = sagemath-modules
from sage.calculus.all__sagemath_categories import *

from sage.calculus.functions import wronskian, jacobian

# We lazy_import the following modules since they import numpy which slows down sage startup
from sage.misc.lazy_import import lazy_import

lazy_import("sage.calculus.interpolators", ["polygon_spline", "complex_cubic_spline"])

del lazy_import
