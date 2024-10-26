#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(
    ['sagemath-objects'],
    spkgs=['gmp', 'mpc', 'mpfr'],
    package_data={
        "sage.cpython": [
            "pycore_long.h",
            "pyx_visit.h",
            "string_impl.h",
            "cython_metaclass.h",
            "python_debug.h",
        ],
        "sage.ext": [
            "ccobject.h",
            "mod_int.h",
        ],
        "sage.rings": [
            "integer_fake.h",
        ]
    }
)
