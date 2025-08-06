SAGE_SPKG_CONFIGURE([libuuid], [dnl
    sage_spkg_install_uuid=yes
    AC_CHECK_HEADER(uuid/uuid.h, [dnl
        AC_CHECK_LIB([uuid], [uuid_generate], [dnl
            sage_spkg_install_uuid=no
        ])
    ])
])
