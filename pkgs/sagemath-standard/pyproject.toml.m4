include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-standard"
description = "passagemath: Standard Python Library"
dependencies = [
    SPKG_INSTALL_REQUIRES_sagemath_standard_no_symbolics
    SPKG_INSTALL_REQUIRES_sagemath_symbolics
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
r = [SPKG_INSTALL_REQUIRES_rpy2]
bliss = [
    'sagemath-bliss',
]
brial = [
    'sagemath-brial',
]
coxeter3 = [
    'sagemath-coxeter3',
]
mcqd = [
    'sagemath-mcqd',
]
meataxe = [
    'sagemath-meataxe',
]
sirocco = [
    'sagemath-sirocco',
]
tdlib = [
    'sagemath-tdlib',
]

[tool.setuptools]
license-files = ["LICENSE.txt"]
include-package-data = false
packages = []

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
