# sage_setup: distribution = sagemath-gap

from sage.groups.perm_gps.all import *
from sage.groups.abelian_gps.all__sagemath_gap import *

from sage.misc.lazy_import import lazy_import

lazy_import('sage.groups.class_function', 'ClassFunction')
lazy_import('sage.groups.conjugacy_classes', ['ConjugacyClass', 'ConjugacyClassGAP'])

del lazy_import
