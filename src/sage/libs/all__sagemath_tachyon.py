# sage_setup: distribution = sagemath-tachyon

from sage.misc.lazy_import import lazy_import

lazy_import('sage.interfaces.tachyon', 'tachyon_rt')

del lazy_import
