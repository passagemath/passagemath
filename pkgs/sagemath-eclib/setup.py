#!/usr/bin/env python

<<<<<<< HEAD
||||||| merged common ancestors
=======
# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

>>>>>>> main
from sage_setup import sage_setup

sage_setup(['sagemath-eclib'])
