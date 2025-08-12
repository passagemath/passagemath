# sage_setup: distribution = sagemath-pari
from .paridecl cimport PariOUT

cdef class PARIKernelIO(object):
    cdef PariOUT pari_out
    cdef PariOUT pari_err
    cdef readonly stdout_stream, stderr_stream
