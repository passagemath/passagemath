# sage_setup: distribution = sagemath-combinat

from sage.databases.all__sagemath_categories import *

from sage.misc.lazy_import import lazy_import

lazy_import('sage.databases.sloane', 'SloaneEncyclopedia')

lazy_import('sage.databases.oeis', 'oeis')

lazy_import('sage.databases.findstat', ['findstat', 'findmap'])

del lazy_import
