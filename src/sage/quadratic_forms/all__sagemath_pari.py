# sage_setup: distribution = sagemath-pari
<<<<<<< HEAD

from sage.quadratic_forms.bqf_class_group import BQFClassGroup
||||||| merged common ancestors
from sage.quadratic_forms.bqf_class_group import BQFClassGroup
=======
>>>>>>> main

from sage.quadratic_forms.special_values import (gamma__exact, zeta__exact, QuadraticBernoulliNumber,
                                                 quadratic_L_function__exact, quadratic_L_function__numerical)

from sage.misc.lazy_import import lazy_import

lazy_import('sage.quadratic_forms.genera.genus', 'Genus')

del lazy_import
