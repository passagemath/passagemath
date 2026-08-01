SAGE_SPKG_CONFIGURE([typing_extensions], [dnl
  SAGE_PYTHON_PACKAGE_CHECK([typing_extensions])
],[
  dnl Three of our python packages are backport packages providing
  dnl python-3.13 features (see coding_in_python.rst):
  dnl
  dnl   * importlib_metadata
  dnl   * importlib_resources
  dnl   * typing_extensions
  dnl
  dnl These packages are therefore not needed for the Sage library with >=python-3.13. Here
  dnl we could test for a python minor version component greater than or equal
  dnl to 13, and mark this package as "not required" if we succeed.
  dnl
  dnl However, various other packages in the Sage distribution require
  dnl typing_extensions unconditionally. So we do nothing.
])
