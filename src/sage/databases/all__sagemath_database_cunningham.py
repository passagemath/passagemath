# sage_setup: distribution = sagemath-database-cunningham

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.cunningham_tables', 'cunningham_prime_factors')

del lazy_import
