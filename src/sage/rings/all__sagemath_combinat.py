# sage_setup: distribution = sagemath-combinat
from sage.rings.all__sagemath_categories import *

from sage.misc.lazy_import import lazy_import

# Lazy combinatorial species
lazy_import('sage.rings.lazy_species', 'LazyCombinatorialSpecies')

del lazy_import
