SAGE_SPKG_CONFIGURE([gettext], [dnl
  AC_SEARCH_LIBS([gettext], [intl], [], [sage_spkg_install_gettext=yes])
])
