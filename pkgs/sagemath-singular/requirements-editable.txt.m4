include(`sage_spkg_versions.m4')dnl
dnl Same as setup.cfg.m4 install_requires; FIXME: should pin to built wheels.
SPKG_INSTALL_REQUIRES_sagemath_pari
SPKG_INSTALL_REQUIRES_cysignals
SPKG_INSTALL_REQUIRES_memory_allocator
-e ../sage-conf
-e ../sagemath-environment
-e ../sagemath-objects
-e ../sagemath-categories
-e ../sagemath-pari
