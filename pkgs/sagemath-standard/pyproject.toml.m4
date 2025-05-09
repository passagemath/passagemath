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
4ti2        = ["passagemath-latte-4ti2"]
benzene     = ["passagemath-benzene"]
bliss       = ["passagemath-bliss"]
brial       = ["passagemath-brial"]
buckygen    = ["passagemath-buckygen"]
cddlib      = ["passagemath-cddlib"]
cliquer     = ["passagemath-cliquer"]
cmr         = ["passagemath-cmr"]
coxeter3    = ["passagemath-coxeter3"]
cvxopt      = [SPKG_INSTALL_REQUIRES_cvxopt]
cvxpy       = [SPKG_INSTALL_REQUIRES_cvxpy]
eclib       = ["passagemath-eclib"]
frobby      = ["passagemath-frobby"]
gfan        = ["passagemath-gfan"]
giac        = ["passagemath-giac"]
glucose     = ["passagemath-glucose"]
igraph      = [SPKG_INSTALL_REQUIRES_python_igraph]
jupyterlab  = [SPKG_INSTALL_REQUIRES_jupyterlab]
kenzo       = ["passagemath-kenzo"]
kissat      = ["passagemath-kissat"]
latte       = ["passagemath-latte-4ti2"]  # alias
latte_int   = ["passagemath-latte-4ti2"]
lrcalc      = [SPKG_INSTALL_REQUIRES_lrcalc_python]
lrslib      = ["passagemath-lrslib"]
macaulay2   = ["passagemath-macaulay2"]
mcqd        = ["passagemath-mcqd"]
meataxe     = ["passagemath-meataxe"]
msolve      = ["passagemath-msolve"]
nauty       = ["passagemath-nauty"]
networkx    = [SPKG_INSTALL_REQUIRES_networkx]
normaliz    = [SPKG_INSTALL_REQUIRES_pynormaliz]
notebook    = [SPKG_INSTALL_REQUIRES_notebook]
palp        = ["passagemath-palp"]
planarity   = ["passagemath-planarity"]
plantri     = ["passagemath-plantri"]
polymake    = [SPKG_INSTALL_REQUIRES_jupymake]
qepcad      = ["passagemath-qepcad"]
r           = [SPKG_INSTALL_REQUIRES_rpy2]
rankwidth   = ["passagemath-rankwidth"]
rubiks      = ["passagemath-rubiks"]
rw          = ["passagemath-rankwidth"]  # alias
scip        = [SPKG_INSTALL_REQUIRES_pyscipopt]
sirocco     = ["passagemath-sirocco"]
sympow      = ["passagemath-sympow"]
tdlib       = ["passagemath-tdlib"]
topcom      = ["passagemath-topcom"]

[tool.setuptools]
license-files = ["LICENSE.txt"]
include-package-data = false
packages = []

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
