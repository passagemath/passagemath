include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-conf"
description = "passagemath: Confectionery and configuration module"
readme = "README.rst"
dnl Not including the standard metadata from pyproject_toml_metadata_supports_windows.m4
dnl because sage-conf is GPL v3+.
license = "GPL-3.0-or-later"
authors = [{name = "The Sage Developers", email = "sage-support@googlegroups.com"}]
maintainers = [
    {name = "Matthias Köppe"},
    {name = "passagemath contributors"},
]
classifiers = [
    "Development Status :: 6 - Mature",
    "Intended Audience :: Education",
    "Intended Audience :: Science/Research",
    "Operating System :: POSIX",
    "Operating System :: MacOS :: MacOS X",
    "Programming Language :: Python :: 3 :: Only",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
    "Programming Language :: Python :: Implementation :: CPython",
    "Topic :: Scientific/Engineering :: Mathematics",
]
requires-python = ">=3.10, <3.14"
dynamic = ["version"]

[project.urls]
"release notes" = "https://github.com/passagemath/passagemath/releases"
"repo (upstream)" = "https://github.com/sagemath/sage"
"repo" = "https://github.com/passagemath/passagemath"
documentation = "https://passagemath.org/docs/latest"
"homepage (upstream)" = "https://www.sagemath.org"
"discourse" = "https://passagemath.discourse.group"
"tracker (upstream)" = "https://github.com/sagemath/sage/issues"
"tracker" = "https://github.com/passagemath/passagemath/issues"

[project.scripts]
sage-config = "sage_conf:_main"

[tool.setuptools]
packages = ["_sage_conf"]
py-modules = ["sage_conf"]
script-files = ["bin/sage-env-config"]
include-package-data = false

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
