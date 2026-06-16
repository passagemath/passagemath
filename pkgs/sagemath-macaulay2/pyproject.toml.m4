include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_objects
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_cysignals
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-macaulay2"
description = "passagemath: Computing in commutative algebra, algebraic geometry and related fields with Macaulay2"
dependencies = [
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_flint          dnl for sage.rings.{real_arb,real_mpfi}
    SPKG_INSTALL_REQUIRES_sagemath_modules        dnl for sage.rings.real_mpfr
    SPKG_INSTALL_REQUIRES_sagemath_repl           dnl for sage_eval
    SPKG_INSTALL_REQUIRES_sagemath_macaulay2_doc
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test = [
    "passagemath-linbox",
]
#
# Runtime dependencies of M2 packages, in part per
# - PROGRAM_OPTIONS
# - OptionalComponentsPresent
#
# Bertini ... bertini
CoincidentRootLoci          = ["passagemath-qepcad"]
# DecomposableSparseSystems ... phc
# EuclideanDistanceDegree ... bertini
FourTiTwo                   = ["passagemath-latte-4ti2"]
gfanInterface               = ["passagemath-gfan"]
MatchingFields              = ["passagemath-latte-4ti2"]
MonomialAlgebras            = ["passagemath-latte-4ti2"]
# MonomialIntegerPrograms ... scip
Msolve                      = ["passagemath-msolve"]
Nauty                       = ["passagemath-nauty"]
NautyGraphs                 = ["passagemath-nauty"]
# NCAlgebra ... bergman
# Normaliz ... normaliz (executable)
# NumericalSchubertCalculus ... phc
# NumericalAlgebraicGeometry ... bertini
Oscillators                 = ["passagemath-nauty"]
# PHCpack ... phc
PhylogeneticTrees           = ["passagemath-latte-4ti2"]
Polyhedra                   = ["passagemath-latte-4ti2", "passagemath-topcom"]
Polymake                    = ["passagemath-polymake"]
Posets                      = ["passagemath-latte-4ti2"]
# RInterface ... R
StatePolytope               = ["passagemath-polymake"]
Topcom                      = ["passagemath-topcom"]
Triangulations              = ["passagemath-topcom"]
Tropical                    = ["passagemath-gfan"]
TropicalToric               = ["passagemath-gfan"]
Valuations                  = ["passagemath-gfan"]
WhitneyStratifications      = ["passagemath-msolve"]
#
# Jupyter
#
jupyterkernel = [
    SPKG_INSTALL_REQUIRES_sagemath_macaulay2_jupyterkernel
]
jupyterlab      = [
    "passagemath-macaulay2[jupyterkernel]",
    SPKG_INSTALL_REQUIRES_jupyterlab
]
notebook        = [
    "passagemath-macaulay2[jupyterkernel]",
    SPKG_INSTALL_REQUIRES_notebook
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
]

host-requires = [
  "pkg:generic/macaulay2",
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
