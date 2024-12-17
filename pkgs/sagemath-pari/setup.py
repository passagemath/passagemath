#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

from autogen import rebuild

rebuild()

sage_setup(['sagemath-pari'],
           required_modules=('gsl',),
           spkgs=['pari', 'gsl'],
           recurse_packages=[
               'sage',
               'cypari2',
            ],
           package_data={"sage": [
               "ext_data/pari/**",
            ],
            'cypari2': [
                'declinl.pxi',
                '*.pxd',
                '*.h'
            ]})
