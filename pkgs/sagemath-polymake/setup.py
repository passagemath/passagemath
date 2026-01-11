#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from setuptools import Extension

from sage_setup import sage_setup
from sage.env import cython_aliases

if not (len(sys.argv) > 1 and (sys.argv[1] in ["sdist", "egg_info", "dist_info"])):
    aliases = cython_aliases(required_modules=('polymake',), optional_modules=())
    ext_modules = [Extension("JuPyMake", ["JuPyMake.cpp"],
                             extra_compile_args=aliases['POLYMAKE_CFLAGS'],
                             include_dirs=aliases['POLYMAKE_INCDIR'],
                             libraries=aliases['POLYMAKE_LIBRARIES'],
                             library_dirs=aliases['POLYMAKE_LIBDIR'],
                             extra_link_args=aliases['POLYMAKE_LIBEXTRA'])]
else:
    ext_modules = []

sage_setup(['sagemath-polymake'],
           recurse_packages=('sage', 'passagemath_polymake'),
           spkgs=['polymake'],
           ext_modules=ext_modules)
