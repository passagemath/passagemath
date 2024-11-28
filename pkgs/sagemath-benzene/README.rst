===============================================================================
passagemath: Generate fusene and benzenoid graphs with benzene
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

This pip-installable distribution ``passagemath-benzene`` provides an interface
to benzene, a program for the efficient generation of all nonisomorphic
fusenes and benzenoids with a given number of faces.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of the benzene executable.


Examples
--------

Using the benzene program on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-benzene[test]" sage -sh -c benzene

Finding the installation location of the benzene program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-benzene[test]" ipython

    In [1]: from sage.features.graph_generators import Benzene

    In [2]: Benzene().absolute_filename()
    Out[2]: '.../bin/benzene'

Using the Python interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-benzene[test]" ipython

    In [1]: from sage.all__sagemath_benzene import *

    In [2]: len(list(graphs.fusenes(9, benzenoids=True)))
    Out[2]: 6505
