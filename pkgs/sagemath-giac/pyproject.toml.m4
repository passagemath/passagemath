include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
<<<<<<< HEAD
    SPKG_INSTALL_REQUIRES_meson_python
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_pkgconfig
]
build-backend = "mesonpy"

[project]
name = "sagemath-giac"
description = "Sage: Open Source Mathematics Software: Symbolic computation with GIAC"
||||||| merged common ancestors
=======
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_pkgconfig
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-giac"
description = "passagemath: Symbolic computation with GIAC"
>>>>>>> main
dependencies = [
    SPKG_INSTALL_REQUIRES_sagemath_categories
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.optional-dependencies]
test            = [
    SPKG_INSTALL_REQUIRES_sagemath_repl
    SPKG_INSTALL_REQUIRES_sagemath_symbolics
]

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[tool.setuptools]
packages = ["sage.libs.giac"]
include-package-data = false

[tool.setuptools.package-data]
"sage.libs.giac" = ["*.pxd"]

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
  "pkg:generic/giac",
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
