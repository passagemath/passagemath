include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sagemath_environment
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-polymake"
description = "passagemath: Polyhedral geometry with polymake"
dependencies = [
    SPKG_INSTALL_REQUIRES_pexpect
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test = [
    "passagemath-repl",
    "passagemath-polyhedra",
]

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
  "pkg:generic/polymake",
]

host-requires = [
  "pkg:generic/polymake",
]

dependencies = [
]
