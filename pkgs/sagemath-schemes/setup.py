#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-schemes'],
           recurse_packages=('sage', 'passagemath_schemes'),
           required_modules=('flint',),
           spkgs=['elliptic_curves'],
           package_data={})
