#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-gap3'],
           recurse_packages=('sage', 'passagemath_gap3'),
           required_modules=('zlib',),
           spkgs=['gap3'],
           package_data={})
