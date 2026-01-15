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
    SPKG_INSTALL_REQUIRES_sagelib
    SPKG_INSTALL_REQUIRES_sagemath_cliquer
    SPKG_INSTALL_REQUIRES_sagemath_cmr
    SPKG_INSTALL_REQUIRES_sagemath_fricas
    SPKG_INSTALL_REQUIRES_sagemath_frobby
    SPKG_INSTALL_REQUIRES_sagemath_gfan
    SPKG_INSTALL_REQUIRES_sagemath_giac
    SPKG_INSTALL_REQUIRES_sagemath_kenzo
    SPKG_INSTALL_REQUIRES_sagemath_latte_4ti2
    SPKG_INSTALL_REQUIRES_sagemath_msolve
    SPKG_INSTALL_REQUIRES_sagemath_polymake
    SPKG_INSTALL_REQUIRES_sagemath_qepcad
    SPKG_INSTALL_REQUIRES_sagemath_rankwidth
    SPKG_INSTALL_REQUIRES_sagemath_rubiks
    SPKG_INSTALL_REQUIRES_sagemath_sympow
    SPKG_INSTALL_REQUIRES_sagemath_database_cunningham
    SPKG_INSTALL_REQUIRES_sagemath_database_jones_numfield
    SPKG_INSTALL_REQUIRES_sagemath_database_kohel
    SPKG_INSTALL_REQUIRES_sagemath_database_odlyzko_zeta
    SPKG_INSTALL_REQUIRES_sagemath_database_stein_watkins_mini
    SPKG_INSTALL_REQUIRES_sagemath_database_symbolic_data
]
build-backend = 'mesonpy'

[project]
name = "passagemath-doc-html"
description = "passagemath: Documentation in HTML format"
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
