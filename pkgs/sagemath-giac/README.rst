========================================================================
 passagemath: Symbolic computation with Giac
========================================================================

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

`Giac/Xcas <https://www-fourier.ujf-grenoble.fr/~parisse/giac.html>`_
is a general purpose Computer algebra system by Bernard Parisse released under GPLv3.
It has been developed since 2000 and is widely used: Giac/Xcas is the native CAS engine
of the HP Prime calculators; the C++ kernel of the system, Giac, provides the CAS view
of `Geogebra <https://www.geogebra.org/>`_.

This pip-installable source distribution ``passagemath-giac`` makes Giac available
from Python and provides integration with the Sage Mathematical Software System.


What is included
----------------

- `Cython interface to GIAC <https://doc.sagemath.org/html/en/reference/libs/sage/libs/giac.html>`_

  The Cython interface is by Frederic Han and was previously available under the name
  `giacpy-sage <https://gitlab.math.univ-paris-diderot.fr/han/giacpy-sage/>`_.
  It was `merged into the Sage library <https://github.com/sagemath/sage/issues/29171>`_
  in 2020.

- `Pexpect interface to GIAC <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/giac.html>`_

- see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-giac/MANIFEST.in

- The binary wheels on PyPI ship a prebuilt copy of the Giac library.


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-giac[test]" IPython

    In [1]: from sage.all__sagemath_modules import *

    In [2]: from sage.libs.giac import groebner_basis as gb_giac
