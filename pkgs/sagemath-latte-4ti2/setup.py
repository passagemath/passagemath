#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup

sage_setup(['sagemath-latte-4ti2'],
           spkgs=['latte_int', '4ti2'])
