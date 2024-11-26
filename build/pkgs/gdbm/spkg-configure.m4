SAGE_SPKG_CONFIGURE([gdbm], [dnl
    AC_CHECK_LIB([gdbm], [gdbm_open], [], [dnl
        sage_spkg_install_gdbm=yes
    ])
])
