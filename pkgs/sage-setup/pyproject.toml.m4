include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-setup"
description = "passagemath: Build system of the Sage library"
dependencies = []
dynamic = ["version"]
include(`pyproject_toml_metadata_supports_windows.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
autogen = ["jinja2"]

[tool.setuptools]
packages = [
    "sage_setup",
    "sage_setup.autogen",
    "sage_setup.autogen.interpreters",
    "sage_setup.autogen.interpreters.internal",
    "sage_setup.autogen.interpreters.internal.specs",
    "sage_setup.command",
]
include-package-data = false

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
