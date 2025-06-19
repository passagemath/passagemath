SAGE_SPKG_CONFIGURE([m4ri], [dnl
    SAGE_SPKG_DEPCHECK([libpng], [dnl
        PKG_CHECK_MODULES([M4RI], [m4ri >= 20250128], [dnl
           AC_MSG_CHECKING([whether m4ri.pc is sane])
           AS_CASE(["$M4RI_CFLAGS"],
                   [*@SIMD_CFLAGS@*], [dnl
                       AC_MSG_RESULT([no, contaminated with SIMD_CFLAGS])
                       sage_spkg_install_m4ri=yes
                   ], [dnl
                       AC_MSG_RESULT([yes])
                   ])
        ], [dnl
           sage_spkg_install_m4ri=yes
        ])
    ])
])
