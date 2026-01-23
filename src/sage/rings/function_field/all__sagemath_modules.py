# sage_setup: distribution = sagemath-modules
from sage.rings.function_field.all__sagemath_categories import *

from sage.misc.lazy_import import lazy_import

lazy_import("sage.rings.function_field.drinfeld_modules.drinfeld_module", "DrinfeldModule")
lazy_import("sage.rings.function_field.drinfeld_modules.carlitz_module", "CarlitzModule")
lazy_import("sage.rings.function_field.drinfeld_modules.carlitz_module", "carlitz_exponential")
lazy_import("sage.rings.function_field.drinfeld_modules.carlitz_module", "carlitz_logarithm")

del lazy_import
