===========================================================
 passagemath: Embeddable Common Lisp
===========================================================

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

This pip-installable distribution ``passagemath-ecl`` is a distribution of a part of the Sage Library.
It ships the Python and Cython interfaces to Embeddable Common Lisp.


What is included
----------------

* `pexpect interface to Lisp <https://passagemath.org/docs/10.6/html/en/reference/interfaces/sage/interfaces/lisp.html>`__

* `Library (Cython) interface to Embeddable Common Lisp <https://passagemath.org/docs/10.6/html/en/reference/libs/sage/libs/ecl.html#module-sage.libs.ecl>`__

* Binary wheels on PyPI contain a prebuilt copy of
  `Embeddable Common Lisp <https://passagemath.org/docs/latest/html/en/reference/spkg/ecl.html>`_


Examples
--------

Starting ECL from the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-ecl[test]" sage --ecl

    ECL (Embeddable Common-Lisp) 23.9.9 (git:UNKNOWN)
    Copyright (C) 1984 Taiichi Yuasa and Masami Hagiya
    ...
    >

Finding the installation location of ECL in Python::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-ecl[test]" ipython

    In [1]: from sage.features.ecl import Ecl

    In [2]: Ecl().absolute_filename()
    Out[2]: '.../bin/ecl'

Using the Cython interface to ECL::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-ecl[test]" sage

    sage: from sage.libs.ecl import *
    sage: ecl_eval("(defun fibo (n) (cond ((= n 0) 0) ((= n 1) 1) (t (+ (fibo (- n 1)) (fibo (- n 2))))))")
    <ECL: FIBO>
    sage: ecl_eval("(mapcar 'fibo '(1 2 3 4 5 6 7))")
    <ECL: (1 1 2 3 5 8 13)>
    sage: list(_)
    [<ECL: 1>, <ECL: 1>, <ECL: 2>, <ECL: 3>, <ECL: 5>, <ECL: 8>, <ECL: 13>]
