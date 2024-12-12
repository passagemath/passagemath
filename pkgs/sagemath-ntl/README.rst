==============================================================================
 passagemath: Computational Number Theory with NTL
==============================================================================

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


About this pip-installable source distribution
----------------------------------------------

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
