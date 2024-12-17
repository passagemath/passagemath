# sage_setup: distribution = sagemath-pari

from sage.libs.gmp.mpz cimport mpz_t

from cypari2.paridecl cimport (GEN, cgetg, t_POL, set_gel, gel, stoi, lg,
                               evalvarn, evalsigne, Z_issquare,
                               hyperellratpoints)
from cypari2.stack cimport clear_stack
from cysignals.signals cimport sig_on

from sage.libs.pari.convert_gmp cimport _new_GEN_from_mpz_t


cdef bint ratpoints_mpz_exists_only(mpz_t *coeffs, long degree, long H) except -1:
    """
    Search for projective points on the hyperelliptic curve
    ``y^2 = P(x)``.

    INPUT:

    - ``coeffs`` -- an array of length ``degree + 1`` giving the
      coefficients of ``P``, starting with the constant coefficient

    - ``degree`` -- degree of ``P``

    - ``H`` -- bound on the naive height for search

    OUTPUT: boolean, whether or not a projective point was found
    """
    sig_on()
    cdef GEN pol = cgetg(degree + 3, t_POL)
    pol[1] = evalvarn(0) + evalsigne(1)
    cdef long i
    for i in range(degree + 1):
        set_gel(pol, i+2, _new_GEN_from_mpz_t(coeffs[i]))

    # PARI checks only for affine points, so we manually check for
    # points at infinity (of the smooth model)
    cdef int r
    if degree % 2 or Z_issquare(gel(pol, degree+2)):
        r = 1
    else:
        R = hyperellratpoints(pol, stoi(H), 1)
        r = (lg(R) > 1)
    clear_stack()
    return r
