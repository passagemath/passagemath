SAGE_SPKG_CONFIGURE([tomli_w], [
    sage_spkg_install_tomli_w=yes
  ], [dnl REQUIRED-CHECK
    AC_REQUIRE([SAGE_SPKG_CONFIGURE_TOX])
    dnl tomli_w is only needed when we cannot use system tox.
    AS_VAR_SET([SPKG_REQUIRE], [$sage_spkg_install_tox])
  ])
