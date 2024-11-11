include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
#
# Note we include numpy here to build some modules that cimport numpy,
# but it is not part of the install-requires.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_jinja2
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_mpmath
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_numpy
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-modules"
description = "passagemath: Vectors, matrices, tensors, vector spaces, affine spaces, modules and algebras, additive groups, quadratic forms, homology, coding theory, matroids"
dependencies = [
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_mpmath
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test    = ["passagemath-repl"]

# extras by packages
flint   = ["passagemath-flint"]
gsl     = []  # No extra needed
linbox  = ["passagemath-linbox"]
m4ri    = ["passagemath-modules[linbox]"]
m4rie   = ["passagemath-modules[linbox]"]
meataxe = ["passagemath-meataxe"]
mpfi    = ["passagemath-modules[flint]"]
mpfr    = []  # No extra needed
mpmath  = []  # No extra needed
ntl     = ["passagemath-ntl"]
numpy   = [SPKG_INSTALL_REQUIRES_numpy]
pari    = ["passagemath-pari"]

# extras by rings
RDF     = ["passagemath-modules[numpy]"]
CDF     = ["passagemath-modules[numpy]"]
RR      = []  # No extra needed
CC      = []  # No extra needed
RIF     = ["passagemath-modules[flint]"]
CIF     = ["passagemath-modules[flint]"]
RBF     = ["passagemath-modules[flint]"]
CBF     = ["passagemath-modules[flint]"]
GF      = ["passagemath-modules[pari]"]
GF2     = ["passagemath-modules[m4ri]"]
GF2e    = ["passagemath-modules[m4rie]"]
GF2n    = ["passagemath-modules[m4rie]"]
GFpn    = ["passagemath-modules[meataxe]"]
QQbar   = ["passagemath-modules[NumberField]"]
AA      = ["passagemath-modules[NumberField]"]
UCF     = ["passagemath-modules[gap]"]
Zp      = ["passagemath-modules[pari]"]
Qp      = ["passagemath-modules[Zp]"]
Zq      = ["passagemath-modules[Zp]"]
Qq      = ["passagemath-modules[Zp]"]
FiniteField     = ["passagemath-modules[GF]"]
NumberField     = ["passagemath-modules[flint]"]
QuadraticField  = ["passagemath-modules[NumberField]"]
CyclotomicField = ["passagemath-modules[NumberField]"]

# extras by features
padics      = ["passagemath-modules[Zp]"]

# the whole package
standard    = ["passagemath-modules[invariant,combinat,padics,NumberField,FiniteField,m4ri,m4rie,flint,linbox,numpy,mpfi,ntl,pari]"]

[tool.setuptools]
include-package-data = false

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}

[external]
# External dependencies in the format proposed by https://peps.python.org/pep-0725
build-requires = [
  "virtual:compiler/c",
  "virtual:compiler/cpp",
  "pkg:generic/pkg-config",
]

host-requires = [
  "pkg:generic/gmp",
  "pkg:generic/gsl",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
