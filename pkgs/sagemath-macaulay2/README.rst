===================================================================================================
passagemath: Computing in commutative algebra, algebraic geometry and related fields with Macaulay2
===================================================================================================

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

This pip-installable distribution ``passagemath-macaulay2`` provides an interface to
`Macaulay2 <https://github.com/Macaulay2/M2>`_.


What is included
----------------

- `Python interface to Macaulay 2 <https://passagemath.org/docs/latest/html/en/reference/interfaces/sage/interfaces/macaulay2.html>`_

- The binary wheels published on PyPI include a prebuilt copy of Macaulay 2.


Examples
--------

Using Macaulay 2 on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-macaulay2" sage -sh -c 'M2'

Finding the installation location of Macaulay 2::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-macaulay2[test]" ipython

    In [1]: from sage.features.macaulay2 import Macaulay2

    In [2]: Macaulay2().absolute_filename()
    Out[2]: '.../bin/M2'

Using the Python interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-macaulay2[test]" ipython

    In [1]: from sage.all__sagemath_macaulay2 import *

    In [2]: R = macaulay2('QQ[x, y]'); R
    Out[2]: QQ[x..y]

    In [3]: S = R / macaulay2('ideal {x^2 - y}'); S
    Out[3]:
    QQ[x..y]
    --------
      2
     x  - y

    In [4]: S.gens()
    Out[4]: {x, y}


Available as extras, from other distributions
---------------------------------------------

Jupyter kernel
~~~~~~~~~~~~~~

``pip install "passagemath-macaulay2[jupyterkernel]"``
 installs the kernel for use in the Jupyter notebook and JupyterLab

``pip install "passagemath-macaulay2[notebook]"``
 installs the kernel and the Jupyter notebook

``pip install "passagemath-macaulay2[jupyterlab]"``
 installs the kernel and JupyterLab
