"""
all.py -- much of sage is imported into this module, so you don't
          have to import everything individually.

TESTS:

This is to test :issue:`10570`. If the number of stackframes at startup
changes due to a patch you made, please check that this was an
intended effect of your patch.

::

    sage: import gc
    sage: import inspect
    sage: from sage import *
    sage: frames = [x for x in gc.get_objects() if inspect.isframe(x)]

We exclude the dependencies and check to see that there are no others
except for the known bad apples::

    sage: allowed = [
    ....:     'IPython', 'prompt_toolkit', 'jedi',     # sage dependencies
    ....:     'threading', 'multiprocessing',  # doctest dependencies
    ....:     'pytz', 'importlib.resources',   # doctest dependencies
    ....:     '__main__', 'sage.doctest',      # doctesting
    ....:     'signal', 'enum', 'types'        # may appear in Python 3
    ....: ]
    sage: def is_not_allowed(frame):
    ....:     module = inspect.getmodule(frame)
    ....:     if module is None: return False
    ....:     return not any(module.__name__.startswith(name)
    ....:                    for name in allowed)
    sage: [inspect.getmodule(f).__name__ for f in frames if is_not_allowed(f)]
    []

Check lazy import of ``interacts``::

    sage: type(interacts)
    <class 'sage.misc.lazy_import.LazyImport'>
    sage: interacts
    <module 'sage.interacts.all' from '...'>

Check that :issue:`34506` is resolved::

    sage: x = int('1'*4301)
"""
# ****************************************************************************
#       Copyright (C) 2005-2012 William Stein <wstein@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

import sage.misc.lazy_import

sage.misc.lazy_import.commence_startup()

import os
import operator
import math
import sys

# Set up warning filters before importing Sage stuff
import warnings

# This is a Python debug build (--with-pydebug)
__with_pydebug = hasattr(sys, 'gettotalrefcount')
if __with_pydebug:
    # a debug build does not install the default warning filters. Sadly, this breaks doctests so we
    # have to re-add them:
    warnings.filterwarnings('ignore', category=PendingDeprecationWarning)
    warnings.filterwarnings('ignore', category=ImportWarning)
    warnings.filterwarnings('ignore', category=ResourceWarning)
else:
    deprecationWarning = ('ignore', None, DeprecationWarning, None, 0)
    if deprecationWarning in warnings.filters:
        warnings.filters.remove(deprecationWarning)

# Ignore all deprecations from IPython etc.
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        module='(IPython|ipykernel|jupyter_client|jupyter_core|nbformat|notebook|ipywidgets|storemagic|jedi)')

# scipy 1.18 introduced deprecation warnings on a number of things they are moving to
# numpy, e.g. DeprecationWarning: scipy.array is deprecated
#             and will be removed in SciPy 2.0.0, use numpy.array instead
# This affects networkx 2.2 up and including 2.4 (cf. :issue:29766)
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        module='(scipy|networkx)')

# However, be sure to keep OUR deprecation warnings
warnings.filterwarnings('default', category=DeprecationWarning,
                        message=r'[\s\S]*See https?://trac\.sagemath\.org/[0-9]* for details.')

# Ignore packaging 20.5 deprecation warnings
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        module='(.*[.]_vendor[.])?packaging')

# Ignore a few warnings triggered by pythran 0.12.1
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message='\n\n  `numpy.distutils` is deprecated since NumPy 1.23.0',
                        module='pythran.dist')
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message='pkg_resources is deprecated as an API|'
                        'Deprecated call to `pkg_resources.declare_namespace(.*)`',
                        module='pkg_resources|setuptools.sandbox')
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message='msvccompiler is deprecated and slated to be removed',
                        module='distutils.msvccompiler')

warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message='The distutils(.sysconfig module| package) is deprecated',
                        module='Cython|distutils|numpy|sage.env|sage.features')

# triggered by pyparsing 2.4.7
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message="module 'sre_constants' is deprecated",
                        module='pyparsing')

# triggered by mpmath on Python 3.14
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message='bitcount function is deprecated',
                        module='mpmath\\.libmp\\.libintmath')

# importlib.resources.path and ...read_binary are deprecated in python 3.11,
# but the replacement importlib.resources.files needs python 3.9
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message=r'(path|read_binary) is deprecated\. Use files\(\) instead\.',
                        module='sage.repl.rich_output.output_(graphics|graphics3d|video)')

# triggered by sphinx
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message="'imghdr' is deprecated and slated for removal in Python 3.13",
                        module='sphinx.util.images')

# triggered by docutils 0.19 on Python 3.11
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message=r"Use setlocale\(\), getencoding\(\) and getlocale\(\) instead",
                        module='docutils.io')

