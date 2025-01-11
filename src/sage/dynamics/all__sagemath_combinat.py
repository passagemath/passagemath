# sage_setup: distribution = sagemath-combinat

from sage.misc.lazy_import import lazy_import

from sage.dynamics.cellular_automata.all import *

# Discrete dynamical systems
lazy_import('sage.dynamics.finite_dynamical_system',
            ['DiscreteDynamicalSystem'])

lazy_import('sage.dynamics', 'finite_dynamical_system_catalog',
            'finite_dynamical_systems')

del lazy_import
