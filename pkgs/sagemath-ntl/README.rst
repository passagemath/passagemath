==============================================================================
 passagemath: Computational Number Theory with NTL
==============================================================================

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

This pip-installable source distribution ``sagemath-ntl`` is a small
distribution that provides modules that depend on
`NTL <https://libntl.org/>`_, the library for doing number theory.


What is included
----------------

* Computation of Bernoulli numbers modulo p:

  * `Cython wrapper for bernmm library <https://doc.sagemath.org/html/en/reference/rings_standard/sage/rings/bernmm.html>`_
  * `Bernoulli numbers modulo p <https://doc.sagemath.org/html/en/reference/rings_standard/sage/rings/bernoulli_mod_p.html>`_

* Finite fields of characteristic 2

  * `Finite fields of characteristic 2 <https://doc.sagemath.org/html/en/reference/finite_rings/sage/rings/finite_rings/finite_field_ntl_gf2e.html>`_
  * `Elements of finite fields of characteristic 2 <https://doc.sagemath.org/html/en/reference/finite_rings/sage/rings/finite_rings/element_ntl_gf2e.html>`_

* p-adic extension elements:

  * `p-adic Extension Element <https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/padic_ext_element.html#module-sage.rings.padics.padic_ext_element>`_
  * `p-adic ZZ_pX Element <https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_element.html>`_
  * `p-adic ZZ_pX CR Element <https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_CR_element.html>`_
  * `p-adic ZZ_pX CA Element <https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_CA_element.html>`_
  * `p-adic ZZ_pX FM Element <https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/padic_ZZ_pX_FM_element.html>`_
  * `PowComputer_ext <https://doc.sagemath.org/html/en/reference/padics/sage/rings/padics/pow_computer_ext.html>`_

* `Frobenius on Monsky-Washnitzer cohomology of a hyperelliptic curve <https://doc.sagemath.org/html/en/reference/arithmetic_curves/sage/schemes/hyperelliptic_curves/hypellfrob.html>`_

* see `MANIFEST <https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-ntl/MANIFEST.in>`_
