=======================================================================================================================================================
 passagemath: Graphs, posets, hypergraphs, designs, abstract complexes, combinatorial polyhedra, abelian sandpiles, quivers
=======================================================================================================================================================

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
