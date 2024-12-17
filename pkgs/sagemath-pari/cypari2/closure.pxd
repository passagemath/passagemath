# sage_setup: distribution = sagemath-pari

from .gen cimport Gen
cpdef Gen objtoclosure(f)
cdef int _pari_init_closure() except -1
