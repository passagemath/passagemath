# from sage.misc.all__sagemath_objects import *
from sage.misc.all__sagemath_environment import *
from sage.misc.all__sagemath_modules import *
from sage.misc.all__sagemath_repl import *

from sage.misc.misc import (BackslashOperator,
                            exists, forall, is_iterator,
                            random_sublist,
                            pad_zeros,
                            SAGE_DB,
                            newton_method_sizes, compose,
                            nest)

<<<<<<< HEAD
||||||| merged common ancestors
<<<<<<<<< Temporary merge branch 1
from sage.misc.dev_tools import import_statements

from sage.misc.edit_module import edit

||||||||| ab24dac430e
                  exists, forall, is_iterator,
                  random_sublist,
                  pad_zeros,
                  SAGE_DB,
                   newton_method_sizes, compose,
                  nest)

from sage.misc.banner import version

from sage.misc.dev_tools import import_statements

from sage.misc.html import html, pretty_print_default

from sage.misc.table import table

from sage.misc.sage_timeit_class import timeit

from sage.misc.edit_module import edit

from sage.misc.map_threaded import map_threaded

from sage.misc.session import load_session, save_session, show_identifiers

=========
>>>>>>>>> Temporary merge branch 2
=======
from sage.misc.dev_tools import import_statements

from sage.misc.edit_module import edit

>>>>>>> main
from sage.misc.remote_file import get_remote_file

lazy_import('sage.misc.pager', 'pager')

from sage.misc.classgraph import class_graph

lazy_import("sage.misc.cython", "cython_lambda")
lazy_import("sage.misc.cython", "cython_compile", "cython")

<<<<<<< HEAD
||||||| merged common ancestors
<<<<<<<<< Temporary merge branch 1
# Following will go to all__sagemath_repl.py in #36566
from sage.misc.explain_pickle import (explain_pickle, unpickle_newobj, unpickle_build,
                                      unpickle_instantiate, unpickle_persistent,
                                      unpickle_extension, unpickle_appends)

lazy_import('sage.misc.inline_fortran', 'fortran')

lazy_import('sage.misc.banner', 'banner', deprecation=34259)
lazy_import('sage.misc.dev_tools', 'runsnake', deprecation=34259)
lazy_import('sage.misc.edit_module', 'set_edit_template', deprecation=34259)
lazy_import('sage.misc.profiler', 'Profiler', deprecation=34259)
lazy_import('sage.misc.trace', 'trace', deprecation=34259)
lazy_import('sage.misc.package', ('installed_packages', 'is_package_installed',
                                  'package_versions'),
            deprecation=34259)
lazy_import('sage.misc.benchmark', 'benchmark', deprecation=34259)
||||||||| ab24dac430e
from sage.misc.func_persist import func_persist

from sage.misc.functional import (additive_order,
                        base_ring,
                        base_field,
                        basis,
                        category,
                        charpoly,
                        characteristic_polynomial,
                        coerce,
                        cyclotomic_polynomial,
                        decomposition,
                        denominator,
                        det,
                        dimension,
                        dim,
                        discriminant,
                        disc,
                        eta,
                        fcp,
                        gen,
                        gens,
                        hecke_operator,
                        image,
                        integral, integrate,
                        integral_closure,
                        interval,
                        xinterval,
                        is_even,
                        is_odd,
                        kernel,
                        krull_dimension,
                        lift,
                        log as log_b,
                        minimal_polynomial,
                        minpoly,
                        multiplicative_order,
                        ngens,
                        norm,
                        numerator,
                        numerical_approx,
                        n, N,
                        objgens,
                        objgen,
                        order,
                        rank,
                        regulator,
                        round,
                        quotient,
                        quo,
                        isqrt,
                        squarefree_part,
                        sqrt,
                        symbolic_sum as sum,
                        symbolic_prod as product,
                        transpose)


from sage.misc.latex import LatexExpr, latex, view

from sage.misc.randstate import seed, set_random_seed, initial_seed, current_randstate

from sage.misc.prandom import *

from sage.misc.timing import walltime, cputime

from sage.misc.explain_pickle import explain_pickle, unpickle_newobj, unpickle_global, unpickle_build, unpickle_instantiate, unpickle_persistent, unpickle_extension, unpickle_appends

lazy_import('sage.misc.inline_fortran', 'fortran')

lazy_import('sage.misc.banner', 'banner', deprecation=34259)
lazy_import('sage.misc.dev_tools', 'runsnake', deprecation=34259)
lazy_import('sage.misc.edit_module', 'set_edit_template', deprecation=34259)
lazy_import('sage.misc.profiler', 'Profiler', deprecation=34259)
lazy_import('sage.misc.trace', 'trace', deprecation=34259)
lazy_import('sage.misc.package', ('installed_packages', 'is_package_installed',
                                  'package_versions'),
            deprecation=34259)
lazy_import('sage.misc.benchmark', 'benchmark', deprecation=34259)
=========
from sage.misc.func_persist import func_persist

>>>>>>>>> Temporary merge branch 2
=======
# Following will go to all__sagemath_repl.py in #36566
from sage.misc.explain_pickle import (explain_pickle, unpickle_newobj, unpickle_build,
                                      unpickle_instantiate, unpickle_persistent,
                                      unpickle_extension, unpickle_appends)

lazy_import('sage.misc.inline_fortran', 'fortran')

lazy_import('sage.misc.banner', 'banner', deprecation=34259)
lazy_import('sage.misc.dev_tools', 'runsnake', deprecation=34259)
lazy_import('sage.misc.edit_module', 'set_edit_template', deprecation=34259)
lazy_import('sage.misc.profiler', 'Profiler', deprecation=34259)
lazy_import('sage.misc.trace', 'trace', deprecation=34259)
lazy_import('sage.misc.package', ('installed_packages', 'is_package_installed',
                                  'package_versions'),
            deprecation=34259)
lazy_import('sage.misc.benchmark', 'benchmark', deprecation=34259)
>>>>>>> main
lazy_import('sage.repl.interpreter', 'logstr', deprecation=34259)
