==================================================================================
 passagemath: Computational Number Theory with PARI/GP
==================================================================================

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

This pip-installable distribution ``passagemath-pari`` is a small
distribution that provides modules that depend on
`PARI/GP <https://pari.math.u-bordeaux.fr/>`__, the computer algebra
system designed for fast computations in number theory: factorizations,
algebraic number theory, elliptic curves, modular forms, L-functions...


What is included
----------------

- `integer factorization <https://passagemath.org/docs/10.6/html/en/reference/rings_standard/sage/rings/factorint_pari.html#module-sage.rings.factorint_pari>`__

- `finite fields <https://passagemath.org/docs/10.6/html/en/reference/finite_rings/sage/rings/finite_rings/finite_field_pari_ffelt.html#module-sage.rings.finite_rings.finite_field_pari_ffelt>`__

- much of the `p-adics functionality of the Sage library <https://passagemath.org/docs/10.6/html/en/reference/padics/index.html>`__

- `discrete valuations <https://passagemath.org/docs/10.6/html/en/reference/valuations/index.html>`__

- parts of the `quadratic forms functionality of the Sage library <https://passagemath.org/docs/10.6/html/en/reference/quadratic_forms/index.html>`__

- various other modules with dependencies on PARI/GP, see `MANIFEST <https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-pari/MANIFEST.in>`_

- the `cypari2 <https://pypi.org/project/cypari2/>`_ API

- the `pari-jupyter kernel <https://github.com/passagemath/upstream-pari-jupyter>`__

- the binary wheels on PyPI ship a prebuilt copy of PARI/GP

- the binary wheels on PyPI ship XEUS-GP, another Jupyter kernel for PARI/GP


Examples
--------

Starting the GP calculator from the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-pari" sage -gp
    GP/PARI CALCULATOR Version 2.17.2 (released)
    ...

Using the pexpect interface to the GP calculator::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-pari[test]" ipython

    In [1]: from sage.interfaces.gp import gp

    In [2]: E = gp.ellinit([1,2,3,4,5])

    In [3]: E.ellglobalred()
    Out[3]: [10351, [1, -1, 0, -1], 1, [11, 1; 941, 1], [[1, 5, 0, 1], [1, 5, 0, 1]]]

Using the ``cypari2`` library interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-pari" python

    >>> import cypari2
    >>> pari = cypari2.Pari()

    >>> pari(2).zeta()
    1.64493406684823

    >>> p = pari("x^3 + x^2 + x - 1")
    >>> modulus = pari("t^3 + t^2 + t - 1")
    >>> fq = p.factorff(3, modulus)
    >>> fq.lift().centerlift()
    [x - t, 1; x + (t^2 + t - 1), 1; x + (-t^2 - 1), 1]


Available as extras, from other distributions
---------------------------------------------

PARI/GP data packages
~~~~~~~~~~~~~~~~~~~~~

See https://pari.math.u-bordeaux.fr/packages.html for detailed descriptions.

``pip install "passagemath-pari[elldata]"``

``pip install "passagemath-pari[galdata]"``

``pip install "passagemath-pari[galpol]"``

``pip install "passagemath-pari[nflistdata]"``

``pip install "passagemath-pari[nftables]"``

``pip install "passagemath-pari[seadata]"``

``pip install "passagemath-pari[seadata-big]"``

``pip install "passagemath-pari[seadata-small]"``
