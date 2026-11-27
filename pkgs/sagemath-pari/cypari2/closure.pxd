# sage_setup: distribution = sagemath-pari
from .gen cimport Gen
cpdef Gen objtoclosure(f)
cdef int _pari_init_closure() except -1
cdef void note_callback_pari_error()
