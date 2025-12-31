SAGE_SPKG_CONFIGURE([primecount], [
    m4_pushdef([SAGE_PRIMECOUNT_MINVER],[7.1])
    m4_pushdef([SAGE_PRIMECOUNT_MAJOR],[7])
    m4_pushdef([SAGE_PRIMECOUNT_MINOR],[1])
    m4_pushdef([SAGE_PRIMECOUNT_LT_MAJOR],[8])
    m4_pushdef([SAGE_PRIMECOUNT_LT_MINOR],[0])
    SAGE_SPKG_DEPCHECK([primesieve], [
      dnl Checking for primecount with pkg-config
      PKG_CHECK_MODULES([PRIMECOUNT], [primecount >= ]SAGE_PRIMECOUNT_MINVER[ primecount < ]SAGE_PRIMECOUNT_LT_MAJOR[.]SAGE_PRIMECOUNT_LT_MINOR, [], [dnl
          AC_CHECK_HEADER([primecount.h], [
           AC_SEARCH_LIBS([primecount_pi], [primecount], [
             AC_MSG_CHECKING([checking primecount version directly])
             AC_RUN_IFELSE([AC_LANG_PROGRAM([
                      [#include <primecount.h>
                      ]],[[
                       if (PRIMECOUNT_VERSION_MAJOR < ]] SAGE_PRIMECOUNT_MAJOR [[ ) return 1;
                       if (PRIMECOUNT_VERSION_MAJOR == ]] SAGE_PRIMECOUNT_MAJOR [[  &&
                           PRIMECOUNT_VERSION_MINOR < ]] SAGE_PRIMECOUNT_MINOR [[ ) return 1;
                       if (PRIMECOUNT_VERSION_MAJOR > ]] SAGE_PRIMECOUNT_LT_MAJOR [[ ) return 1;
                       if (PRIMECOUNT_VERSION_MAJOR == ]] SAGE_PRIMECOUNT_LT_MAJOR [[  &&
                           PRIMECOUNT_VERSION_MINOR >= ]] SAGE_PRIMECOUNT_LT_MINOR [[ ) return 1;
                       return 0;
                      ]])],
                     [AC_MSG_RESULT([Good.])],
                     [AC_MSG_RESULT([Too old.])
                      sage_spkg_install_primecount=yes],
                     []) dnl cross-compilation - noop
           ],
              [sage_spkg_install_primecount=yes])
          ], [sage_spkg_install_primecount=yes])
      ])
    ])
    m4_popdef([SAGE_PRIMECOUNT_MINVER])
    m4_popdef([SAGE_PRIMECOUNT_MAJOR])
    m4_popdef([SAGE_PRIMECOUNT_MINOR])
    m4_popdef([SAGE_PRIMECOUNT_LT_MAJOR])
    m4_popdef([SAGE_PRIMECOUNT_LT_MINOR])
])

