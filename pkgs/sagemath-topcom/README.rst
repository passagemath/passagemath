=====================================================================================
passagemath: Triangulations of point configurations and oriented matroids with TOPCOM
=====================================================================================

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

This pip-installable distribution ``passagemath-topcom`` provides an interface to
`TOPCOM <https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM/>`_,
a package for computing triangulations of point configurations and
oriented matroids by Jörg Rambau.


What is included
----------------

- Raw access to all executables from Python using `sage.features.topcom <https://doc.sagemath.org/html/en/reference/spkg/sage/features/topcom.html>`_

- The binary wheels published on PyPI include a prebuilt copy of TOPCOM.


Examples
--------

Using TOPCOM programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-topcom" sage -sh -c 'cube 4 | points2facets'
