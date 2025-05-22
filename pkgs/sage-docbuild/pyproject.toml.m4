include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-docbuild"
description = "passagemath: Build system of the Sage documentation"
dependencies = [
    SPKG_INSTALL_REQUIRES_sphinx
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[tool.setuptools]
packages = [
    "sage_docbuild",
    "sage_docbuild.ext",
]
include-package-data = false

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
