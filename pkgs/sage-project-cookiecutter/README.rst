=========================================================================================
passagemath: Script for maintaining a passagemath-based project
=========================================================================================

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

Complete sets of binary wheels are provided on PyPI for Python versions 3.10.x-3.14.x.


About this pip-installable distribution package
-----------------------------------------------

Creating a user project
~~~~~~~~~~~~~~~~~~~~~~~

::

   $ sage-project-cookiecutter create PROJECT-DIRECTORY

This creates configuration files:

- ``environment*.yml`` for local use with conda-forge in Linux, macOS
- ``.devcontainer/downstream-*/`` for use in dev container on Linux, macOS, Windows

It can also be invoked as follows::

   $ pipx run cruft create https://github.com/passagemath/passagemath \
       --directory="pkgs/sage-project-cookiecutter/sage_project_cookiecutter/user-project-template"

See https://cruft.github.io/cruft/ for available options.


Creating a pip-installable downstream package
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  $ sage-project-cookiecutter create --downstream-package PROJECT-DIRECTORY

Additionally creates:

- ``.github/workflows/``

It can also be invoked as follows::

   $ pipx run cruft create https://github.com/passagemath/passagemath \
       --directory="pkgs/sage-project-cookiecutter/sage_project_cookiecutter/downstream-package-template"


Adding Sage CI portability/integration testing infrastructure to an upstream project
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

   $ sage-project-cookiecutter create --upstream-package PROJECT-DIRECTORY

Creates in the existing ``PROJECT-DIRECTORY``:

- ``.github/workflows/ci-sage.yml``
- ``.devcontainer/portability-*``
- ``.devcontainer/tox-docker-in-docker``

It can also be invoked as follows::

   [alice@localhost PROJECT-DIRECTORY]$ (cd .. && pipx run cruft create \
       https://github.com/passagemath/passagemath \
       --directory="pkgs/sage-project-cookiecutter/sage_project_cookiecutter/upstream-package-template" \
       --overwrite-if-exists)
   [1/1] Name of the project (directory name to create) (my-sage-project): PROJECT-DIRECTORY


Creating a pip-installable upstream package of the SageMath organization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

   $ sage-project-cookiecutter create --sagemath-upstream-package PROJECT-DIRECTORY

Additionally creates:

- ``CODE_OF_CONDUCT.md``
- ``CONTRIBUTING.md``

It can also be invoked as follows::

   $ pipx run cruft create https://github.com/passagemath/passagemath \
       --directory="pkgs/sage-project-cookiecutter/sage_project_cookiecutter/sagemath-upstream-package-template"


Updating a project
~~~~~~~~~~~~~~~~~~

::

   [alice@localhost PROJECT-DIRECTORY]$ pipx run cruft update
