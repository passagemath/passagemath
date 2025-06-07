==========================================================================================
passagemath: Find automorphism groups of graphs, generate non-isomorphic graphs with nauty
==========================================================================================

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

This pip-installable distribution ``passagemath-nauty`` provides an interface to
`nauty and traces <https://pallini.di.uniroma1.it/>`_, the programs for computing
automorphism groups of graphs and digraphs by Brendan McKay and Adolfo Piperno.


What is included
----------------

- Graph generators `graphs.nauty_genbg <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.nauty_genbg>`_, `graphs.nauty_geng <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.nauty_geng>`_, `graphs.nauty_genktreeg <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.nauty_genktreeg>`_

- Hypergraph generator `hypergraphs.nauty <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/hypergraph_generators.html#sage.graphs.hypergraph_generators.HypergraphGenerators.nauty>`_

- Raw access to all gtools from Python

- The binary wheels published on PyPI include a prebuilt copy of nauty and traces.


Examples
--------

Using the gtools on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-nauty" sage -sh -c 'geng 4'
    >A geng -d0D3 n=4 e=0-6
    C?
    CC
    CE
    CF
    CQ
    CU
    CT
    CV
    C]
    C^
    C~
    >Z 11 graphs generated in 0.00 sec

Finding the installation location of a gtools program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-nauty[test]" ipython

    In [1]: from sage.features.nauty import NautyExecutable

    In [2]: NautyExecutable('geng').absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/535c90a22321f64/lib/python3.11/site-packages/sage_wheels/bin/geng'

Use with sage.graphs::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-nauty[test]" ipython

    In [1]: from sage.all__sagemath_graphs import *

    In [2]: gen = graphs.nauty_geng("7 -c")  # connected graphs on 7 vertices

    In [3]: len(list(gen))
    Out[3]: 853
