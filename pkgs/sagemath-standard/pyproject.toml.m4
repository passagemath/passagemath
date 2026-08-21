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
    SPKG_INSTALL_REQUIRES_sagemath_maxima
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
4ti2        = [SPKG_INSTALL_REQUIRES_sagemath_latte_4ti2]
benzene     = [SPKG_INSTALL_REQUIRES_sagemath_benzene]
bliss       = [SPKG_INSTALL_REQUIRES_sagemath_bliss]
brial       = [SPKG_INSTALL_REQUIRES_sagemath_brial]
buckygen    = [SPKG_INSTALL_REQUIRES_sagemath_buckygen]
cliquer     = [SPKG_INSTALL_REQUIRES_sagemath_cliquer]
cmr         = [SPKG_INSTALL_REQUIRES_sagemath_cmr]
coxeter3    = [SPKG_INSTALL_REQUIRES_sagemath_coxeter3]
cvxopt      = [SPKG_INSTALL_REQUIRES_cvxopt]
cvxpy       = [SPKG_INSTALL_REQUIRES_cvxpy]
database-cremona-ellcurve   = [SPKG_INSTALL_REQUIRES_sagemath_database_cremona_ellcurve]
database-cubic-hecke        = [SPKG_INSTALL_REQUIRES_database_cubic_hecke]
database-cunningham         = [SPKG_INSTALL_REQUIRES_sagemath_database_cunningham]
database-jones-numfield     = [SPKG_INSTALL_REQUIRES_sagemath_database_jones_numfield]
database-knotinfo           = [SPKG_INSTALL_REQUIRES_database_knotinfo]
database-kohel              = [SPKG_INSTALL_REQUIRES_sagemath_database_kohel]
database-matroids           = [SPKG_INSTALL_REQUIRES_matroid_database]
database-mutation-class     = [SPKG_INSTALL_REQUIRES_sagemath_database_mutation_class]
database-odlyzko-zeta       = [SPKG_INSTALL_REQUIRES_sagemath_database_odlyzko_zeta]
database-polytopes-4d       = [SPKG_INSTALL_REQUIRES_sagemath_database_polytopes_4d]
database-stein-watkins      = [SPKG_INSTALL_REQUIRES_sagemath_database_stein_watkins]
database-stein-watkins-mini = [SPKG_INSTALL_REQUIRES_sagemath_database_stein_watkins_mini]
database-symbolic-data      = [SPKG_INSTALL_REQUIRES_sagemath_database_symbolic_data]
eclib       = [SPKG_INSTALL_REQUIRES_sagemath_eclib]
fricas      = [SPKG_INSTALL_REQUIRES_sagemath_fricas]
frobby      = [SPKG_INSTALL_REQUIRES_sagemath_frobby]
gap3        = [SPKG_INSTALL_REQUIRES_sagemath_gap3]
gcg         = [SPKG_INSTALL_REQUIRES_pygcgopt]
gfan        = [SPKG_INSTALL_REQUIRES_sagemath_gfan]
giac        = [SPKG_INSTALL_REQUIRES_sagemath_giac]
glucose     = [SPKG_INSTALL_REQUIRES_sagemath_glucose]
graphviz    = [SPKG_INSTALL_REQUIRES_sagemath_graphviz]
highs       = [SPKG_INSTALL_REQUIRES_sagemath_highs]
igraph      = [SPKG_INSTALL_REQUIRES_python_igraph]
jupyterlab  = [SPKG_INSTALL_REQUIRES_jupyterlab]
kenzo       = [SPKG_INSTALL_REQUIRES_sagemath_kenzo]
khoca       = [SPKG_INSTALL_REQUIRES_khoca]
kissat      = [SPKG_INSTALL_REQUIRES_sagemath_kissat]
latte       = [SPKG_INSTALL_REQUIRES_sagemath_latte_4ti2]  # alias
latte_int   = [SPKG_INSTALL_REQUIRES_sagemath_latte_4ti2]
lrslib      = [SPKG_INSTALL_REQUIRES_sagemath_lrslib]
macaulay2   = [SPKG_INSTALL_REQUIRES_sagemath_macaulay2]
marimo      = [SPKG_INSTALL_REQUIRES_marimo]
mathics3    = ["mathics3"]
mcqd        = [SPKG_INSTALL_REQUIRES_sagemath_mcqd]
meataxe     = [SPKG_INSTALL_REQUIRES_sagemath_meataxe]
msolve      = [SPKG_INSTALL_REQUIRES_sagemath_msolve]
nauty       = [SPKG_INSTALL_REQUIRES_sagemath_nauty]
networkx    = [SPKG_INSTALL_REQUIRES_networkx]
normaliz    = [SPKG_INSTALL_REQUIRES_pynormaliz]
notebook    = [SPKG_INSTALL_REQUIRES_notebook]
palp        = [SPKG_INSTALL_REQUIRES_sagemath_palp]
planarity   = [SPKG_INSTALL_REQUIRES_sagemath_planarity]
plantri     = [SPKG_INSTALL_REQUIRES_sagemath_plantri]
polymake    = [SPKG_INSTALL_REQUIRES_sagemath_polymake]
qepcad      = [SPKG_INSTALL_REQUIRES_sagemath_qepcad]
r           = [SPKG_INSTALL_REQUIRES_rpy2]
rankwidth   = [SPKG_INSTALL_REQUIRES_sagemath_rankwidth]
regina      = [SPKG_INSTALL_REQUIRES_regina]
rubiks      = [SPKG_INSTALL_REQUIRES_sagemath_rubiks]
rw          = [SPKG_INSTALL_REQUIRES_sagemath_rankwidth]  # alias
scip        = [SPKG_INSTALL_REQUIRES_pyscipopt]
sirocco     = [SPKG_INSTALL_REQUIRES_sagemath_sirocco]
sympow      = [SPKG_INSTALL_REQUIRES_sagemath_sympow]
tdlib       = [SPKG_INSTALL_REQUIRES_sagemath_tdlib]
topcom      = [SPKG_INSTALL_REQUIRES_sagemath_topcom]

test        = []

[tool.setuptools]
license-files = ["LICENSE.txt"]
include-package-data = false
packages = [
    "passagemath_standard",
]

[tool.setuptools.dynamic]
version = {file = ["VERSION.txt"]}
