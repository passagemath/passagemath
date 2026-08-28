include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_pkgconfig
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-gap"
description = "passagemath: Computational Group Theory with GAP"
dependencies = [
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_dot2tex
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_pexpect
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_factint_data
    SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_primgrp_data
    SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_smallgrp_data
    SPKG_INSTALL_REQUIRES_sagemath_repl                         dnl Needed for GAP package RingsForHomalg
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test            = []

# GAP packages
# - external dependencies per 'ExternalConditions' in PackageInfo.g
# - dependencies on packages with external dependencies per 'NeededOtherPackages' in PackageInfo.g
4ti2interface   = [SPKG_INSTALL_REQUIRES_sagemath_latte_4ti2]
aclib           = ["passagemath-gap[polycyclic]"]
agt             = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_agt_data]
alnuth          = [SPKG_INSTALL_REQUIRES_sagemath_pari]
automata        = [SPKG_INSTALL_REQUIRES_sagemath_graphviz]
caratinterface  = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_caratinterface]
cddinterface    = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_cddinterface]
corefreesub     = ["passagemath-gap[polycyclic]",
                   SPKG_INSTALL_REQUIRES_sagemath_graphviz]
cryst           = ["passagemath-gap[polycyclic]"]
crystcat        = ["passagemath-gap[cryst]"]
ctbllib         = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_ctbllib_data]
cubefree        = ["passagemath-gap[grpconst,polycyclic]"]
curlinterface   = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_curlinterface]
deepthought     = ["passagemath-gap[polycyclic]"]
difsets         = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_difsets_data]
digraphs        = [SPKG_INSTALL_REQUIRES_sagemath_graphviz]
fining          = [SPKG_INSTALL_REQUIRES_sagemath_graphviz]
float           = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_float]
fr              = ["passagemath-gap[polycyclic]"]
fwtree          = ["passagemath-gap[polycyclic]"]
grpconst        = ["passagemath-gap[irredsol]"]
guarana         = ["passagemath-gap[polenta]"]
hap             = ["passagemath-gap[polycyclic,crystcat,aclib,nq]",
                   SPKG_INSTALL_REQUIRES_sagemath_graphviz]
hapcryst        = ["passagemath-gap[polycyclic,aclib,cryst,hap,polymaking]"]
help            = ["passagemath-gap[ctbllib]"]
irredsol        = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_irredsol_data]
lpres           = ["passagemath-gap[polycyclic]"]
modisom         = ["passagemath-gap[polycyclic]"]
nilmat          = ["passagemath-gap[polenta]"]
nq              = ["passagemath-gap[polycyclic]"]
normalizinterface = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_normalizinterface]
numericalsgps   = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_numericalsgps_data
                   SPKG_INSTALL_REQUIRES_sagemath_graphviz]
perfgrp         = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_perfgrp_data]
polenta         = ["passagemath-gap[polycyclic,alnuth,radiroot]"]
polycyclic      = ["passagemath-gap[alnuth]"]
polymaking      = [SPKG_INSTALL_REQUIRES_sagemath_polymake]
radiroot        = ["passagemath-gap[alnuth]"]
rcwa            = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_rcwa_data "passagemath-gap[resclasses]"]
resclasses      = ["passagemath-gap[polycyclic]"]
semigroups      = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_semigroups]
sglppow         = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_sglppow_data]
sgpviz          = [SPKG_INSTALL_REQUIRES_sagemath_graphviz]
simpcomp        = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_simpcomp_data]
singular        = [SPKG_INSTALL_REQUIRES_sagemath_singular]
smallsemi       = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_smallsemi_data]
sonata          = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_sonata_data]
symbcompcc      = ["passagemath-gap[polycyclic]"]
tomlib          = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_tomlib_data]
transgrp        = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_transgrp_data]
xmod            = ["passagemath-gap[hap]"]
unitlib         = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_unitlib_data]
yangbaxter      = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_yangbaxter_data "passagemath-gap[cryst]"]

# Jupyter
jupyterkernel   = [SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_jupyterkernel]
jupyterlab      = [
    "passagemath-gap[jupyterkernel]",
    SPKG_INSTALL_REQUIRES_jupyterlab
]
notebook        = [
    "passagemath-gap[jupyterkernel]",
    SPKG_INSTALL_REQUIRES_notebook
]

# Everything as in standard Sage
standard        = [
    "passagemath-gap[transgrp,ctbllib,tomlib,irredsol]",
    SPKG_INSTALL_REQUIRES_sagemath_pari
    SPKG_INSTALL_REQUIRES_sagemath_singular
]

# The full set of GAP packages shipped by the GAP distribution;
# omitted: polymaking
# omitted: jupyterkernel -- the indirect self-reference passagemath-gap-package-jupyterkernel -> passagemath-gap is problematic for tox, which tries to "install_package_deps" before installing the package.
full            = [
    "passagemath-gap[standard,4ti2interface,agt,caratinterface,cddinterface,curlinterface,difsets,normalizinterface,numericalsgps,rcwa,semigroups,sglppow,simpcomp,smallsemi,sonata,unitlib,yangbaxter]"
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
  "pkg:generic/gap",
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
