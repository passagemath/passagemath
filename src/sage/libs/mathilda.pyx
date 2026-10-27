# sage_setup: distribution = sagemath-mathilda
# distutils: libraries = MATHILDA_LIBRARIES
# distutils: extra_compile_args = MATHILDA_CFLAGS
# distutils: include_dirs = MATHILDA_INCDIR
# distutils: library_dirs = MATHILDA_LIBDIR
# distutils: extra_link_args = MATHILDA_LIBEXTRA

cdef extern from "mathilda_ffi.h":

    cdef void mathilda_ffi_init()
    cdef void mathilda_ffi_set_home(const char* dir)
    cdef char* mathilda_ffi_eval(const char* input)
    cdef char* mathilda_ffi_eval_latex(const char* input)
    cdef char* mathilda_ffi_eval_json(const char* input)
    ctypedef void (*mathilda_ffi_sink)(void* ctx, const char* json_line)
    cdef void mathilda_ffi_eval_cell(const char* code, int id,
                                     int cell, mathilda_ffi_sink sink,
                                     void* ctx)
    cdef int mathilda_ffi_is_complete(const char* code)
    cdef char* mathilda_ffi_complete(const char* prefix)
    cdef void mathilda_ffi_free(char* s)
    cdef const char* mathilda_ffi_version()
