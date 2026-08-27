===================================================
 passagemath: Computational group theory with GAP3
===================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2026 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork uses the motto "Creating a Free Passage Between the
Scientific Python Ecosystem and Mathematical Software Communities."
It was created in October 2024 with the following goals:

-  providing modularized installation with pip from binary wheels,
   - this major project was started in May 2020 in the Sage codebase and completed in passagemath 10.5.29 (May 2025),

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

-  developing a port to WebAssembly (`Pyodide <https://pyodide.org/en/stable/>`__, emscripten-forge) for
   serverless deployment with Javascript,

-  developing a native Windows port
   - passagemath 10.6.1 (July 2025) published the first pip-installable wheel packages for native Windows on x86_64,
   - passagemath packages became available in the [MSYS2 software distribution](https://packages.msys2.org/search?t=pkg&q=passagemath) in November 2025.

Moreover, the passagemath project:

-  provides a stable, frequently updated version of the Sage distribution,
-  integrates additional mathematical software, notably Macaulay2, a full set of GAP packages,
   and the Combinatorial Matrix Recognition library,
-  curates a library of Sage user packages.

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

Binary wheels for native Windows (x86_64, ARM) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath-10.8.x series are 3.11.x-3.14.x;
the passagemath-10.6.x series (EOL 2026-10) still supports Python 3.10.x.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-gap3`` provides
an interface to `GAP3 <https://passagemath.org/docs/latest/html/en/reference/spkg/gap3.html>`__.

It can be installed as an extra of the distribution
`passagemath-groups <https://pypi.org/project/passagemath-groups>`_::

  $ pip install "passagemath-groups[gap3]"


What is included
----------------

- `Finite real reflection groups <https://passagemath.org/docs/latest/html/en/reference/combinat/sage/combinat/root_system/reflection_group_real.html>`__

- `Finite complex reflection groups <https://passagemath.org/docs/latest/html/en/reference/combinat/sage/combinat/root_system/reflection_group_complex.html>`__

- the binary wheels on PyPI ship a prebuilt copy of GAP3, namely
  `Jean Michel's pre-packaged GAP3 <https://webusers.imj-prg.fr/~jean.michel/gap3/>`__,
  which is a minimal GAP3 distribution containing packages that have
  no equivalent in GAP4.


Examples
--------

Starting GAP3 from the command line without explicit installation::

    $ pipx run --spec "passagemath-gap3" sage -gap3
                 ########            Lehrstuhl D fuer Mathematik, RWTH Aachen
               ###    ####             #######            #########
              ##         ##           #      ##          ## #     ##
             ##          #           #       ##             #      ##
            ##           #           ##       #             #      ##
            ####        ##            #########             #######
             #####     ###  Version 3 Release 4.4 18 Apr 97 #
               ######### #                                  # Martin Schoenert
                        ##  Alice Niemeyer, Werner Nickel   # Erzsebet Horvath
                       ###  Bettina Eick,   Frank Celler,   # Udo Polis
                      ## #  Johannes Meier, Alex Wegner,    # Goetz Pfeiffer
                     ##  #  Juergen Mnich,  Thomas Breuer   # Heiko Theissen
                    ##   #  Hans U. Besche, Volkmar Felsch  # Ansgar Kaup
                   ##    #  Akos Seress,    Alexander Hulpke, Thomas Bischops
                  ##    ##
                   ######   For help enter: ?<return>
     lib: 29 May 2017, src: 22 feb 2017, sys: macosx gcc64
     for this GAP3 distribution see webusers.imj-prg.fr/~jmichel/gap3
    ...
    gap>

Using the pexpect interface::

    $ pipx run --spec "passagemath-gap3" sage
    ...
    sage: from sage.interfaces.gap3 import gap3
    sage: gap3.load_package("chevie")
    sage: m = gap3([[1,2,3],[4,5,6]]); m
    [ [ 1, 2, 3 ], [ 4, 5, 6 ] ]

Using ``sage.combinat.root_system``::

    $ pipx run --spec "passagemath-gap3" python
    ...
    >>> from passagemath_gap3 import *
    >>> W = ReflectionGroup(['H',4]); W
    Irreducible real reflection group of rank 4 and type H4
