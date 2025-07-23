SAGE_SPKG_CONFIGURE([patchelf], [dnl
  AC_PATH_PROG(PATCHELF, patchelf)
  AS_IF([test -z "${PATCHELF}"], [sage_spkg_install_patchelf=yes])
], [dnl REQUIRED-CHECK
  AS_CASE([$host],
    [*-*-linux*], [],
    [AS_VAR_SET([SPKG_REQUIRE], [no])])
])
