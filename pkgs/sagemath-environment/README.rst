=========================================================================
 passagemath: System and software environment
=========================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2025 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork was created in October 2024 with the following
goals:

-  providing modularized installation with pip, thus completing a `major
   project started in 2020 in the Sage
   codebase <https://github.com/sagemath/sage/issues/29705>`__,
-  establishing first-class membership in the scientific Python
   ecosystem,
-  giving `clear attribution of upstream
   projects <https://groups.google.com/g/sage-devel/c/6HO1HEtL1Fs/m/G002rPGpAAAJ>`__,
-  providing independently usable Python interfaces to upstream
   libraries,
-  providing `platform portability and integration testing
   services <https://github.com/passagemath/passagemath/issues/704>`__
   to upstream projects,
-  inviting collaborations with upstream projects,
-  `building a professional, respectful, inclusive
   community <https://groups.google.com/g/sage-devel/c/xBzaINHWwUQ>`__,
-  developing a port to `Pyodide <https://pyodide.org/en/stable/>`__ for
   serverless deployment with Javascript,
-  developing a native Windows port.

`Full documentation <https://doc.sagemath.org/html/en/index.html>`__ is
available online.

passagemath attempts to support all major Linux distributions and recent versions of
macOS. Use on Windows currently requires the use of Windows Subsystem for Linux or
virtualization.

Complete sets of binary wheels are provided on PyPI for Python versions 3.10.x-3.13.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


About this pip-installable distribution package
-----------------------------------------------

The pip-installable distribution package `sagemath-environment` is a
distribution of a small part of the Sage Library.

It provides a small, fundamental subset of the modules of the Sage
library ("sagelib", `sagemath-standard`), providing the connection to the
system and software environment.


What is included
----------------

* `sage` script for launching the Sage REPL and accessing various developer tools
  (see `sage --help`, `Invoking Sage <https://doc.sagemath.org/html/en/reference/repl/options.html>`_).

* sage.env

* `sage.features <https://doc.sagemath.org/html/en/reference/misc/sage/features.html>`_: Testing for features of the environment at runtime

* `sage.misc.package <https://doc.sagemath.org/html/en/reference/misc/sage/misc/package.html>`_: Listing packages of the Sage distribution

* `sage.misc.package_dir <https://doc.sagemath.org/html/en/reference/misc/sage/misc/package_dir.html>`_

* `sage.misc.temporary_file <https://doc.sagemath.org/html/en/reference/misc/sage/misc/temporary_file.html>`_

* `sage.misc.viewer <https://doc.sagemath.org/html/en/reference/misc/sage/misc/viewer.html>`_
