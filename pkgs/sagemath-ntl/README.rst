==============================================================================
 passagemath: Computational Number Theory with NTL
==============================================================================

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

This pip-installable package ``passagemath-ntl`` is a small
distribution that provides modules that depend on
`NTL <https://libntl.org/>`_, the library for doing number theory.


What is included
----------------

* Computation of Bernoulli numbers modulo p:

  * `Cython wrapper for bernmm library <https://passagemath.org/docs/latest/html/en/reference/rings_standard/sage/rings/bernmm.html>`_
  * `Bernoulli numbers modulo p <https://passagemath.org/docs/latest/html/en/reference/rings_standard/sage/rings/bernoulli_mod_p.html>`_

* Finite fields of characteristic 2

  * `Finite fields of characteristic 2 <https://passagemath.org/docs/latest/html/en/reference/finite_rings/sage/rings/finite_rings/finite_field_ntl_gf2e.html>`_
  * `Elements of finite fields of characteristic 2 <https://passagemath.org/docs/latest/html/en/reference/finite_rings/sage/rings/finite_rings/element_ntl_gf2e.html>`_

* p-adic extension elements:

  * `p-adic Extension Element <https://passagemath.org/docs/latest/html/en/reference/padics/sage/rings/padics/padic_ext_element.html#module-sage.rings.padics.padic_ext_element>`_
  * `p-adic ZZ_pX Element <https://passagemath.org/docs/latest/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_element.html>`_
  * `p-adic ZZ_pX CR Element <https://passagemath.org/docs/latest/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_CR_element.html>`_
  * `p-adic ZZ_pX CA Element <https://passagemath.org/docs/latest/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_CA_element.html>`_
  * `p-adic ZZ_pX FM Element <https://passagemath.org/docs/latest/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_FM_element.html>`_
  * `PowComputer_ext <https://passagemath.org/docs/latest/html/en/reference/padics/sage/rings/padics/pow_computer_ext.html>`_

* `Frobenius on Monsky-Washnitzer cohomology of a hyperelliptic curve <https://passagemath.org/docs/latest/html/en/reference/arithmetic_curves/sage/schemes/hyperelliptic_curves/hypellfrob.html>`_

* see `MANIFEST <https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-ntl/MANIFEST.in>`_
