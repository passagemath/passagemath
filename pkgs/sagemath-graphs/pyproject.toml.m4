include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-graphs"
description = "passagemath: Graphs, posets, hypergraphs, designs, abstract complexes, combinatorial polyhedra, abelian sandpiles, quivers"
dependencies = [
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_sagemath_categories
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test        = ["passagemath-repl"]

# libraries
bliss       = ["passagemath-bliss"]
gap         = ["passagemath-gap"]
igraph      = [SPKG_INSTALL_REQUIRES_python_igraph]
mcqd        = ["passagemath-mcqd"]
nauty       = ["passagemath-nauty"]
networkx    = [SPKG_INSTALL_REQUIRES_networkx]
pari        = ["passagemath-pari"]
planarity   = ["passagemath-planarity"]
rankwidth   = ["passagemath-rankwidth"]
rw          = ["passagemath-graphs[rankwidth]"]  # alias
tdlib       = ["passagemath-tdlib"]

# features
combinat    = ["passagemath-combinat"]
editor      = [SPKG_INSTALL_REQUIRES_phitigra]
homology    = ["passagemath-modules"]
mip         = ["passagemath-polyhedra"]
modules     = ["passagemath-modules"]
plot        = ["passagemath-plot"]
polyhedra   = ["passagemath-polyhedra"]
repl        = ["passagemath-repl"]
sat         = ["passagemath-combinat"]

standard    = ["passagemath-graphs[combinat,databases,mip,modules,planarity,plot,polyhedra,rankwidth,repl]"]

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
  "pkg:generic/boost",
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
