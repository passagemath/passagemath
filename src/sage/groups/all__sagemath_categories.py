# sage_setup: distribution = sagemath-categories
from sage.groups.all__sagemath_objects import *

from sage.groups.generic import (discrete_log, discrete_log_rho, discrete_log_lambda,
                                 linear_relation, multiple, multiples)

from sage.misc.lazy_import import lazy_import

lazy_import('sage.groups', 'groups_catalog', 'groups')

del lazy_import