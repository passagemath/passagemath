# sage_setup: distribution = sagemath-database-symbolic-data

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.symbolic_data', 'SymbolicData')

del lazy_import
