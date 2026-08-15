# sage_setup: distribution = sagemath-gap3

from sage.all__sagemath_gap import *


try:
    from sage.all__sagemath_combinat import *
except ImportError:
    pass


try:
    from sage.all__sagemath_modules import *
except ImportError:
    pass
