# sage_setup: distribution = sagemath-modules
from .binary_qf import BinaryQF, BinaryQF_reduced_representatives

from .ternary_qf import TernaryQF, find_all_ternary_qf_by_level_disc, find_a_ternary_qf_by_level_disc

from .quadratic_form import QuadraticForm, DiagonalQuadraticForm, quadratic_form_from_invariants

from .random_quadraticform import (random_quadraticform, random_quadraticform_with_conditions,
                                   random_ternaryqf, random_ternaryqf_with_conditions)

from .extras import least_quadratic_nonresidue, extend_to_primitive, is_triangular_number

from .constructions import BezoutianQuadraticForm, HyperbolicPlane_quadratic_form