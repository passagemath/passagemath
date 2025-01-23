"""
Flat surfaces

Some code about flat surfaces and interval exchanges has been removed
from Sage. The package ``surface_dynamics`` contains all that code
and much more. For more information, see

    https://www.labri.fr/perso/vdelecro/surface-dynamics/latest/

You can install the ``surface_dynamics`` package via:

    sage -pip install surface_dynamics

If you do not have write access to the Sage installation you can
alternatively do:

    sage -pip install surface_dynamics --user
"""
# install the docstring of this module to the containing package
from sage.misc.namespace_package import install_doc
install_doc(__package__, __doc__)

from sage.dynamics.all__sagemath_combinat import *
from sage.dynamics.all__sagemath_schemes import *

try:
    from sage.dynamics.all__sagemath_symbolics import *
except ImportError:
    pass

del install_doc
