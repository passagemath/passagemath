#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-glpk'],
<<<<<<< HEAD
           spkgs=['glpk'])
=======
           required_modules=('zlib',),
           spkgs=['glpk'],
           package_data={})
>>>>>>> 8994de58fea (pkgs/*/setup.py: Set package_data to ensure that pyx files are shipped in wheels)
