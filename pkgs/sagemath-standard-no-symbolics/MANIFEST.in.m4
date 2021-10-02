dnl MANIFEST.in is generated from this file by SAGE_ROOT/bootstrap via m4.

dnl Include all from sagemath-categories (via m4 include)
include(`../sagelib/src/MANIFEST.in')

exclude *.m4
include requirements.txt

prune sage/symbolic
prune sage/functions
prune sage/calculus
prune sage/manifolds
prune sage/geometry/riemannian_manifolds
prune sage/geometry/hyperbolic_space
prune sage/dynamics/complex_dynamics

exclude sage/modules/vector_*symbol*.*
exclude sage/matrix/matrix_symbolic_*.*

prune sage/libs/pynac
exclude sage/libs/ecl.p*

exclude sage/interfaces/maxima*.p*
