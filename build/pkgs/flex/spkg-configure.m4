SAGE_SPKG_CONFIGURE([flex], [dnl
  AC_PATH_PROG([FLEX], [flex])
  AS_IF([test -z "$FLEX"], [dnl
    dnl No flex found
    sage_spkg_install_flex=yes
  ])
], [dnl REQUIRED-CHECK
  AC_REQUIRE([SAGE_SPKG_CONFIGURE_GCC])
  AC_REQUIRE([SAGE_SPKG_CONFIGURE_GFORTRAN])
  dnl flex is only needed if we are building gcc or gfortran.
  AS_IF([test x$sage_spkg_install_gcc = xno -a x$sage_spkg_install_gfortran = xno], [
    sage_require_flex=no
  ])
])
