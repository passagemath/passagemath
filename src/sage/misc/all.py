# from sage.misc.all__sagemath_objects import *
from sage.misc.all__sagemath_environment import *
from sage.misc.all__sagemath_modules import *
from sage.misc.all__sagemath_repl import *

from sage.misc.misc import (BackslashOperator,
                            exists, forall, is_iterator,
                            random_sublist,
                            pad_zeros,
                            newton_method_sizes, compose,
                            nest)

lazy_import('sage.misc.banner', 'banner', deprecation=34259)
lazy_import('sage.misc.dev_tools', 'runsnake', deprecation=34259)
lazy_import('sage.misc.edit_module', 'set_edit_template', deprecation=34259)
lazy_import('sage.misc.profiler', 'Profiler', deprecation=34259)
lazy_import('sage.misc.trace', 'trace', deprecation=34259)
lazy_import('sage.misc.package', ('installed_packages', 'is_package_installed',
                                  'package_versions'),
            deprecation=34259)
lazy_import('sage.misc.benchmark', 'benchmark', deprecation=34259)
lazy_import('sage.repl.interpreter', 'logstr', deprecation=34259)

# Following will go to all__sagemath_objects.py in #36566
from sage.misc.randstate import seed, set_random_seed, initial_seed, current_randstate
from sage.misc.prandom import *
from sage.misc.sage_timeit_class import timeit
from sage.misc.session import load_session, save_session, show_identifiers
from sage.misc.reset import reset, restore
