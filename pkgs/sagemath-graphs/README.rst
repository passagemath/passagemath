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

Complete sets of binary wheels are provided on PyPI for Python versions 3.10.x-3.13.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable package `passagemath-graphs` is a distribution of a part of the Sage Library.  It provides a small subset of the modules of the Sage library ("sagelib", `passagemath-standard`) for computations with graphs, posets, complexes, etc.

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

Libraries
~~~~~~~~~

``pip install passagemath-graphs[benzene,buckygen,plantri]`` additionally make
various graph generators available via `passagemath-benzene <https://pypi.org/project/passagemath-benzene/>`_, `passagemath-buckygen <https://pypi.org/project/passagemath-buckygen/>`_, and `passagemath-plantri <https://pypi.org/project/passagemath-plantri/>`_.

``pip install passagemath-graphs[bliss]`` additionally installs `passagemath-bliss <https://pypi.org/project/passagemath-bliss/>`_ for the purpose
of computing graph (iso/auto)morphisms.

``pip install passagemath-graphs[cliquer]`` additionally installs `passagemath-cliquer <https://pypi.org/project/passagemath-cliquer/>`_

``pip install passagemath-graphs[cmr]`` additionally installs `passagemath-cmr <https://pypi.org/project/passagemath-cmr/>`_ for recognition and decomposition algorithms
for network matrices, totally unimodular matrices and regular matroids, series-parallel matroids, etc.

``pip install passagemath-graphs[gap]`` additionally installs `passagemath-gap <https://pypi.org/project/passagemath-gap/>`_ for group-theoretic functionality.

``pip install passagemath-graphs[igraph]`` additionally installs
`igraph <https://python.igraph.org/en/stable/>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[igraph,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: ## Example depending on igraph goes here

``pip install passagemath-graphs[mcqd]`` additionally installs `passagemath-mcqd <https://pypi.org/project/passagemath-mcqd/>`_

``pip install passagemath-graphs[nauty]`` additionally installs `passagemath-nauty <https://pypi.org/project/passagemath-nauty/>`_ for computing
automorphism groups of graphs and digraphs.

``pip install passagemath-graphs[networkx]`` additionally installs
`NetworkX <https://networkx.github.io>`__::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[networkx,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: ## Example depending on networkx goes here

``pip install passagemath-graphs[pari]`` additionally installs `passagemath-pari <https://pypi.org/project/passagemath-pari/>`_

``pip install passagemath-graphs[planarity]`` additionally installs `passagemath-planarity <https://pypi.org/project/passagemath-planarity/>`_ for planarity testing.

``pip install passagemath-graphs[rankwidth]`` additionally installs `passagemath-rankwidth <https://pypi.org/project/passagemath-rankwidth/>`_ for rank width and rank decompositions.

``pip install passagemath-graphs[tdlib]`` additionally installs `passagemath-tdlib <https://pypi.org/project/passagemath-tdlib/>`_ for computing tree decompositions.


Features
~~~~~~~~

``pip install passagemath-graphs[combinat]`` additionally installs `passagemath-combinat <https://pypi.org/project/passagemath-combinat/>`_

``pip install passagemath-graphs[editor]`` additionally installs the interactive graph editor `phitigra <https://pypi.org/project/phitigra/>`_.

``pip install passagemath-graphs[groups]`` additionally makes group-theoretic features
available via `passagemath-gap <https://pypi.org/project/passagemath-gap/>`_, `passagemath-groups <https://pypi.org/project/passagemath-groups/>`_, and `passagemath-nauty <https://pypi.org/project/passagemath-nauty/>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[groups,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: g = Graph({
                0: [1, 2],
                1: [0, 2],
                2: [0, 1, 3],
                3: [2]
            })

    In [3]: aut = g.automorphism_group()

    In [4]: print(aut.order())

``pip install passagemath-graphs[homology]`` provides homological computations for abstract complexes via `passagemath-modules <https://pypi.org/project/passagemath-modules/>`_.

``pip install passagemath-graphs[mip]`` additionally makes the mixed-integer programming
solver GLPK available via `passagemath-glpk <https://pypi.org/project/passagemath-glpk/>`_ and `passagemath-polyhedra <https://pypi.org/project/passagemath-polyhedra/>`_ (see there for other available solvers).::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-graphs[mip,test]" ipython
    In [1]: from sage.all__sagemath_graphs import *

    In [2]: ## Example depending on MIP goes here

``pip install passagemath-graphs[modules]`` additionally makes linear algebra features available via `passagemath-modules <https://pypi.org/project/passagemath-modules/>`_.

``pip install passagemath-graphs[plot]`` additionally installs `passagemath-plot <https://pypi.org/project/passagemath-plot/>`_.

``pip install passagemath-graphs[polyhedra]`` additionally installs `passagemath-polyhedra <https://pypi.org/project/passagemath-polyhedra/>`_.

``pip install passagemath-graphs[sat]`` additionally provides SAT features via `passagemath-combinat <https://pypi.org/project/passagemath-combinat/>`_.

``pip install passagemath-graphs[standard]`` installs all libraries and features related to graphs that
are available in a standard installation of Sage.


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv graphs-venv
    passagemath $ source graphs-venv/bin/activate
    (graphs-venv) passagemath $ pip install -v -e pkgs/sagemath-graphs
