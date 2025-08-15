# sage_setup: distribution = sagemath-database-kohel

from sage.databases.db_class_polynomials import \
    HilbertClassPolynomialDatabase

from sage.databases.db_modular_polynomials import \
    ClassicalModularPolynomialDatabase, \
    DedekindEtaModularPolynomialDatabase, \
    DedekindEtaModularCorrespondenceDatabase, \
    AtkinModularPolynomialDatabase, \
    AtkinModularCorrespondenceDatabase
