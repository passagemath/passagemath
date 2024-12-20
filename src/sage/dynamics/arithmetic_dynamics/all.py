# sage_setup: distribution = sagemath-schemes
from sage.misc.lazy_import import lazy_import

from sage.dynamics.arithmetic_dynamics.generic_ds import DynamicalSystem
from sage.dynamics.arithmetic_dynamics.affine_ds import DynamicalSystem_affine
from sage.dynamics.arithmetic_dynamics.projective_ds import DynamicalSystem_projective
from sage.dynamics.arithmetic_dynamics.product_projective_ds import DynamicalSystem_product_projective
from sage.dynamics.arithmetic_dynamics.berkovich_ds import DynamicalSystem_Berkovich
from sage.dynamics.arithmetic_dynamics.dynamical_semigroup import DynamicalSemigroup
from sage.dynamics.arithmetic_dynamics.dynamical_semigroup import DynamicalSemigroup_affine
from sage.dynamics.arithmetic_dynamics.dynamical_semigroup import DynamicalSemigroup_projective
lazy_import('sage.dynamics.arithmetic_dynamics.wehlerK3', 'WehlerK3Surface')
lazy_import('sage.dynamics.arithmetic_dynamics.wehlerK3', 'random_WehlerK3Surface')
del lazy_import
