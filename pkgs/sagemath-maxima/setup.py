#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup('sagemath-maxima',
           required_modules=('gsl', 'Singular', 'ecl'),
           spkgs=['maxima'],
           package_data={
               "sage.interfaces": [
                   "sage-maxima.lisp",
               ],
               "sage": [
                   "ext_data/*",
                   "ext_data/kenzo/*",
                   "ext_data/singular/*",
                   "ext_data/singular/function_field/*",
                   "ext_data/magma/*",
                   "ext_data/magma/latex/*",
                   "ext_data/magma/sage/*",
               ],
            })
