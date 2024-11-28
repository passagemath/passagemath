===============================================================================
passagemath: Generating planar graphs with plantri and fullgen
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

This pip-installable distribution ``passagemath-plantri`` provides an interface
to `plantri <https://users.cecs.anu.edu.au/~bdm/plantri/>`_.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of plantri executables.


Examples
--------

Using plantri programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-plantri" sage -sh -c plantri


Finding the installation location of a plantri program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-plantri[test]" ipython

    In [1]: from sage.features.graph_generators import Plantri

    In [2]: Plantri().absolute_filename()
    Out[2]: '.../bin/plantri'


Using the Python interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-plantri[test]" ipython

    In [1]: from sage.all__sagemath_plantri import *

    In [2]: len(list(graphs.planar_graphs(4, minimum_edges=4)))
    Out[2]: 4

    In [3]: gen = graphs.triangulations(6, only_eulerian=True); g = next(gen)

    In [4]: g.is_isomorphic(graphs.OctahedralGraph())
    Out[4]: True
