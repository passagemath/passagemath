===============================================================================
passagemath: Generation of nonisomorphic fullerenes with buckygen
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

This pip-installable distribution ``passagemath-buckygen`` provides an interface
to `buckygen <http://caagt.ugent.be/buckygen/>`_, a program for the efficient
generation of all nonisomorphic fullerenes.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of buckygen.


Examples
--------

Using the buckygen program on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-buckygen[test]" sage -sh -c buckygen

Finding the installation location of the buckygen program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-buckygen[test]" ipython

    In [1]: from sage.features.graph_generators import Buckygen

    In [2]: Buckygen().absolute_filename()
    Out[2]: '.../bin/buckygen'

Using the Python interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-buckygen[test]" ipython

    In [1]: from sage.all__sagemath_buckygen import *

    In [2]: len(list(graphs.fullerenes(60)))
    Out[2]: 1812

    In [3]: gen = graphs.fullerenes(60, ipr=True); next(gen)
    Out[3]: Graph on 60 vertices
