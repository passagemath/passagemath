#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(
    ['sagemath-categories'],
    interpreters=['Element', 'Python'],  # RDF uses gsl --> sagemath-modules
    package_data={
        "sage.data_structures": [
            "bitset_intrinsics.h",
            "pairing_heap.h",
        ],
        "sage.rings.finite_rings": [
            "integer_mod_limits.h",
        ],
    })
