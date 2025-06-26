# sage_setup: distribution = sagemath-libbraiding
# delvewheel: patch

from sage.all__sagemath_objects import *

try:
    from sage.all__sagemath_groups import *
except ImportError:
    pass

try:
    from sage.all__sagemath_graphs import *
except ImportError:
    pass

try:
    from sage.all__sagemath_schemes import *
except ImportError:
    pass
