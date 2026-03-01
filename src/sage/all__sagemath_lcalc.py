# sage_setup: distribution = sagemath-lcalc
# delvewheel: patch

try:
    from sage.all__sagemath_schemes import *
except ImportError:
    pass


from sage.lfunctions.all__sagemath_lcalc import *
from sage.libs.all__sagemath_lcalc import *
