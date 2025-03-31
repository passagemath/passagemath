# sage_setup: distribution = sagemath-cmr
# -*- python -*-

cdef CMR *cmr = NULL


cdef CMR_CALL(CMR_ERROR _cmr_error):
    if _cmr_error == CMR_OKAY:
        return
    if _cmr_error == CMR_ERROR_INPUT:
        raise RuntimeError("User input error")
    if _cmr_error == CMR_ERROR_MEMORY:
        raise RuntimeError("Memory (re)allocation failed")
    if _cmr_error == CMR_ERROR_INVALID:
        raise RuntimeError("Invalid input")
    if _cmr_error == CMR_ERROR_TIMEOUT:
        raise RuntimeError("Time limit exceeded")
    if _cmr_error == CMR_ERROR_STRUCTURE:
        raise RuntimeError("Invalid matrix structure")
    if _cmr_error == CMR_ERROR_INCONSISTENT:
        raise RuntimeError("Inconsistent pieces of input")
    if _cmr_error == CMR_ERROR_PARAMS:
        raise RuntimeError("Invalid parameters provided")
    raise RuntimeError("Unknown error")
