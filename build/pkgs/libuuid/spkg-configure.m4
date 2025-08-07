SAGE_SPKG_CONFIGURE([libuuid], [dnl
    sage_spkg_install_libuuid=yes
    AC_CHECK_HEADER(uuid/uuid.h, [dnl
        AC_CHECK_LIB([uuid], [uuid_generate], [dnl
            sage_spkg_install_libuuid=no
        ])
    ])
], [dnl REQUIRED-CHECK
  AS_CASE([$host],
    [*-*-linux*], [],
    [AS_VAR_SET([SPKG_REQUIRE], [no])])
])
