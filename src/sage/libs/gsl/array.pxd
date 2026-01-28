# sage_setup: distribution = sagemath-modules
# distutils: extra_compile_args = -DGSL_DLL
cdef class GSLDoubleArray:
    cdef size_t n
    cdef size_t stride
    cdef double * data
