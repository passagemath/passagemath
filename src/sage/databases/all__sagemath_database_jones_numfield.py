# sage_setup: distribution = sagemath-database-jones-numfield
from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.jones', 'JonesDatabase')

del lazy_import
