include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
# sage_conf is needed for library name of the flint library.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_numpy
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_sagemath_ntl
    SPKG_INSTALL_REQUIRES_sagemath_pari
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cypari
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_pkgconfig
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-flint"
description = "passagemath: Fast computations with MPFI and FLINT"
dependencies = [
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_ntl
    SPKG_INSTALL_REQUIRES_numpy
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test = [
     "passagemath-repl",
     "passagemath-modules",
]

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
  "pkg:generic/flint",
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
