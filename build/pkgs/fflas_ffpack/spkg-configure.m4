SAGE_SPKG_CONFIGURE([fflas_ffpack], [
  SAGE_SPKG_DEPCHECK([givaro gmp openblas], [
    # If our dependencies come from the system, then we can use
    # the system fflas-ffpack, too. Use pkg-config to find a
    # recentish version, if there is one.
    PKG_CHECK_MODULES([FFLAS_FFPACK],
                      [fflas-ffpack >= 2.5.0],dnl The version test is refined in linbox/spkg-configure.m4
                      [sage_spkg_install_fflas_ffpack=no],
                      [sage_spkg_install_fflas_ffpack=yes])
  ])
])
