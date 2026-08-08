SAGE_SPKG_CONFIGURE([tox], [
       dnl Because of https://github.com/tox-dev/tox/issues/3238, need >=4.39.0
       m4_pushdef([TOX4_MIN_VERSION], [4.39.0])
       AC_CACHE_CHECK([for tox >= ]TOX4_MIN_VERSION, [ac_cv_path_TOX], [
         AC_PATH_PROGS_FEATURE_CHECK([TOX], [tox], [
            tox_version=$($ac_path_TOX --version 2> /dev/null | tail -n 1)
            AX_COMPARE_VERSION([$tox_version], [ge], TOX4_MIN_VERSION, [
                ac_cv_path_TOX="$ac_path_TOX"
                ac_path_TOX_found=:
            ])
         ])
       ])
       AS_IF([test -z "$ac_cv_path_TOX"],
             [sage_spkg_install_tox=yes])
       m4_popdef([TOX4_MIN_VERSION])
])
