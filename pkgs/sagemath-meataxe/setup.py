#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-meataxe'],
           spkgs=['meataxe'],
           package_data={
               "sage.libs": ["meataxe.pxd"],
               "sage.matrix": ["matrix_gfpn_dense.pxd"],
           })
