# sage_setup: distribution = sagemath-lcalc

from sage.misc.lazy_import import lazy_import

lazy_import("sage.lfunctions.lcalc", "lcalc")

del lazy_import
