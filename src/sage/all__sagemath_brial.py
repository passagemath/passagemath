# sage_setup: distribution = sagemath-brial
# delvewheel: patch

from .all__sagemath_categories import *

try:
    from .all__sagemath_modules import *
except ImportError:
    pass
