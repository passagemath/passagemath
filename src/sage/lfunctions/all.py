# sage_setup: distribution = sagemath-schemes

try:
    from .all__sagemath_lcalc import *
except ImportError:
    pass

try:
    from .all__sagemath_sympow import *
except ImportError:
    pass

from sage.misc.lazy_import import lazy_import

lazy_import("sage.lfunctions.dokchitser", "Dokchitser")
lazy_import("sage.lfunctions.zero_sums", "LFunctionZeroSum")

del lazy_import
