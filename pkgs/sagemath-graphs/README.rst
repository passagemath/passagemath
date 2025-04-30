=======================================================================================================================================================
 passagemath: Graphs, posets, hypergraphs, designs, abstract complexes, combinatorial polyhedra, abelian sandpiles, quivers
=======================================================================================================================================================

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

Complete sets of binary wheels are provided on PyPI for Python versions 3.9.x-3.12.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable package `passagemath-graphs` is a distribution of a part of the Sage Library.  It provides a small subset of the modules of the Sage library ("sagelib", `sagemath-standard`) for computations with graphs, posets, complexes, etc.

It consists of over 170 first-party Python and Cython modules and uses the `Boost Graph Library <https://github.com/boostorg/graph>`_, with additional functionality from `NetworkX <https://networkx.github.io/>`_ and several other libraries.


What is included
----------------

* `Graph Theory <https://doc.sagemath.org/html/en/reference/graphs/index.html>`_

* `Trees <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/enumerated_sets.html#trees>`_

* `Posets <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/posets/all.html>`_

* `Abstract Complexes <https://doc.sagemath.org/html/en/reference/topology/index.html>`_

* `Combinatorial Designs and Incidence Structure <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/designs/all.html>`_

* `Finite State Machines, Automata, Transducers <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/finite_state_machine.html>`_

* `Cluster Algebras and Quivers <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/cluster_algebra_quiver/all.html>`_

* `Knot Theory <https://doc.sagemath.org/html/en/reference/knots/index.html>`_

* `Sandpiles <https://doc.sagemath.org/html/en/reference/dynamics/sage/sandpiles/sandpile.html>`_

* see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-graphs/MANIFEST.in


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [6]: g = Graph([(1, 3), (3, 8), (5, 2)]); g
    Out[6]: Graph on 5 vertices

    In [7]: g.is_connected()
    Out[7]: False


Available as extras, from other distributions
---------------------------------------------

``pip install passagemath-graphs[networkx]`` additionally installs
`NetworkX <https://networkx.github.io>`::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[networkx,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: ## Example depending on networkx goes here


``pip install passagemath-graphs[igraph]`` additionally installs
`igraph <https://python.igraph.org/en/stable/>`::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[igraph,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: ## Example depending on igraph goes here


``pip install passagemath-graphs[mip]`` additionally makes the mixed-integer programming
solver GLPK available::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[mip,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: ## Example depending on MIP goes here



Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv graphs-venv
    passagemath $ source graphs-venv/bin/activate
    (graphs-venv) passagemath $ pip install -v -e pkgs/sagemath-graphs
