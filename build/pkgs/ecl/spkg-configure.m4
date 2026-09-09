SAGE_SPKG_CONFIGURE([ecl], [

  # Default to installing the SPKG
  sage_spkg_install_ecl=yes

  SAGE_SPKG_DEPCHECK([gcc gc gmp], [
    AC_PATH_PROG([ECL], [ecl])
    AC_PATH_PROG([ECL_CONFIG], [ecl-config])
    AS_IF([test x$ECL != x -a x$ECL_CONFIG != x], [dnl
      # "CPPFLAGS" is not a typo, the --cflags output from
      # ecl-config typically contains -D and -I flags.
      saved_CPPFLAGS="${CPPFLAGS}"
      CPPFLAGS="${CPPFLAGS} $($ECL_CONFIG --cflags)"

      AC_LANG_PUSH([C])
      AC_RUN_IFELSE([AC_LANG_PROGRAM([[
        #include <ecl/config.h>
      ]],[[
        if (ECL_VERSION_NUMBER < 210201) { return 1; }
      ]])], [dnl
        rm -rf conftest.*
        cat > conftest.lisp <<EOF
(defun foo ()
  nil)
EOF
        AS_IF([$ECL --norc --eval '(multiple-value-bind (output-truename warnings-p failure-p) (compile-file "conftest.lisp" :system-p t) (if failure-p (quit 1) (quit)))' 2>& ]AS_MESSAGE_LOG_FD[ >&2], [dnl
          sage_spkg_install_ecl=no
        ])
      ], [dnl
        CPPFLAGS="${saved_CPPFLAGS}"
        AC_MSG_NOTICE([ecl found but too old])
      ])
      AC_LANG_POP([C])
    ])
  ])
],[],[],[
  # post-check
  if test x$sage_spkg_install_ecl = xyes; then
    AC_SUBST(SAGE_ECL_CONFIG, ['${prefix}'/bin/ecl-config])
  else
    AC_SUBST(SAGE_ECL_CONFIG, [$ECL_CONFIG])
  fi

  # Kenzo cannot yet be provided by the system, so we always use
  # the SAGE_LOCAL path for now.
  AC_SUBST(SAGE_KENZO_FAS, ['${prefix}'/lib/ecl/kenzo.fas])
])
