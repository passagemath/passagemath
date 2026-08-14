include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_numpy
    SPKG_INSTALL_REQUIRES_cysignals
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-symbolics"
description = "passagemath: Symbolic calculus"
dependencies = [
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_numpy
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_flint
    SPKG_INSTALL_REQUIRES_sagemath_gsl
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_sagemath_ntl
    SPKG_INSTALL_REQUIRES_sympy
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
conf            = [SPKG_INSTALL_REQUIRES_sage_conf]
test            = [SPKG_INSTALL_REQUIRES_sagemath_repl]

# extras by libraries
fricas          = [SPKG_INSTALL_REQUIRES_sagemath_fricas]
giac            = [SPKG_INSTALL_REQUIRES_sagemath_giac]
ginac           = []  # no extra needed, same as pynac
mathics3        = ["mathics3"]
maxima          = [SPKG_INSTALL_REQUIRES_sagemath_maxima]
ntl             = []  # no extra needed
primecount      = [SPKG_INSTALL_REQUIRES_primecountpy]
pynac           = []  # no extra needed
singular        = [SPKG_INSTALL_REQUIRES_sagemath_singular]
sympy           = []  # no extra needed

# extras by other features
plot            = [SPKG_INSTALL_REQUIRES_sagemath_plot]

standard        = ["passagemath-symbolics[maxima,primecount,singular,test]"]

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
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
  "pkg:generic/singular",  # factory only
]

dependencies = [
]
