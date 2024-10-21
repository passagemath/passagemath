#!/usr/bin/env python

<<<<<<< HEAD
from sage_setup import sage_setup

sage_setup(['sagemath-singular'],
           required_modules=('Singular',
                             # from sagemath-linbox
                             'fflas-ffpack', 'givaro', 'gsl', 'linbox', 'cblas',
                             'm4ri', 'gdlib', 'libpng', 'zlib'))
||||||| merged common ancestors
=======
# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-singular'],
           required_modules=('Singular',
                             # from sagemath-linbox
                             'fflas-ffpack', 'givaro', 'gsl', 'linbox', 'cblas',
                             'm4ri', 'gdlib', 'libpng', 'zlib'),
           package_data={"sage": [
               "ext_data/singular/**",
           ]})
>>>>>>> main
