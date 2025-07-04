======================================================================================================
 passagemath: Algebraic combinatorics, combinatorial representation theory
======================================================================================================

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

This pip-installable source distribution ``passagemath-combinat`` is a distribution of a part of the Sage library.  It provides a small subset of the modules of the Sage library ("sagelib", ``sagemath-standard``).


What is included
----------------

* `Enumerative Combinatorics <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/enumerated_sets.html#sage-combinat-enumerated-sets>`_: `Partitions, Tableaux <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/catalog_partitions.html>`_

* `Combinatorics on Words <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/words/all.html#sage-combinat-words-all>`_, `Free Monoids <https://doc.sagemath.org/html/en/reference/monoids/index.html>`_, `Automatic Semigroups <https://doc.sagemath.org/html/en/reference/monoids/sage/monoids/automatic_semigroup.html>`_

* `Symmetric Functions <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/sf/all.html#sage-combinat-sf-all>`_, other `Algebras with combinatorial bases <https://doc.sagemath.org/html/en/reference/algebras/index.html>`_

* see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-combinat/MANIFEST.in


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-combinat[test]" ipython

    In [1]: from sage.all__sagemath_combinat import *

    In [2]: RowStandardTableaux([3,2,1]).cardinality()
    Out[2]: 60


Available as extras, from other distribution packages
-----------------------------------------------------

* `passagemath-graphs <https://pypi.org/project/passagemath-graphs>`_:
  Graphs, posets, finite state machines, combinatorial designs, incidence structures, quivers

* `passagemath-modules <https://pypi.org/project/passagemath-modules>`_:
  Modules and algebras, root systems, coding theory

* `passagemath-polyhedra <https://pypi.org/project/passagemath-polyhedra>`_:
  Polyhedra, lattice points, hyperplane arrangements


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv combinat-venv
    passagemath $ source combinat-venv/bin/activate
    (combinat-venv) passagemath $ pip install -v -e pkgs/sagemath-combinat
