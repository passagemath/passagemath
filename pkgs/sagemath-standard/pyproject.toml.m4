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
cliquer     = ["passagemath-cliquer"]
cmr         = ["passagemath-cmr"]
coxeter3    = ["passagemath-coxeter3"]
cvxopt      = [SPKG_INSTALL_REQUIRES_cvxopt]
cvxpy       = [SPKG_INSTALL_REQUIRES_cvxpy]
database-cremona-ellcurve   = ["passagemath-database-cremona-ellcurve"]
database-cubic-hecke        = [SPKG_INSTALL_REQUIRES_database_cubic_hecke]
database-cunningham         = ["passagemath-database-cunningham"]
database-jones-numfield     = ["passagemath-database-jones-numfield"]
database-knotinfo           = [SPKG_INSTALL_REQUIRES_database_knotinfo]
database-kohel              = ["passagemath-database-kohel"]
database-matroids           = [SPKG_INSTALL_REQUIRES_matroid_database]
database-mutation-class     = ["passagemath-database-mutation-class"]
database-odlyzko-zeta       = ["passagemath-database-odlyzko-zeta"]
database-polytopes-4d       = ["passagemath-database-polytopes-4d"]
database-stein-watkins      = ["passagemath-database-stein-watkins"]
database-stein-watkins-mini = ["passagemath-database-stein-watkins-mini"]
database-symbolic-data      = ["passagemath-database-symbolic-data"]
eclib       = ["passagemath-eclib"]
fricas      = ["passagemath-fricas"]
frobby      = ["passagemath-frobby"]
gcg         = [SPKG_INSTALL_REQUIRES_pygcgopt]
gfan        = ["passagemath-gfan"]
giac        = ["passagemath-giac"]
glucose     = ["passagemath-glucose"]
highs       = ["passagemath-highs"]
igraph      = [SPKG_INSTALL_REQUIRES_python_igraph]
jupyterlab  = [SPKG_INSTALL_REQUIRES_jupyterlab]
kenzo       = ["passagemath-kenzo"]
khoca       = [SPKG_INSTALL_REQUIRES_khoca]
kissat      = ["passagemath-kissat"]
latte       = ["passagemath-latte-4ti2"]  # alias
latte_int   = ["passagemath-latte-4ti2"]
lrslib      = ["passagemath-lrslib"]
macaulay2   = ["passagemath-macaulay2"]
marimo      = [SPKG_INSTALL_REQUIRES_marimo]
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
polymake    = ["passagemath-polymake"]
qepcad      = ["passagemath-qepcad"]
r           = [SPKG_INSTALL_REQUIRES_rpy2]
rankwidth   = ["passagemath-rankwidth"]
regina      = [SPKG_INSTALL_REQUIRES_regina]
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
packages = [
    "passagemath_standard",
]

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
