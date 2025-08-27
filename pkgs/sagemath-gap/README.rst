=============================================================================
 passagemath: Computational Group Theory with GAP
=============================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2025 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork uses the motto "Creating a Free Passage Between the
Scientific Python Ecosystem and Mathematical Software Communities."
It was created in October 2024 with the following goals:

-  providing modularized installation with pip,
-  establishing first-class membership in the scientific Python
   ecosystem,
-  giving `clear attribution of upstream
   projects <https://groups.google.com/g/sage-devel/c/6HO1HEtL1Fs/m/G002rPGpAAAJ>`__,
-  providing independently usable Python interfaces to upstream
   libraries,
-  offering `platform portability and integration testing
   services <https://github.com/passagemath/passagemath/issues/704>`__
   to upstream projects,
-  inviting collaborations with upstream projects,
-  `building a professional, respectful, inclusive
   community <https://groups.google.com/g/sage-devel/c/xBzaINHWwUQ>`__,
-  `empowering Sage users to participate in the scientific Python ecosystem
   <https://github.com/passagemath/passagemath/issues/248>`__ by publishing packages,
-  developing a port to `Pyodide <https://pyodide.org/en/stable/>`__ for
   serverless deployment with Javascript,
-  developing a native Windows port.

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

Binary wheels for native Windows (x86_64) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath 10.6.x series are 3.10.x-3.13.x.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-gap`` is a small
distribution that provides modules that depend on the `GAP system <https://www.gap-system.org>`_.


What is included
----------------

- `Cython interface to libgap <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/gap/libgap.html>`_

- `Pexpect interface to GAP <https://passagemath.org/docs/latest/html/en/reference/interfaces/sage/interfaces/gap.html>`_

- numerous modules with build-time dependencies on GAP, see `MANIFEST <https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-gap/MANIFEST.in>`_

- the binary wheels on PyPI ship a prebuilt copy of GAP and the following `GAP packages <https://www.gap-system.org/packages>`__:

  - `aclib <https://gap-packages.github.io/aclib/>`__: Almost crystallographic groups
  - `alnuth <https://gap-packages.github.io/alnuth>`__: Algebraic number theory, interface to PARI/GP
  - `atlasrep <https://www.math.rwth-aachen.de/~Thomas.Breuer/atlasrep>`__: Interface to the Atlas of Group Representations
  - `autodoc <https://gap-packages.github.io/AutoDoc>`__: Generate documentation from GAP source code
  - `autpgrp <https://gap-packages.github.io/autpgrp/>`__: Computing the automorphism group of a p-group
  - `cohomolo <https://gap-packages.github.io/cohomolo>`__: Cohomology groups of finite groups on finite modules
  - `corelg <https://gap-packages.github.io/corelg/>`__: Computing with real Lie algebras
  - `crime <https://gap-packages.github.io/crime/>`__: Group cohomology and Massey products
  - `crisp <http://www.icm.tu-bs.de/~bhoeflin/crisp/index.html>`__: Computing with radicals, injectors, Schunck classes and projectors
  - `crypting <https://gap-packages.github.io/crypting/>`__: Hashes and crypto
  - `cryst <https://www.math.uni-bielefeld.de/~gaehler/gap/packages.php>`__: Computing with crystallographic groups
  - `crystcat <https://www.math.uni-bielefeld.de/~gaehler/gap/packages.php>`__: Crystallographic groups catalog
  - `datastructures <https://gap-packages.github.io/datastructures>`__: Collection of standard data structures
  - `design <https://gap-packages.github.io/design>`__: Constructing, classifying, partitioning, and studying block designs
  - `digraphs <https://digraphs.github.io/Digraphs>`__: Graphs, digraphs, and multidigraphs
  - `factint <https://gap-packages.github.io/FactInt>`__: Advanced methods for factoring integers
  - `fga <https://gap-packages.github.io/fga/>`__: Free group algorithms
  - `gapdoc <https://www.math.rwth-aachen.de/~Frank.Luebeck/GAPDoc>`__: Meta package for GAP documentation
  - `gbnp <https://gap-packages.github.io/gbnp/>`__: Gröbner bases of noncommutative polynomials
  - `genss <https://gap-packages.github.io/genss>`__: Generic Schreier-Sims
  - `grape <https://gap-packages.github.io/grape>`__: GRaph Algorithms using PErmutation groups
  - `guava <https://gap-packages.github.io/guava>`__: Computing with error-correcting codes
  - `hap <https://gap-packages.github.io/hap>`__: Homological algebra programming
  - `hapcryst <https://gap-packages.github.io/hapcryst/>`__: HAP extension for crystallographic groups
  - `hecke <https://gap-packages.github.io/hecke/>`__: Calculating decomposition matrices of Hecke algebras
  - `images <https://gap-packages.github.io/images/>`__: Minimal and canonical images
  - `jupyterviz <https://nathancarter.github.io/jupyterviz>`__: Visualization Tools for Jupyter and the GAP REPL
  - `io <https://gap-packages.github.io/io>`__: Bindings for low level C library I/O routines
  - `json <https://gap-packages.github.io/json/>`__: Reading and Writing JSON
  - `laguna <https://gap-packages.github.io/laguna>`__: Lie AlGebras and UNits of group Algebras
  - `liealgdb <https://gap-packages.github.io/liealgdb/>`__: Database of Lie algebras
  - `liepring <https://gap-packages.github.io/liepring/>`__: Database and algorithms for Lie p-rings
  - `liering <https://gap-packages.github.io/liering/>`__: Computing with finitely presented Lie rings
  - `lins <https://gap-packages.github.io/LINS/>`__: Computing the normal subgroups of a finitely presented group
  - `loops <https://gap-packages.github.io/loops/>`__: Computing with quasigroups and loops
  - `mapclass <https://gap-packages.github.io/MapClass>`__: Mapping class orbit computation
  - `nq <https://gap-packages.github.io/nq/>`__: Nilpotent quotients of finitely presented groups
  - `orb <https://gap-packages.github.io/orb>`__: Methods to enumerate orbits
  - `packagemanager <https://gap-packages.github.io/PackageManager/>`__: Easily download and install GAP packages
  - `polenta <https://gap-packages.github.io/polenta/>`__: Polycyclic presentations for matrix groups
  - `polycyclic <https://gap-packages.github.io/polycyclic/>`__: Computation with polycyclic groups
  - `polymaking <https://gap-packages.github.io/polymaking/>`__: Interfacing the geometry software polymake
  - `primgrp <https://gap-packages.github.io/primgrp/>`__: Primitive permutation groups library
  - `quagroup <https://gap-packages.github.io/quagroup/>`__: Computations with quantum groups
  - `qpa <https://folk.ntnu.no/oyvinso/QPA/>`__: Quivers and path algebras
  - `radiroot <https://gap-packages.github.io/radiroot/>`__: Roots of a polynomial as radicals
  - `repsn <https://gap-packages.github.io/repsn/>`__: Constructing representations of finite groups
  - `resclasses <https://gap-packages.github.io/resclasses/>`__: Set-theoretic computations with residue classes
  - `singular <https://gap-packages.github.io/singular/>`__: Interface to Singular
  - `sla <https://gap-packages.github.io/sla/>`__: Simple Lie algebras
  - `smallgrp <https://gap-packages.github.io/smallgrp/>`__: The GAP Small Groups Library
  - `sonata <https://gap-packages.github.io/sonata/>`__: System of nearrings and their applications
  - `sophus <https://gap-packages.github.io/sophus/>`__: Computing in nilpotent Lie algebras
  - `toric <https://gap-packages.github.io/toric>`__: Toric varieties and some combinatorial geometry computations
  - `utils <https://gap-packages.github.io/utils>`__: Utility functions
  - `uuid <https://gap-packages.github.io/uuid/>`__: RFC 4122 UUIDs
  - `ZeroMQInterface <https://gap-packages.github.io/ZeroMQInterface/>`__: ZeroMQ bindings

