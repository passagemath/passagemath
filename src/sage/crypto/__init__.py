# sage_setup: distribution = sagemath-modules
# delvewheel: patch
from sage.misc.lazy_import import lazy_import
lazy_import('sage.crypto.lattice', 'gen_lattice')
