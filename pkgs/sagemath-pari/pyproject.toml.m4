include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_sagemath_flint
    SPKG_INSTALL_REQUIRES_mpmath
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_pkgconfig
]
# We need access to the autogen package at build time.
# Hence we declare a custom build backend.
#build-backend = "_custom_build_meta"  # just re-exports setuptools.build_meta definitions
#backend-path = ["."]

[project]
name = "passagemath-pari"
description = "passagemath: Computational Number Theory with PARI/GP"
dependencies = [
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_conway_polynomials
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test = ["passagemath-repl"]

# PARI data packages
elldata         = ["passagemath-pari-elldata"]
galdata         = ["passagemath-pari-galdata"]
galpol          = ["passagemath-pari-galpol"]
nflistdata      = ["passagemath-pari-nflistdata"]
nftables        = ["passagemath-pari-nftables"]
seadata         = ["passagemath-pari-seadata"]
seadata-big     = ["passagemath-pari-seadata-big"]
seadata-small   = ["passagemath-pari-seadata-small"]

# Jupyter
jupyterkernel   = [
    SPKG_INSTALL_REQUIRES_ipykernel
]
jupyterlab      = [
    "passagemath-pari[jupyterkernel]",
    SPKG_INSTALL_REQUIRES_jupyterlab
]
notebook        = [
    "passagemath-pari[jupyterkernel]",
    SPKG_INSTALL_REQUIRES_notebook
]

# Everything as in standard Sage
standard        = ["passagemath-pari[galdata,seadata-small]"]

[tool.cibuildwheel.linux]
repair-wheel-command = [
    'python3 -m pip install passagemath-conf auditwheel',
    'python3 {package}/repair_wheel.py {wheel}',
    'auditwheel repair -w {dest_dir} {wheel}',
]
[tool.cibuildwheel.macos]
repair-wheel-command = [
    'python3 -m pip install passagemath-conf auditwheel',
    'python3 {package}/repair_wheel.py {wheel}',
    'delocate-wheel --require-archs {delocate_archs} -w {dest_dir} -v {wheel}',
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
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
  "pkg:generic/pari",
  "pkg:generic/givaro",
]

dependencies = [
]
