SAGE_SPKG_CONFIGURE([cmake], [dnl
        dnl macaulay2 1.24.11 needs 3.24
        m4_pushdef([CMAKE_MIN_VERSION], [3.24])
        AC_CACHE_CHECK([for cmake >= ]CMAKE_MIN_VERSION, [ac_cv_path_CMAKE], [dnl
        dnl Do not accept cmake installed via https://pypi.org/project/cmake/
        dnl in the default user scheme; it will not work in our venv because
        dnl we set PYTHONUSERBASE in sage-env.
        WITH_SAGE_PYTHONUSERBASE([dnl
            AC_PATH_PROGS_FEATURE_CHECK([CMAKE], [cmake], [dnl
                cmake_version=`$ac_path_CMAKE --version 2>&1 \
                    | $SED -n -e 's/cmake version *\([[0-9]]*\.[[0-9]]*\.[[0-9]]*\)/\1/p'`
                AS_IF([test -n "$cmake_version"], [dnl
                    AX_COMPARE_VERSION([$cmake_version], [ge], CMAKE_MIN_VERSION, [dnl
                        dnl https://github.com/Macaulay2/M2/issues/3855
                        dnl https://gitlab.kitware.com/cmake/cmake/-/issues/26824
                        AX_COMPARE_VERSION([$cmake_version], [ne], [4.0.0], [dnl
                            ac_cv_path_CMAKE="$ac_path_CMAKE"
                            ac_path_CMAKE_found=:
                        ])
                    ])
                ])
            ])
        ])
        m4_popdef([CMAKE_MIN_VERSION])
    ])
    AS_IF([test -z "$ac_cv_path_CMAKE"], [sage_spkg_install_cmake=yes])
])
