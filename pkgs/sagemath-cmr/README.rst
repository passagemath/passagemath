==========================================================================
 passagemath: Combinatorial matrix recognition
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

This pip-installable distribution ``passagemath-cmr`` is a small
optional distribution for use with `passagemath-modules <https://pypi.org/project/passagemath-modules/>`_ and
`passagemath-graphs <https://pypi.org/project/passagemath-graphs/>`_.

It provides a Cython interface to the
`CMR library <https://github.com/discopt/cmr>`_,
which implements recognition and decomposition algorithms for:

- Totally Unimodular Matrices
- Network Matrices
- Complementary Totally Unimodular Matrices
- (Strongly) Equimodular and Unimodular Matrices
- Regular Matroids
- Graphic / Cographic / Planar Matrices
- Series-Parallel Matroids


Examples
--------

::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-cmr[test]" ipython

    In [1]: from sage.all__sagemath_cmr import *

    In [2]: from sage.matrix.matrix_cmr_sparse import Matrix_cmr_chr_sparse

    In [3]: M = Matrix_cmr_chr_sparse(MatrixSpace(ZZ, 3, 3, sparse=True), [[1, 0, 1], [0, 1, 1], [1, 2, 3]]); M
    Out[3]:
    [1 0 1]
    [0 1 1]
    [1 2 3]

    In [4]: M.is_unimodular()
    Out[4]: True

    In [5]: M.is_strongly_unimodular()
    Out[5]: False


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git  # or use your fork
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ source ./.homebrew-build-env         # on macOS when homebrew is in use
    passagemath $ export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/wsl/lib  # on WSL
    passagemath $ export PIP_CONSTRAINT="$(pwd)/constraints_cmr.txt"
    passagemath $ echo "passagemath-categories @ file://$(pwd)/pkgs/sagemath-categories" >> constraints_cmr.txt
    passagemath $ echo "passagemath-modules @ file://$(pwd)/pkgs/sagemath-modules" >> constraints_cmr.txt
    passagemath $ python3 -m venv cmr-venv
    passagemath $ source cmr-venv/bin/activate
    (cmr-venv) passagemath $ pip install -v -e pkgs/sagemath-cmr        \
                                            -e pkgs/sagemath-modules    \
                                            -e pkgs/sagemath-categories

Modularized use::

    (cmr-venv) passagemath $ pip install -v passagemath-repl
    (cmr-venv) passagemath $ sage
    ... sage.all is not available ...
    sage: from sage.all__sagemath_modules import *
    sage: matroids.Uniform(3, 4)
    U(3, 4): Matroid of rank 3 on 4 elements with circuit-closures
    {3: {{0, 1, 2, 3}}}

In plain Python::

    (cmr-venv) passagemath $ python3
    >>> from sage.all__sagemath_modules import *
    >>> matroids.Uniform(3, 4)
    U(3, 4): Matroid of rank 3 on 4 elements with circuit-closures
    {3: {{0, 1, 2, 3}}}

For full functionality of Sage::

    (cmr-venv) passagemath $ pip install -v passagemath-standard
    (cmr-venv) passagemath $ sage
    sage: matroids.Uniform(3, 4)
    U(3, 4): Matroid of rank 3 on 4 elements with circuit-closures
    {3: {{0, 1, 2, 3}}}
