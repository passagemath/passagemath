# sage_setup: distribution = sagemath-pari

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.conway', 'ConwayPolynomials')

del lazy_import
