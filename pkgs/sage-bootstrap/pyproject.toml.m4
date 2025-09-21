include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-bootstrap"
description = "passagemath: Package database"
readme = "README.rst"
dnl Not including the standard metadata from pyproject_toml_metadata_supports_windows.m4
dnl because passagemath-bootstrap is GPL v3+.
license = "GPL-3.0-or-later"
authors = [
    {name = "Volker Braun", email = "vbraun.name@gmail.com"},
    {name = "The Sage Developers", email = "sage-support@googlegroups.com"},
]
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
requires-python = ">=2.7, !=3.0.*, !=3.1.*, !=3.2.*, !=3.3.*, <3.15"
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

[tool.setuptools]
packages = [
    'sage_bootstrap',
    'sage_bootstrap.compat',
    'sage_bootstrap.download',
    'sage_bootstrap.uncompress',
    'sage_root',
]
script-files = [
    'bin/sage-download-file',
    'bin/sage-get-system-packages',
    'bin/sage-guess-package-system',
    'bin/sage-package',
    'bin/sage-print-system-package-command',
    'bin/sage-spkg-info',
    'bin/sage-uncompress-spkg',
]
include-package-data = false

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
