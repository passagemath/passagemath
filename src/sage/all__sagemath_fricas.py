# sage_setup: distribution = sagemath-fricas
# delvewheel: patch

from sage.all__sagemath_ecl import *

try:
    # "test" dependency
    from sage.all__sagemath_symbolics import *
except ImportError:
    pass
