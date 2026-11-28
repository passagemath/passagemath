# sage_setup: distribution = sagemath-categories

from sage.misc.lazy_import import lazy_import

from sage.databases.sql_db import SQLQuery, SQLDatabase

lazy_import('sage.databases.conway', 'ConwayPolynomials')

del lazy_import
