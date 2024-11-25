# sage_setup: distribution = sagemath-rubiks

from sage.all__sagemath_categories import *

try:
    from sage.all__sagemath_groups import *
except ImportError:
    pass
