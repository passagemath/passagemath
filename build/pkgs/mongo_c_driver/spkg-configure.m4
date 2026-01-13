SAGE_SPKG_CONFIGURE([mongo_c_driver], [
    AC_CHECK_HEADER([libmongoc-1.0/mongoc/mongoc.h], [], [sage_spkg_install_mongo_c_driver=yes])
])
