# sage_setup: distribution = sagemath-giac
# delvewheel: patch

from sage.all__sagemath_categories import *

try:
    from sage.all__sagemath_symbolics import *
except ImportError:
    pass

from sage.libs.all__sagemath_giac import *
