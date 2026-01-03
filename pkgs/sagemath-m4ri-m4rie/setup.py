#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-m4ri-m4rie'],
           recurse_packages=('sage', 'passagemath_m4ri_m4rie'),
           required_modules=('m4ri', 'gdlib', 'libpng', 'zlib'),
           spkgs=['m4ri', 'm4rie', 'libgd'],
           package_data={})
