include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_meson_python
    SPKG_INSTALL_REQUIRES_sage_docbuild
    SPKG_INSTALL_REQUIRES_sphinx
    SPKG_INSTALL_REQUIRES_sphinx_copybutton
    SPKG_INSTALL_REQUIRES_sphinx_inline_tabs
    SPKG_INSTALL_REQUIRES_furo
    SPKG_INSTALL_REQUIRES_jupyter_sphinx
    SPKG_INSTALL_REQUIRES_jupyterlite_sphinx
    SPKG_INSTALL_REQUIRES_sagelib
]
build-backend = 'mesonpy'

[project]
name = "passagemath-doc-pdf"
description = "passagemath: Documentation in PDF format"
dependencies = []
license = "GPL-2.0-or-later AND CC-BY-SA-3.0"
authors = [{name = "The Sage Developers", email = "sage-support@googlegroups.com"}]
maintainers = [
    {name = "Matthias Köppe"},
    {name = "passagemath contributors"},
]
classifiers = [
    "Development Status :: 6 - Mature",
    "Intended Audience :: Education",
    "Intended Audience :: Science/Research",
    "Programming Language :: Python :: 3 :: Only",
    "Topic :: Scientific/Engineering :: Mathematics",
]
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

[project.readme]
file = "README.rst"
content-type = "text/x-rst"
