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


About this pip-installable distribution
---------------------------------------

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

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ ./.homebrew-build-env         # on macOS when homebrew is in use
    passagemath $ export PATH=/usr/sbin/:/sbin/:/bin/:/usr/lib/wsl/lib/   # on WSL
    passagemath $ export PIP_CONSTRAINT="$(pwd)/constraints_cmr.txt"
    passagemath $ echo "passagemath-conf @ file://$(pwd)/pkgs/sage-conf_pypi" > constraints_cmr.txt
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

In plain Python::

    (cmr-venv) passagemath $ python3
    >>> from sage.all__sagemath_modules import *
    >>> matroids.Uniform(3, 4)

For full functionality of Sage::

    (cmr-venv) passagemath $ pip install -v passagemath-standard
    (cmr-venv) passagemath $ sage
    sage: matroids.Uniform(3, 4)
