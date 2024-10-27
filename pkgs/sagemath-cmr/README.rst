==========================================================================
 passagemath: Combinatorial matrix recognition
==========================================================================

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


About this pip-installable source distribution
----------------------------------------------

This pip-installable source distribution ``passagemath-cmr`` is a small
optional distribution for use with ``passagemath-standard``.

It provides a Cython interface to the CMR library (https://github.com/discopt/cmr),
providing recognition and decomposition algorithms for:

- Totally Unimodular Matrices
- Network Matrices
- Complement Totally Unimodular Matrices
- (Strongly) k-Modular and Unimodular Matrices
- Regular Matroids
- Graphic / Cographic / Planar Matrices
- Series-Parallel Matroids


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ ./.homebrew-build-env         # on macOS when homebrew is in use
    passagemath $ export PATH=/usr/sbin/:/sbin/:/bin/:/usr/lib/wsl/lib/   # on WSL
    passagemath $ python3 -m venv cmr-venv
    passagemath $ source cmr-venv/bin/activate
    passagemath $ export PIP_CONSTRAINT="$(pwd)/constraints_cmr.txt"
    passagemath $ echo "passagemath-conf @ file://$(pwd)/pkgs/sage-conf" > constraints_cmr.txt
    passagemath $ echo "passagemath-categories @ file://$(pwd)/pkgs/sagemath-categories" >> constraints_cmr.txt
    passagemath $ echo "passagemath-modules @ file://$(pwd)/pkgs/sagemath-modules" >> constraints_cmr.txt
    (cmr-venv) passagemath $ pip install -v -e pkgs/sagemath-cmr        \
                                            -e pkgs/sagemath-modules    \
                                            -e pkgs/sagemath-categories

Modularized use::

    (cmr-venv) passagemath $ pip install -v passagemath-repl
    (cmr-venv) passagemath $ sage
    ... sage.all is not available ...
    sage: from sage.all__sagemath_modules import *
    sage: matroids.Uniform(3, 4)

In plain Python::

    (cmr-venv) passagemath $ python3
    >>> from sage.all__sagemath_modules import *
    >>> matroids.Uniform(3, 4)

For full functionality of Sage::

    (cmr-venv) passagemath $ pip install -v passagemath-standard
    (cmr-venv) passagemath $ sage
    sage: matroids.Uniform(3, 4)
