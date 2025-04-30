============================================================================
passagemath: Lattice points in polyhedra with LattE integrale and 4ti2
============================================================================

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

This pip-installable source distribution ``passagemath-latte-4ti2`` provides an interface
to `LattE integrale <https://www.math.ucdavis.edu/~latte/>`_
(for the problems of counting lattice points in and integration over convex polytopes)
and `4ti2 <https://github.com/4ti2/4ti2>`_
(for algebraic, geometric and combinatorial problems on linear spaces).


What is included
----------------

- `Python interface to LattE integrale programs <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/latte.html#module-sage.interfaces.latte>`_

- `Python interface to 4ti2 programs <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/four_ti_2.html>`_

- Raw access to all executables from Python using `sage.features.latte <https://doc.sagemath.org/html/en/reference/spkg/sage/features/latte.html>`_ and `sage.features.four_ti_2 <https://doc.sagemath.org/html/en/reference/spkg/sage/features/four_ti_2.html>`_

- The binary wheels published on PyPI include a prebuilt copy of
  LattE integrale and 4ti2.


Examples
--------

Using LattE integrale and 4ti2 programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-latte-4ti2" sage -sh -c 'ppi 5'
    ...
    ### This makes 47 PPI up to sign
    ### Writing data file ppi5.gra and matrix file ppi5.mat done.

Finding the installation location of a LattE integrale or 4ti2 program in Python::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-latte-4ti2[test]" ipython

    In [1]: from sage.features.latte import Latte_count

    In [2]: Latte_count().absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/2dc147a5e4863b4/lib/python3.11/site-packages/sage_wheels/bin/count'

    In [3]: from sage.features.four_ti_2 import FourTi2Executable

    In [4]: FourTi2Executable('ppi').absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/2dc147a5e4863b4/lib/python3.11/site-packages/sage_wheels/bin/ppi'

Using the low-level Python interfaces::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-latte-4ti2[test]" ipython

    In [1]: from sage.interfaces.latte import count

    In [2]: cdd_Hrep = 'H-representation\nbegin\n 6 4 rational\n 2 -1 0 0\n 2 0 -1 0\n 2 0 0 -1\n 2 1 0 0\n 2 0 0 1\n 2 0 1 0\nend\n'

    In [3]: count(cdd_Hrep, cdd=True)
    Out[3]: 125

Use with sage.geometry.polyhedron::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-latte-4ti2[test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: P = Polyhedron(vertices=[[1,0,0], [0,0,1], [-1,1,1], [-1,2,0]])

    In [3]: P.volume(measure='induced_lattice', engine='latte')
    Out[3]: 3
