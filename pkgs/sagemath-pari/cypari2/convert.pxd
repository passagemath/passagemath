# sage_setup: distribution = sagemath-pari

from .paridecl cimport (GEN, t_COMPLEX, dbltor, real_0_bit, stoi, cgetg,
                        set_gel, gen_0)
from .gen cimport Gen
from cpython.int cimport PyInt_AS_LONG
from cpython.float cimport PyFloat_AS_DOUBLE
from cpython.complex cimport PyComplex_RealAsDouble, PyComplex_ImagAsDouble
from cpython.longintrepr cimport py_long


# Conversion PARI -> Python

cdef GEN gtoi(GEN g0) except NULL

cdef PyObject_FromGEN(GEN g)

cdef PyInt_FromGEN(GEN g)

cpdef gen_to_python(Gen z)

cpdef gen_to_integer(Gen x)


# Conversion C -> PARI

cdef inline GEN double_to_REAL(double x) noexcept:
    # PARI has an odd concept where it attempts to track the accuracy
    # of floating-point 0; a floating-point zero might be 0.0e-20
    # (meaning roughly that it might represent any number in the
    # range -1e-20 <= x <= 1e20).

    # PARI's dbltor converts a floating-point 0 into the PARI real
    # 0.0e-307; PARI treats this as an extremely precise 0.  This
    # can cause problems; for instance, the PARI incgam() function can
    # be very slow if the first argument is very precise.

    # So we translate 0 into a floating-point 0 with 53 bits
    # of precision (that's the number of mantissa bits in an IEEE
    # double).
    if x == 0:
        return real_0_bit(-53)
    else:
        return dbltor(x)


cdef inline GEN doubles_to_COMPLEX(double re, double im) noexcept:
    cdef GEN g = cgetg(3, t_COMPLEX)
    if re == 0:
        set_gel(g, 1, gen_0)
    else:
        set_gel(g, 1, dbltor(re))
    if im == 0:
        set_gel(g, 2, gen_0)
    else:
        set_gel(g, 2, dbltor(im))
    return g


# Conversion Python -> PARI

cdef inline GEN PyInt_AS_GEN(x) except? NULL:
    return stoi(PyInt_AS_LONG(x))

cdef GEN PyLong_AS_GEN(py_long x) noexcept

cdef inline GEN PyFloat_AS_GEN(x) except? NULL:
    return double_to_REAL(PyFloat_AS_DOUBLE(x))

cdef inline GEN PyComplex_AS_GEN(x) except? NULL:
    return doubles_to_COMPLEX(
        PyComplex_RealAsDouble(x), PyComplex_ImagAsDouble(x))

cdef GEN PyObject_AsGEN(x) except? NULL


# Deprecated functions still used by SageMath

cdef Gen new_gen_from_double(double)
cdef Gen new_t_COMPLEX_from_double(double re, double im)