# triggered by dateutil 2.8.2 and sphinx 7.0.1 on Python 3.12
# see: https://github.com/dateutil/dateutil/pull/1285
# see: https://github.com/sphinx-doc/sphinx/pull/11468
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message=r"datetime.datetime.utcfromtimestamp\(\) is deprecated",
                        module='dateutil.tz.tz|sphinx.(builders.gettext|util.i18n)')

# triggered on Python 3.12
warnings.filterwarnings('ignore', category=DeprecationWarning,
                        message=r"This process.* is multi-threaded, "
                                r"use of .*\(\) may lead to deadlocks in the child.")

# rpy2>=3.6 emits warnings for R modifying LD_LIBRARY_PATH
warnings.filterwarnings('ignore', category=UserWarning,
                        message=r".*redefined by R and overriding existing variable.*",
                        module='rpy2.*')

# ############### end setup warnings ###############################

# includes .all__sagemath_objects, .all__sagemath_environment
from sage.all__sagemath_repl import *
from sage.all__sagemath_modules import *

from time import sleep
from functools import reduce  # in order to keep reduce in python3

# ##################################################################

from sage.misc.all import *         # takes a while

from sage.libs.all import *
from sage.data_structures.all import *

from sage.rings.all import *

from sage.algebras.all import *

from sage.all__sagemath_schemes import *
from sage.all__sagemath_combinat import *
from sage.all__sagemath_graphs import *
from sage.all__sagemath_groups import *
from sage.all__sagemath_polyhedra import *

from sage.databases.all import *
from sage.sets.all import *
from sage.interfaces.all import *


from sage.combinat.all import *

from sage.geometry.all import *
from sage.geometry.triangulation.all import *

from sage.dynamics.all import *

from sage.homology.all import *

from sage.quadratic_forms.all import *

from sage.logic.all import *

from sage.numerical.all import *

# Lazily import interacts (#15335)
lazy_import('sage.interacts', 'all', 'interacts')

try:
    from .all__sagemath_plot import *
except ImportError:
    pass

try:
    from .all__sagemath_symbolics import *
except ImportError:
    pass

from sage.combinat.all import Posets  # so that sage.combinat.all.Posets wins over sage.categories.all.Posets


###########################################################
#    WARNING:
# DO *not* import numpy / matplotlib / networkx here!!
# Each takes a surprisingly long time to initialize,
# and that initialization should be done more on-the-fly
# when they are first needed.
###########################################################

from sage.misc.copying import license
copying = license
copyright = license

from sage.misc.persist import register_unpickle_override
register_unpickle_override('sage.categories.category', 'Sets', Sets)
register_unpickle_override('sage.categories.category_types', 'HeckeModules',
                           HeckeModules)
register_unpickle_override('sage.categories.category_types', 'Objects',
                           Objects)
register_unpickle_override('sage.categories.category_types', 'Rings',
                           Rings)
register_unpickle_override('sage.categories.category_types', 'Fields',
                           Fields)
register_unpickle_override('sage.categories.category_types', 'VectorSpaces',
                           VectorSpaces)
register_unpickle_override('sage.categories.category_types',
                           'Schemes_over_base',
                           sage.categories.schemes.Schemes_over_base)
register_unpickle_override('sage.categories.category_types',
                           'ModularAbelianVarieties',
                           ModularAbelianVarieties)
register_unpickle_override('sage.libs.pari.gen_py', 'pari', pari)

# Cache the contents of star imports.
sage.misc.lazy_import.save_cache_file()


# ##### Debugging for Singular, see issue #10903
# from sage.libs.singular.ring import poison_currRing
# sys.settrace(poison_currRing)


# Set a new random number seed as the very last thing
# (so that printing initial_seed() and using that seed
# in set_random_seed() will result in the same sequence you got at
# Sage startup).
set_random_seed()


# Relink imported lazy_import objects to point to the appropriate namespace

from sage.misc.lazy_import import clean_namespace
clean_namespace()
del clean_namespace

# From now on it is ok to resolve lazy imports
sage.misc.lazy_import.finish_startup()


# Python broke large ints; see trac #34506

if hasattr(sys, "set_int_max_str_digits"):
    sys.set_int_max_str_digits(0)


def sage_globals():
    r"""
    Return the Sage namespace.

    EXAMPLES::

        sage: 'log' in sage_globals()
        True
        sage: 'MatrixSpace' in sage_globals()
        True
        sage: 'Permutations' in sage_globals()
        True
        sage: 'TheWholeUniverse' in sage_globals()
        False
    """
    return globals()
