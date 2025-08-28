# sage_setup: distribution = sagemath-schemes

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.cremona', 'CremonaDatabase')

del lazy_import