- the binary wheels on PyPI ship a prebuilt copy of the native Jupyter kernel for GAP


Examples
--------

Running GAP from the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-gap" sage -gap
     ┌───────┐   GAP 4.14.0 of 2024-12-05
     │  GAP  │   https://www.gap-system.org
     └───────┘   Architecture: x86_64-apple-darwin22-default64-kv9
     Configuration:  gmp 6.3.0, GASMAN, readline
     Loading the library and packages ...
     Packages:   GAPDoc 1.6.7, PrimGrp 3.4.4, SmallGrp 1.5.4, TransGrp 3.6.5
     Try '??help' for help. See also '?copyright', '?cite' and '?authors'
    gap>

Using the library interface from Python::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-gap[test]" IPython

    In [1]: from sage.all__sagemath_modules import *

    In [2]: from sage.all__sagemath_gap import *

    In [3]: G = libgap.eval("Group([(1,2,3), (1,2)(3,4), (1,7)])")

    In [4]: CG = G.ConjugacyClasses()

    In [5]: gamma = CG[2]

    In [6]: g = gamma.Representative()

    In [7]: CG; gamma; g
    [ ()^G, (4,7)^G, (3,4,7)^G, (2,3)(4,7)^G, (2,3,4,7)^G, (1,2)(3,4,7)^G, (1,2,3,4,7)^G ]
    (3,4,7)^G
    (3,4,7)


Available as extras, from other distributions
---------------------------------------------

Jupyter kernel spec
~~~~~~~~~~~~~~~~~~~

``pip install "passagemath-gap[jupyterkernel]"``
 installs the kernel spec for use in the Jupyter notebook and JupyterLab

``pip install "passagemath-gap[notebook]"``
 installs the kernel spec and the Jupyter notebook

``pip install "passagemath-gap[jupyterlab]"``
 installs the kernel spec and JupyterLab


GAP packages
~~~~~~~~~~~~

``pip install "passagemath-gap[ctbllib]"``
 installs `ctbllib <https://www.math.rwth-aachen.de/~Thomas.Breuer/ctbllib>`__: The GAP Character Table Library

``pip install "passagemath-gap[irredsol]"``
 installs `irredsol <http://www.icm.tu-bs.de/~bhoeflin/irredsol/index.html>`__: Library of irreducible soluble linear groups over finite fields and of finite primivite soluble groups

``pip install "passagemath-gap[tomllib]"``
 installs `tomlib <https://gap-packages.github.io/tomlib>`__: The GAP Library of Tables of Marks

``pip install "passagemath-gap[transgrp]"``
 installs `transgrp <https://www.math.colostate.edu/~hulpke/transgrp>`__: Transitive Groups Library
