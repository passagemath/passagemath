# sage_setup: distribution = sagemath-sympow

from sage.misc.lazy_import import lazy_import

lazy_import("sage.lfunctions.sympow", "sympow")

del lazy_import
