include(`sage_spkg_versions_toml.m4')dnl' -*- conf-toml -*-
[build-system]
# Minimum requirements for the build system to execute.
requires = [
    SPKG_INSTALL_REQUIRES_setuptools
    SPKG_INSTALL_REQUIRES_sage_setup
    SPKG_INSTALL_REQUIRES_pkgconfig
    SPKG_INSTALL_REQUIRES_sagemath_environment
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_sagemath_polyhedra
    SPKG_INSTALL_REQUIRES_sagemath_flint
    SPKG_INSTALL_REQUIRES_scipy
    SPKG_INSTALL_REQUIRES_cython
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_memory_allocator
]
build-backend = "setuptools.build_meta"

[project]
name = "passagemath-schemes"
description = "passagemath: Schemes, varieties, elliptic curves, algebraic Riemann surfaces, modular forms, arithmetic dynamics"
dependencies = [
    SPKG_INSTALL_REQUIRES_gmpy2
    SPKG_INSTALL_REQUIRES_cysignals
    SPKG_INSTALL_REQUIRES_fpylll
    SPKG_INSTALL_REQUIRES_memory_allocator
    SPKG_INSTALL_REQUIRES_scipy
    SPKG_INSTALL_REQUIRES_sagemath_modules
    SPKG_INSTALL_REQUIRES_sagemath_flint
    SPKG_INSTALL_REQUIRES_sagemath_polyhedra
    SPKG_INSTALL_REQUIRES_sagemath_singular
]
dynamic = ["version"]
include(`pyproject_toml_metadata.m4')dnl'

[project.readme]
file = "README.rst"
content-type = "text/x-rst"

[project.optional-dependencies]
test    = ["passagemath-repl"]

# extras by packages (same as sagemath-modules)
flint   = []  # No extra needed
fpylll  = []  # No extra needed
gsl     = []  # No extra needed
linbox  = ["passagemath-linbox"]
m4ri    = ["passagemath-modules[linbox]"]
m4rie   = ["passagemath-modules[linbox]"]
meataxe = ["passagemath-meataxe"]
mpfi    = ["passagemath-modules[flint]"]
mpfr    = []  # No extra needed
mpmath  = []  # No extra needed
ntl     = ["passagemath-ntl"]
numpy   = [SPKG_INSTALL_REQUIRES_numpy]
pari    = ["passagemath-pari"]
primecountpy = [SPKG_INSTALL_REQUIRES_primecountpy]

# extras by packages (specific to sagemath-schemes)

eclib   = ["passagemath-eclib"]
msolve  = ["passagemath-msolve"]
qepcad  = ["passagemath-qepcad"]
singular = []  # no extra needed
sympow  = ["passagemath-sympow"]

# extras by rings; same as in sagemath-modules
RDF     = ["passagemath-schemes[numpy]"]
CDF     = ["passagemath-schemes[numpy]"]
RR      = []  # no extra needed
CC      = []  # no extra needed
RIF     = []
CIF     = []
RBF     = ["passagemath-schemes[flint]"]
CBF     = ["passagemath-schemes[flint]"]
GF      = ["passagemath-schemes[pari]"]
GF2     = ["passagemath-schemes[m4ri]"]
GF2e    = ["passagemath-schemes[m4rie]"]
GF2n    = ["passagemath-schemes[m4rie]"]
GFpn    = ["passagemath-schemes[meataxe]"]
QQbar   = ["passagemath-schemes[NumberField]"]
AA      = ["passagemath-schemes[NumberField]"]
UCF     = ["passagemath-schemes[NumberField]"]
Zp      = []  # FIXME
Qp      = ["passagemath-schemes[Zp]"]
Zq      = ["passagemath-schemes[Zp]"]
Qq      = ["passagemath-schemes[Zp]"]
FiniteField     = ["passagemath-schemes[GF]"]
NumberField     = []  # FIXME
QuadraticField  = ["passagemath-schemes[NumberField]"]
CyclotomicField = ["passagemath-schemes[NumberField]"]

# extras by features
toric           = ["passagemath-polyhedra",
                   "passagemath-graphs"]
padics          = ["passagemath-schemes[Zp]"]

# the whole package
standard        = ["passagemath-schemes[toric,padics,NumberField,FiniteField,flint,linbox,mpfi,ntl,numpy,pari,singular,eclib,sympow]"]

[tool.cibuildwheel.linux]
# Unfortunately CIBW_REPAIR_WHEEL_COMMAND does not expand {project} (and other placeholders),
# so there is no clean way to refer to the repair_wheel.py script
# https://github.com/pypa/cibuildwheel/issues/1931
repair-wheel-command = [
    'python3 -m pip install passagemath-conf auditwheel',
    'python3 pkgs/sagemath-schemes/repair_wheel.py {wheel}',
    'auditwheel repair -w {dest_dir} {wheel}',
]
[tool.cibuildwheel.macos]
repair-wheel-command = [
    'python3 -m pip install passagemath-conf auditwheel',
    'python3 pkgs/sagemath-schemes/repair_wheel.py {wheel}',
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
  "pkg:generic/gmp",
  "pkg:generic/mpc",
  "pkg:generic/mpfr",
]

dependencies = [
]
