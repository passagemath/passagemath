================================================================================================================
 passagemath: Computer algebra, algebraic geometry, singularity theory with Singular
================================================================================================================

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

This pip-installable source distribution ``passagemath-singular`` is a
distribution that provides modules that depend on Singular.


What is included
----------------

- The binary wheels published on PyPI include a prebuilt copy of Singular.


Examples
--------

Using Singular on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-singular" sage -singular



