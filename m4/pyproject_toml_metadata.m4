dnl Standard metadata of SageMath distribution packages
dnl
license = "GPL-2.0-or-later"
authors = [{name = "The Sage Developers", email = "sage-support@googlegroups.com"}]
maintainers = [
    {name = "Matthias Köppe"},
    {name = "passagemath contributors"},
]
classifiers = [
    "Development Status :: 6 - Mature",
    "Intended Audience :: Education",
    "Intended Audience :: Science/Research",
    "Operating System :: POSIX",
    "Operating System :: POSIX :: Linux",
    "Operating System :: MacOS :: MacOS X",
    "Programming Language :: Python :: 3 :: Only",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Programming Language :: Python :: 3.13",
    "Programming Language :: Python :: 3.14",
    "Programming Language :: Python :: Implementation :: CPython",
    "Topic :: Scientific/Engineering :: Mathematics",
]
requires-python = ">=3.11, <3.15"

[project.urls]
"release notes" = "https://github.com/passagemath/passagemath/releases"
"repo (upstream)" = "https://github.com/sagemath/sage"
"repo" = "https://github.com/passagemath/passagemath"
documentation = "https://passagemath.org/docs/latest"
"homepage (upstream)" = "https://www.sagemath.org"
"discourse" = "https://passagemath.discourse.group"
"tracker (upstream)" = "https://github.com/sagemath/sage/issues"
"tracker" = "https://github.com/passagemath/passagemath/issues"

[tool.uv.sources]
passagemath-bootstrap = { workspace = true}
passagemath-conf = { workspace = true }
passagemath-setup = { workspace = true }
passagemath-docbuild = { workspace = true }
passagemath-sws2rst = { workspace = true }
#
passagemath-benzene = { workspace = true }
passagemath-bliss = { workspace = true }
passagemath-brial = { workspace = true }
passagemath-buckygen = { workspace = true }
passagemath-categories = { workspace = true }
passagemath-cddlib = { workspace = true }
passagemath-cliquer = { workspace = true }
passagemath-cmr = { workspace = true }
passagemath-combinat = { workspace = true }
passagemath-coxeter3 = { workspace = true }
passagemath-database-cremona-ellcurve = { workspace = true }
passagemath-database-cunningham = { workspace = true }
passagemath-database-jones-numfield = { workspace = true }
passagemath-database-kohel = { workspace = true }
passagemath-database-mutation-class = { workspace = true }
passagemath-database-odlyzko-zeta = { workspace = true }
passagemath-database-polytopes-4d = { workspace = true }
passagemath-database-stein-watkins = { workspace = true }
passagemath-database-stein-watkins-mini = { workspace = true }
passagemath-database-symbolic-data = { workspace = true }
passagemath-doc-html = { workspace = true }
passagemath-doc-pdf = { workspace = true }
passagemath-ecl = { workspace = true }
passagemath-eclib = { workspace = true }
passagemath-environment = { workspace = true }
passagemath-flint = { workspace = true }
passagemath-fricas = { workspace = true }
passagemath-frobby = { workspace = true }
passagemath-gap = { workspace = true }
passagemath-gap-pkg-agt-data = { workspace = true }
passagemath-gap-pkg-caratinterface = { workspace = true }
passagemath-gap-pkg-cddinterface = { workspace = true }
passagemath-gap-pkg-ctbllib-data = { workspace = true }
passagemath-gap-pkg-curlinterface = { workspace = true }
passagemath-gap-pkg-difsets-data = { workspace = true }
passagemath-gap-pkg-factint-data = { workspace = true }
passagemath-gap-pkg-float = { workspace = true }
passagemath-gap-pkg-irredsol-data = { workspace = true }
passagemath-gap-pkg-normalizinterface = { workspace = true }
passagemath-gap-pkg-numericalsgps-data = { workspace = true }
passagemath-gap-pkg-perfgrp-data = { workspace = true }
passagemath-gap-pkg-primgrp-data = { workspace = true }
passagemath-gap-pkg-rcwa-data = { workspace = true }
passagemath-gap-pkg-semigroups = { workspace = true }
passagemath-gap-pkg-sglppow-data = { workspace = true }
passagemath-gap-pkg-simpcomp-data = { workspace = true }
passagemath-gap-pkg-smallgrp-data = { workspace = true }
passagemath-gap-pkg-smallsemi-data = { workspace = true }
passagemath-gap-pkg-sonata-data = { workspace = true }
passagemath-gap-pkg-tomlib-data = { workspace = true }
passagemath-gap-pkg-transgrp-data = { workspace = true }
passagemath-gap-pkg-unitlib-data = { workspace = true }
passagemath-gap-pkg-yangbaxter-data = { workspace = true }
passagemath-gap3 = { workspace = true }
passagemath-gfan = { workspace = true }
passagemath-giac = { workspace = true }
passagemath-glpk = { workspace = true }
passagemath-glucose = { workspace = true }
passagemath-graphs = { workspace = true }
passagemath-graphviz = { workspace = true }
passagemath-groups = { workspace = true }
passagemath-gsl = { workspace = true }
passagemath-highs = { workspace = true }
passagemath-homfly = { workspace = true }
passagemath-iml = { workspace = true }
passagemath-kenzo = { workspace = true }
passagemath-kissat = { workspace = true }
passagemath-latte-4ti2 = { workspace = true }
passagemath-lcalc = { workspace = true }
passagemath-libbraiding = { workspace = true }
passagemath-libecm = { workspace = true }
passagemath-lie = { workspace = true }
passagemath-linbox = { workspace = true }
passagemath-lrslib = { workspace = true }
passagemath-m4ri-m4rie = { workspace = true }
passagemath-macaulay2 = { workspace = true }
passagemath-macaulay2-doc = { workspace = true }
passagemath-mathilda = { workspace = true }
passagemath-maxima = { workspace = true }
passagemath-mcqd = { workspace = true }
passagemath-meataxe = { workspace = true }
passagemath-modules = { workspace = true }
passagemath-msolve = { workspace = true }
passagemath-nauty = { workspace = true }
passagemath-ntl = { workspace = true }
passagemath-objects = { workspace = true }
passagemath-palp = { workspace = true }
passagemath-pari = { workspace = true }
passagemath-pari-elldata = { workspace = true }
passagemath-pari-galdata = { workspace = true }
passagemath-pari-galpol = { workspace = true }
passagemath-pari-nflistdata = { workspace = true }
passagemath-pari-nftables = { workspace = true }
passagemath-pari-seadata = { workspace = true }
passagemath-pari-seadata-big = { workspace = true }
passagemath-pari-seadata-small = { workspace = true }
passagemath-planarity = { workspace = true }
passagemath-plantri = { workspace = true }
passagemath-plot = { workspace = true }
passagemath-polyhedra = { workspace = true }
passagemath-polymake = { workspace = true }
passagemath-qepcad = { workspace = true }
passagemath-rankwidth = { workspace = true }
passagemath-repl = { workspace = true }
passagemath-rubiks = { workspace = true }
passagemath-schemes = { workspace = true }
passagemath-singular = { workspace = true }
passagemath-sirocco = { workspace = true }
passagemath-standard = { workspace = true }
passagemath-standard-no-symbolics = { workspace = true }
passagemath-symbolics = { workspace = true }
passagemath-sympow = { workspace = true }
passagemath-tachyon = { workspace = true }
passagemath-tdlib = { workspace = true }
passagemath-tides = { workspace = true }
passagemath-topcom = { workspace = true }
