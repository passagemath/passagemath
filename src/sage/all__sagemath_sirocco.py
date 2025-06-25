# sage_setup: distribution = sagemath-sirocco
# delvewheel: patch

try:
    from sage.all__sagemath_schemes import *
except ImportError:
    pass

from sage.all__sagemath_modules import *
