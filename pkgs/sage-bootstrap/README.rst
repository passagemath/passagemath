passagemath: System package database with support for PURLs (package URLs)
==========================================================================

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

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support all major Linux distributions and recent versions of
macOS. Use on Windows currently requires the use of Windows Subsystem for Linux or
virtualization.

Complete sets of binary wheels are provided on PyPI for Python versions 3.10.x-3.13.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


About this pip-installable distribution package
-----------------------------------------------

This distribution package ``passagemath-bootstrap`` provides:

- a script ``sage-guess-package-system``::

    $ sage-guess-package-system
    homebrew

- a script ``sage-get-system-packages`` to map PURLs to names of system packages::

    $ sage-get-system-packages gentoo generic/gmp generic/gap
    sci-mathematics/gap
    dev-libs/gmp

- a script ``sage-print-system-package-command`` to print system package installation
  commands for given PURLs::

    $ sage-print-system-package-command void --spkg install generic/gmp generic/gap
    xbps-install gmp-devel gmpxx-devel

    $ sage-print-system-package-command fedora --spkg --sudo install generic/linbox
    sudo dnf install linbox linbox-devel

- a script ``sage-package`` to query the system package database::

    $ sage-package properties generic/gmp
    path:                        .../site-packages/sage_root/build/pkgs/gmp
    version_with_patchlevel:     6.3.0
    type:                        standard
    source:                      normal
    trees:                       SAGE_LOCAL
    purl:                        pkg:generic/gmp
    description:                 Library for arbitrary precision arithmetic
    uses_python_package_check:   False

- a script ``sage-spkg-info`` to print system package information::

    $ sage-spkg-info generic/macaulay2
    ...

    $ sage-spkg-info pypi/setuptools
    ...

- a Python API defined in ``sage_bootstrap``

The database of packages is included with ``passagemath-bootstrap`` and consists of
over 600 packages; see https://passagemath.org/docs/latest/html/en/reference/spkg/index.html
for a list of the available packages.
