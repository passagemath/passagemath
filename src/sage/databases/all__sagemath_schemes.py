# sage_setup: distribution = sagemath-schemes

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.cremona', 'CremonaDatabase')

from sage.databases.db_modular_polynomials import \
    ClassicalModularPolynomialDatabase, \
    DedekindEtaModularPolynomialDatabase, \
    DedekindEtaModularCorrespondenceDatabase, \
    AtkinModularPolynomialDatabase, \
    AtkinModularCorrespondenceDatabase

lazy_import('sage.databases.stein_watkins',
            ['SteinWatkinsAllData', 'SteinWatkinsPrimeData'])

del lazy_import
