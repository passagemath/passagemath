#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup('sagemath-symbolics',
           recurse_packages=('sage', 'passagemath_symbolics'),
           required_modules=('flint', 'gsl', 'factory'),
           spkgs=['flint', 'gsl', 'singular'],
           package_data={
               "sage": [
                   "ext_data/*",
                   "ext_data/magma/*",
                   "ext_data/magma/latex/*",
                   "ext_data/magma/sage/*",
               ],
            })
