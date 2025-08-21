# sage_setup: distribution = sagemath-database-odlyzko-zeta

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.odlyzko', 'zeta_zeros')

del lazy_import
