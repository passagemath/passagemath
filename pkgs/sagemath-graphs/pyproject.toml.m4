include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sage_conf
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
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sagemath_environment
]
dynamic = ["version"]
include(`pyproject_toml_metadata_supports_windows.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test        = ["passagemath-repl"]

# libraries
benzene     = ["passagemath-benzene"]
bliss       = ["passagemath-bliss"]
buckygen    = ["passagemath-buckygen"]
cliquer     = ["passagemath-cliquer"]
cmr         = ["passagemath-cmr"]
gap         = ["passagemath-gap"]
igraph      = [SPKG_INSTALL_REQUIRES_python_igraph]
mcqd        = ["passagemath-mcqd"]
nauty       = ["passagemath-nauty"]
networkx    = [SPKG_INSTALL_REQUIRES_networkx]
pari        = ["passagemath-pari"]
planarity   = ["passagemath-planarity"]
plantri     = ["passagemath-plantri"]
rankwidth   = ["passagemath-rankwidth"]
regina      = [SPKG_INSTALL_REQUIRES_regina]
rw          = ["passagemath-graphs[rankwidth]"]  # alias
tdlib       = ["passagemath-tdlib"]

# features
combinat    = ["passagemath-combinat"]
databases   = []
editor      = [SPKG_INSTALL_REQUIRES_phitigra]
groups      = ["passagemath-groups", "passagemath-graphs[nauty]"]
homology    = ["passagemath-modules"]
mip         = ["passagemath-polyhedra"]
modules     = ["passagemath-modules"]
plot        = ["passagemath-plot"]
polyhedra   = ["passagemath-polyhedra"]
repl        = ["passagemath-repl"]
sat         = ["passagemath-combinat"]

# the whole package
standard    = [
    "passagemath-graphs[combinat,databases,groups,mip,modules,planarity,polyhedra,rankwidth,repl]",
    "passagemath-plot[tachyon]",
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
  "pkg:generic/boost",
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
