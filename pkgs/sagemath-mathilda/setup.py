#!/usr/bin/env python

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))


kernelpath = os.path.join("share", "jupyter", "kernels", "mathilda")


from sage_setup import sage_setup


sage_setup(['sagemath-mathilda'],
           recurse_packages=('sage', 'passagemath_mathilda'),
           spkgs=['mathilda'],
           package_data={
           },
           data_files=[
               (kernelpath, ['kernel.json'])
           ],
           py_limited_api=True,
)
