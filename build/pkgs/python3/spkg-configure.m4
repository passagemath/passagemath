SAGE_SPKG_CONFIGURE([python3], [
   AC_ARG_WITH([python],
               [AS_HELP_STRING([--with-python=''],
               [full path to a Python 3 to use for Sage venv, e.g. --with-python=/usr/opt/python3.42])])
   ac_path_PYTHON3="$with_python"

   SAGE_SPKG_DEPCHECK([sqlite libpng bzip2 xz libffi], [
      dnl Check if we can do venv with a system python3
      dnl instead of building our own copy.
      check_modules="sqlite3, ctypes, math, hashlib, crypt, readline, socket, zlib, distutils.core"
      m4_pushdef([MIN_VERSION], [3.7.0])
      m4_pushdef([LT_VERSION],  [3.9.0])
      AC_CACHE_CHECK([for python3 >= ]MIN_VERSION[, < ]LT_VERSION[ with modules $check_modules], [ac_cv_path_PYTHON3], [
        AS_IF([test x"$ac_path_PYTHON3" != x], [dnl checking explicitly specified $with_python
           AC_MSG_RESULT([])
           SAGE_CHECK_PYTHON_FOR_VENV([$ac_path_PYTHON3],
                                    MIN_VERSION, LT_VERSION,
                                    $check_modules, [
                    dnl It is good
                    ac_cv_path_PYTHON3="$ac_path_PYTHON3"
                    ac_path_PYTHON3_found=:
                    AC_MSG_RESULT([yes])
                    AC_MSG_CHECKING("$ac_path_PYTHON3"[ for python3 >= ]MIN_VERSION[, < ]LT_VERSION[ with modules $check_modules])
           ])
	], [dnl checking the default system python3
           AC_MSG_RESULT([])
           AC_PATH_PROGS_FEATURE_CHECK([PYTHON3], [python3], [
                SAGE_CHECK_PYTHON_FOR_VENV([$ac_path_PYTHON3],
                                           MIN_VERSION, LT_VERSION,
                                           $check_modules, [
                    dnl It is good
                    ac_cv_path_PYTHON3="$ac_path_PYTHON3"
                    ac_path_PYTHON3_found=:
                    AC_MSG_RESULT([yes])
                    dnl introduction for AC_MSG_RESULT printed by AC_CACHE_CHECK
                    AC_MSG_CHECKING([for python3 >= ]MIN_VERSION[, < ]LT_VERSION[ with modules $check_modules])
                ])
            ])
	])
      ])
      AS_IF([test -z "$ac_cv_path_PYTHON3"], [sage_spkg_install_python3=yes])
      m4_popdef([MIN_VERSION])
      m4_popdef([LT_VERSION])
    ])
],, [
    dnl PRE
], [
    dnl POST
    AS_IF([test x$sage_spkg_install_python3 = xno], [PYTHON_FOR_VENV="$ac_cv_path_PYTHON3"])
    AC_SUBST([PYTHON_FOR_VENV])

    dnl These temporary directories are created by the check above
    dnl and need to be cleaned up to prevent the "rm -f conftest*"
    dnl (that a bunch of other checks do) from emitting warnings about
    dnl conftest.dir and conftest_venv being directories.
    rm -rf conftest.dir conftest_venv
])
