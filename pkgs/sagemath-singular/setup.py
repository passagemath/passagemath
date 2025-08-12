#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from setuptools import Extension

from sage_setup import sage_setup
from sage.env import cython_aliases

if not (len(sys.argv) > 1 and (sys.argv[1] in ["sdist", "egg_info", "dist_info"])):
    aliases = cython_aliases(required_modules=('Singular',), optional_modules=())
    ext_modules = [Extension("PySingular", ["PySingular.cpp"],
                             extra_compile_args=aliases['SINGULAR_CFLAGS'],
                             include_dirs=aliases['SINGULAR_INCDIR'],
                             libraries=aliases['SINGULAR_LIBRARIES'],
                             library_dirs=aliases['SINGULAR_LIBDIR'],
                             extra_link_args=aliases['SINGULAR_LIBEXTRA'])]
else:
    ext_modules = []

sage_setup(['sagemath-singular'],
           required_modules=('Singular', 'factory',
                             # from sagemath-linbox
                             'fflas-ffpack', 'givaro', 'gsl', 'linbox', 'cblas',
                             'm4ri', 'gdlib', 'libpng', 'zlib'),
           spkgs=['singular'],
           package_data={"sage": [
               "ext_data/singular/**",
           ]},
           ext_modules=ext_modules)
