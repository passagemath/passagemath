========================================================================
 passagemath: Symbolic computation with Giac
========================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2025 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork uses the motto "Creating a Free Passage Between the
Scientific Python Ecosystem and Mathematical Software Communities."
It was created in October 2024 with the following goals:

-  providing modularized installation with pip,
-  establishing first-class membership in the scientific Python
   ecosystem,
-  giving `clear attribution of upstream
   projects <https://groups.google.com/g/sage-devel/c/6HO1HEtL1Fs/m/G002rPGpAAAJ>`__,
-  providing independently usable Python interfaces to upstream
   libraries,
-  offering `platform portability and integration testing
   services <https://github.com/passagemath/passagemath/issues/704>`__
   to upstream projects,
-  inviting collaborations with upstream projects,
-  `building a professional, respectful, inclusive
   community <https://groups.google.com/g/sage-devel/c/xBzaINHWwUQ>`__,
-  `empowering Sage users to participate in the scientific Python ecosystem
   <https://github.com/passagemath/passagemath/issues/248>`__ by publishing packages,
-  developing a port to `Pyodide <https://pyodide.org/en/stable/>`__ for
   serverless deployment with Javascript,
-  developing a native Windows port.

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

Binary wheels for native Windows (x86_64) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath 10.6.x series are 3.10.x-3.13.x.


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

- `Cython interface to GIAC <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/giac.html>`_

  The Cython interface is by Frederic Han and was previously available under the name
  `giacpy-sage <https://gitlab.math.univ-paris-diderot.fr/han/giacpy-sage/>`_.
  It was merged into the Sage library in 2020.

- `Pexpect interface to GIAC <https://passagemath.org/docs/latest/html/en/reference/interfaces/sage/interfaces/giac.html>`_

- see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-giac/MANIFEST.in

- The binary wheels on PyPI ship a prebuilt copy of the Giac library.


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-giac[test]" ipython

    In [1]: from sage.all__sagemath_giac import *

    In [2]: x = libgiac('x')

    In [3]: V = [[x[i]**j for i in range(8)] for j in range(8)]

    In [4]: libgiac(V).dim()
    Out[4]: [8,8]

    In [5]: libgiac.det_minor(V).factor()
    Out[5]: (x[6]-(x[7]))*(x[5]-(x[7]))*(x[5]-(x[6]))*(x[4]-(x[7]))*(x[4]-(x[6]))*(x[4]-(x[5]))*(x[3]-(x[7]))*(x[3]-(x[6]))*(x[3]-(x[5]))*(x[3]-(x[4]))*(x[2]-(x[7]))*(x[2]-(x[6]))*(x[2]-(x[5]))*(x[2]-(x[4]))*(x[2]-(x[3]))*(x[1]-(x[7]))*(x[1]-(x[6]))*(x[1]-(x[5]))*(x[1]-(x[4]))*(x[1]-(x[3]))*(x[1]-(x[2]))*(x[0]-(x[7]))*(x[0]-(x[6]))*(x[0]-(x[5]))*(x[0]-(x[4]))*(x[0]-(x[3]))*(x[0]-(x[2]))*(x[0]-(x[1]))

    In [6]: (x+5)**(1/3)        # note here 1/3 is done in Python before being sent to Giac
    Out[6]: (x+5)^0.333333333333

    In [7]: (x+5)**QQ('1/3')    # using Sage rationals
    Out[7]: (x+5)^(1/3)

    In [8]: from fractions import Fraction  # using Python rationals

    In [9]: (x+5)**Fraction(1,3)
    Out[9]: (x+5)^(1/3)

The last example again, using the Sage REPL::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-giac[test]" sage
    Warning: sage.all is not available; this is a limited REPL.

    sage: from sage.all__sagemath_giac import *

    sage: x = libgiac('x')

    sage: (x+5)^(1/3)           # the Sage preparser translates this to (x+5)**QQ('1/3')
    (x+5)^(1/3)
