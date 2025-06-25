# sage_setup: distribution = sagemath-eclib
# delvewheel: patch

try:
    from sage.all__sagemath_repl import *
except ImportError:
    pass

from sage.all__sagemath_modules import *
from sage.all__sagemath_linbox import *

try:
    from sage.all__sagemath_schemes import *
except ImportError:
    pass

from sage.libs.all__sagemath_eclib import *
