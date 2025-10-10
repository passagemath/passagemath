SAGE_SPKG_CONFIGURE([gettext], [dnl
    AC_CHECK_LIB([intl], [main], [], [sage_spkg_install_gettext=yes])
])
