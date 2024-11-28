===============================================================================
passagemath: Finding cliques in graphs with cliquer
===============================================================================

About SageMath
--------------

   "Creating a Viable Open Source Alternative to
    Magma, Maple, Mathematica, and MATLAB"

   Copyright (C) 2005-2024 The Sage Development Team

   https://www.sagemath.org

SageMath fully supports all major Linux distributions, recent versions of
macOS, and Windows (Windows Subsystem for Linux).

See https://doc.sagemath.org/html/en/installation/index.html
for general installation instructions.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-cliquer`` provides an interface
to `cliquer <https://users.aalto.fi/~pat/cliquer.html>`_, an exact branch-and-bound
algorithm for finding cliques in an arbitrary weighted graph by Patric Östergård.


What is included
----------------

* `Cython interface to cliquer <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/cliquer.html>`_


Examples
--------

::

   $ pipx run --pip-args="--prefer-binary" --spec "passagemath-cliquer[test]" ipython

   In [1]: from sage.all__sagemath_cliquer import *

   In [2]: from sage.graphs.cliquer import max_clique

   In [3]: C = graphs.PetersenGraph(); max_clique(C)
   Out[3]: [7, 9]
