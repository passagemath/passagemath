# sage_setup: distribution = sagemath-categories
from .all__sagemath_objects import *

from .generic import (discrete_log, discrete_log_rho, discrete_log_lambda,
                      linear_relation, multiple, multiples)

from sage.misc.lazy_import import lazy_import

lazy_import('sage.groups', 'groups_catalog', 'groups')

del lazy_import