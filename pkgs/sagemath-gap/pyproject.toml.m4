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
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_pexpect
    SPKG_INSTALL_REQUIRES_sage_conf
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_categories
    SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_factint_data
    SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_primgrp_data
    SPKG_INSTALL_REQUIRES_sagemath_gap_pkg_smallgrp_data
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test            = ["passagemath-repl"]

# GAP packages
# - external dependencies per 'ExternalConditions' in PackageInfo.g
# - dependencies on packages with external dependencies per 'NeededOtherPackages' in PackageInfo.g
4ti2interface   = ["passagemath-latte-4ti2"]
aclib           = ["passagemath-gap[polycyclic]"]
agt             = ["passagemath-gap-pkg-agt-data"]
alnuth          = ["passagemath-pari"]
corefreesub     = ["passagemath-gap[polycyclic]"]
cryst           = ["passagemath-gap[polycyclic]"]
crystcat        = ["passagemath-gap[cryst]"]
ctbllib         = ["passagemath-gap-pkg-ctbllib-data"]
cubefree        = ["passagemath-gap[grpconst,polycyclic]"]
deepthought     = ["passagemath-gap[polycyclic]"]
difsets         = ["passagemath-gap-pkg-difsets-data"]
fr              = ["passagemath-gap[polycyclic]"]
fwtree          = ["passagemath-gap[polycyclic]"]
grpconst        = ["passagemath-gap[irredsol]"]
guarana         = ["passagemath-gap[polenta]"]
hap             = ["passagemath-gap[polycyclic,crystcat,aclib,nq]"]
hapcryst        = ["passagemath-gap[polycyclic,aclib,cryst,hap,polymaking]"]
help            = ["passagemath-gap[ctbllib]"]
irredsol        = ["passagemath-gap-pkg-irredsol-data"]
lpres           = ["passagemath-gap[polycyclic]"]
modisom         = ["passagemath-gap[polycyclic]"]
nilmat          = ["passagemath-gap[polenta]"]
nq              = ["passagemath-gap[polycyclic]"]
polenta         = ["passagemath-gap[polycyclic,alnuth,radiroot]"]
polycyclic      = ["passagemath-gap[alnuth]"]
polymaking      = [SPKG_INSTALL_REQUIRES_jupymake]
radiroot        = ["passagemath-gap[alnuth]"]
rcwa            = ["passagemath-gap-pkg-rcwa-data", "passagemath-gap[resclasses]"]
resclasses      = ["passagemath-gap[polycyclic]"]
semigroups      = ["passagemath-gap-pkg-semigroups"]
singular        = ["passagemath-singular"]
smallsemi       = ["passagemath-gap-pkg-smallsemi-data"]
symbcompcc      = ["passagemath-gap[polycyclic]"]
tomlib          = ["passagemath-gap-pkg-tomlib-data"]
transgrp        = ["passagemath-gap-pkg-transgrp-data"]
xmod            = ["passagemath-gap[hap]"]
unitlib         = ["passagemath-gap-pkg-unitlib-data"]
yangbaxter      = ["passagemath-gap-pkg-yangbaxter-data", "passagemath-gap[cryst]"]

# Jupyter
jupyterkernel   = ["passagemath-gap-pkg-jupyterkernel"]
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
    "passagemath-pari",
    "passagemath-singular",
]

[tool.cibuildwheel.linux]
# Unfortunately CIBW_REPAIR_WHEEL_COMMAND does not expand {project} (and other placeholders),
# so there is no clean way to refer to the repair_wheel.py script
# https://github.com/pypa/cibuildwheel/issues/1931
repair-wheel-command = [
    'python3 -m pip install passagemath-conf auditwheel',
    'python3 pkgs/sagemath-gap/repair_wheel.py {wheel}',
    'auditwheel repair -w {dest_dir} {wheel}',
]
[tool.cibuildwheel.macos]
repair-wheel-command = [
    'python3 -m pip install passagemath-conf auditwheel',
    'python3 pkgs/sagemath-gap/repair_wheel.py {wheel}',
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
