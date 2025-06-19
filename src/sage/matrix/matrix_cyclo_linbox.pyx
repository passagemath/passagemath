# sage_setup: distribution = sagemath-linbox
# sage.doctest: needs sage.libs.flint sage.libs.linbox

from sage.arith.misc import previous_prime
from sage.libs.flint.fmpq cimport fmpq_is_zero, fmpq_set_mpq, fmpq_canonicalise
from sage.libs.flint.fmpq_mat cimport fmpq_mat_entry_num, fmpq_mat_entry_den, fmpq_mat_entry
from sage.libs.flint.fmpz cimport fmpz_init, fmpz_clear, fmpz_set_mpz, fmpz_one, fmpz_get_mpz, fmpz_add, fmpz_mul, fmpz_sub, fmpz_mul_si, fmpz_mul_si, fmpz_mul_si, fmpz_divexact, fmpz_lcm
from sage.libs.gmp.types cimport mpz_t
from sage.matrix.constructor import matrix
from sage.matrix.matrix_cyclo_dense cimport Matrix_cyclo_dense
from sage.matrix.matrix_integer_linbox cimport _lift_crt
from sage.matrix.matrix_rational_dense cimport Matrix_rational_dense
from sage.matrix.matrix_space import MatrixSpace
from sage.matrix.misc_flint import matrix_integer_dense_rational_reconstruction
from sage.misc.verbose import verbose
from sage.rings.integer_ring import ZZ
from sage.rings.rational_field import QQ
from sage.structure.element cimport Matrix as baseMatrix
from sage.structure.proof.proof import get_flag as get_proof_flag

from sage.matrix.matrix_modn_dense_double import MAX_MODULUS as MAX_MODULUS_modn_dense_double
from sage.arith.multi_modular import MAX_MODULUS as MAX_MODULUS_multi_modular
MAX_MODULUS = min(MAX_MODULUS_modn_dense_double, MAX_MODULUS_multi_modular)

# parameters for tuning
echelon_primes_increment = 15
echelon_verbose_level = 1


cpdef _matrix_times_matrix_(Matrix_cyclo_dense self, baseMatrix right):
    """
    Return the product of two cyclotomic dense matrices.

    INPUT:

    - ``self``, ``right`` -- cyclotomic dense matrices with compatible
      parents (same base ring, and compatible dimensions for matrix
      multiplication)

    OUTPUT: cyclotomic dense matrix

    ALGORITHM:

    Use a multimodular algorithm that involves multiplying the two matrices
    modulo split primes.

    EXAMPLES::

        sage: W.<z> = CyclotomicField(5)
        sage: A = matrix(3, 3, [1,z,z^2,z^3,z^4,2/3*z,-3*z,z,2+z]); B = matrix(3, 3, [-1,2*z,3*z^2,5*z+1,z^4,1/3*z,2-z,3-z,5-z])
        sage: A*B
        [        -z^3 + 7*z^2 + z - 1       -z^3 + 3*z^2 + 2*z + 1              -z^3 + 25/3*z^2]
        [-2*z^3 - 5/3*z^2 + 1/3*z + 4           -z^3 - 8/3*z^2 - 2     -2/3*z^2 + 10/3*z + 10/3]
        [             4*z^2 + 4*z + 4               -7*z^2 + z + 7  -9*z^3 - 2/3*z^2 + 3*z + 10]

    Verify that the answer above is consistent with what the
    generic sparse matrix multiply gives (which is a different
    implementation).::

        sage: A*B == A.sparse_matrix()*B.sparse_matrix()
        True

        sage: N1 = Matrix(CyclotomicField(6), 1, [1])
        sage: cf6 = CyclotomicField(6) ; z6 = cf6.0
        sage: N2 = Matrix(CyclotomicField(6), 1, 5, [0,1,z6,-z6,-z6+1])
        sage: N1*N2
        [         0          1      zeta6     -zeta6 -zeta6 + 1]
        sage: N1 = Matrix(CyclotomicField(6), 1, [-1])
        sage: N1*N2
        [        0        -1    -zeta6     zeta6 zeta6 - 1]

    Verify that a degenerate case bug reported at :issue:`5974` is fixed.

        sage: K.<zeta6>=CyclotomicField(6); matrix(K,1,2) * matrix(K,2,[0, 1, 0, -2*zeta6, 0, 0, 1, -2*zeta6 + 1])
        [0 0 0 0]

    TESTS:

    This is from :issue:`8666`::

        sage: K.<zeta4> = CyclotomicField(4)
        sage: m = matrix(K, [125])
        sage: n = matrix(K, [186])
        sage: m*n
        [23250]
        sage: (-m)*n
        [-23250]
    """
    A, denom_self = self._matrix._clear_denom()
    B, denom_right = (<Matrix_cyclo_dense>right)._matrix._clear_denom()

    # conservative but correct estimate: 2 is there to account for the
    # sign of the entries
    bound = 1 + 2 * A.height() * B.height() * self._ncols

    n = self._base_ring._n()
    p = previous_prime(MAX_MODULUS)
    prod = 1
    v = []
    while prod <= bound:
        while (n >= 2 and p % n != 1) or denom_self % p == 0 or denom_right % p == 0:
            if p == 2:
                raise RuntimeError("we ran out of primes in matrix multiplication.")
            p = previous_prime(p)
        prod *= p
        Amodp, _ = self._reductions(p)
        Bmodp, _ = right._reductions(p)
        _, S = self._reduction_matrix(p)
        X = Amodp[0]._matrix_from_rows_of_matrices([Amodp[i] * Bmodp[i] for i in range(len(Amodp))])
        v.append(S*X)
        p = previous_prime(p)
    M = matrix(ZZ, self._base_ring.degree(), self._nrows*right.ncols())
    _lift_crt(M, v)
    d = denom_self * denom_right
    if d == 1:
        M = M.change_ring(QQ)
    else:
        M = (1/d)*M
    cdef Matrix_cyclo_dense C = Matrix_cyclo_dense.__new__(Matrix_cyclo_dense,
                MatrixSpace(self._base_ring, self._nrows, right.ncols()),
                                                           None, None, None)
    C._matrix = M
    return C


def _charpoly_multimodular(Matrix_cyclo_dense self, var='x', proof=None):
    """
    Compute the characteristic polynomial of ``self`` using a
    multimodular algorithm.

    INPUT:

    - ``proof`` -- boolean (default: global flag); if ``False``, compute
      using primes `p_i` until the lift modulo all primes up to `p_i` is
      the same as the lift modulo all primes up to `p_{i+3}` or the bound
      is reached

    EXAMPLES::

        sage: K.<z> = CyclotomicField(3)
        sage: A = matrix(3, [-z, 2*z + 1, 1/2*z + 2, 1, -1/2, 2*z + 2, -2*z - 2, -2*z - 2, 2*z - 1])
        sage: A._charpoly_multimodular()
        x^3 + (-z + 3/2)*x^2 + (17/2*z + 9/2)*x - 9/2*z - 23/2
        sage: A._charpoly_multimodular('T')
        T^3 + (-z + 3/2)*T^2 + (17/2*z + 9/2)*T - 9/2*z - 23/2
        sage: A._charpoly_multimodular('T', proof=False)
        T^3 + (-z + 3/2)*T^2 + (17/2*z + 9/2)*T - 9/2*z - 23/2

    TESTS:

    We test a degenerate case::

        sage: A = matrix(CyclotomicField(1),2,[1,2,3,4]); A.charpoly()
        x^2 - 5*x - 2
    """
    cdef Matrix_cyclo_dense A
    A = Matrix_cyclo_dense.__new__(Matrix_cyclo_dense, self.parent(),
                                   None, None, None)

    proof = get_proof_flag(proof, "linear_algebra")

    n = self._base_ring._n()
    p = previous_prime(MAX_MODULUS)
    prod = 1
    v = []
    # A, denom = self._matrix._clear_denom()
    # TODO: this might be stupidly slow
    denom = self._matrix.denominator()
    A._matrix = <Matrix_rational_dense>(denom*self._matrix)
    bound = A._charpoly_bound()
    L_last = 0
    while prod <= bound:
        while (n >= 2  and p % n != 1) or denom % p == 0:
            if p == 2:
                raise RuntimeError("we ran out of primes in multimodular charpoly algorithm.")
            p = previous_prime(p)

        X = A._charpoly_mod(p)
        v.append(X)
        prod *= p
        p = previous_prime(p)

        # if we've used enough primes as determined by bound, or
        # if we've used 3 primes, we check to see if the result is
        # the same.
        if prod >= bound or (not proof and (len(v) % 3 == 0)):
            M = matrix(ZZ, self._base_ring.degree(), self._nrows+1)
            L = _lift_crt(M, v)
            if not proof and L == L_last:
                break
            L_last = L

    # Now each column of L encodes a coefficient of the output polynomial,
    # with column 0 being the constant coefficient.
    K = self.base_ring()
    R = K[var]
    coeffs = [K(w.list()) for w in L.columns()]
    f = R(coeffs)

    # Rescale to account for denominator, if necessary
    if denom != 1:
        x = R.gen()
        f = f(x * denom) * (1 / (denom**f.degree()))

    return f


def _echelon_form_multimodular(Matrix_cyclo_dense self, num_primes=10, height_guess=None):
    """
    Use a multimodular algorithm to find the echelon form of ``self``.

    INPUT:

    - ``num_primes`` -- number of primes to work modulo

    - ``height_guess`` -- guess for the height of the echelon form of self

    OUTPUT: matrix in reduced row echelon form

    EXAMPLES::

        sage: W.<z> = CyclotomicField(3)
        sage: A = matrix(W, 2, 3, [1+z, 2/3, 9*z+7, -3 + 4*z, z, -7*z]); A
        [  z + 1     2/3 9*z + 7]
        [4*z - 3       z    -7*z]
        sage: A._echelon_form_multimodular(10)
        [                  1                   0  -192/97*z - 361/97]
        [                  0                   1 1851/97*z + 1272/97]

    TESTS:

    We test a degenerate case::

        sage: A = matrix(CyclotomicField(5),0); A
        []
        sage: A._echelon_form_multimodular(10)
        []
        sage: A.pivots()
        ()

        sage: A = matrix(CyclotomicField(13), 2, 3, [5, 1, 2, 46307, 46307*4, 46307])
        sage: A._echelon_form_multimodular()
        [   1    0 7/19]
        [   0    1 3/19]
    """
    cdef Matrix_cyclo_dense res
    cdef bint is_square

    verbose("entering _echelon_form_multimodular",
            level=echelon_verbose_level)

    denom = self._matrix.denominator()
    A = denom * self

    # This bound is chosen somewhat arbitrarily. Changing it affects the
    # runtime, not the correctness of the result.
    if height_guess is None:
        height_guess = (A.coefficient_bound() + 100) * 1000000

    # This is all setup to keep track of various data
    # in the loop below.
    p = previous_prime(MAX_MODULUS)
    found = 0
    prod = 1
    n = self._base_ring._n()
    height_bound = self._ncols * height_guess * A.coefficient_bound() + 1
    mod_p_ech_ls = []
    max_pivots = tuple()
    is_square = self._nrows == self._ncols

    verbose("using height bound %s" % height_bound,
            level=echelon_verbose_level)

    while True:
        # Generate primes to use, and find echelon form
        # modulo those primes.
        while found < num_primes or prod <= height_bound:
            if (n == 1) or p % n == 1:
                try:
                    mod_p_ech, piv_ls = A._echelon_form_one_prime(p)
                except ValueError:
                    # This means that we chose a prime which divides
                    # the denominator of the echelon form of self, so
                    # just skip it and continue
                    p = previous_prime(p)
                    continue
                # if we have the identity, just return it, and
                # we're done.
                if is_square and len(piv_ls) == self._nrows:
                    self.cache('pivots', tuple(range(self._nrows)))
                    return self.parent().identity_matrix()
                if piv_ls > max_pivots:
                    mod_p_ech_ls = [mod_p_ech]
                    max_pivots = piv_ls
                    # add this to the list of primes
                    prod = p
                    found = 1
                elif piv_ls == max_pivots:
                    mod_p_ech_ls.append(mod_p_ech)
                    # add this to the list of primes
                    prod *= p
                    found += 1
                else:
                    # this means that the rank profile mod this
                    # prime is worse than those that came before,
                    # so we just loop
                    p = previous_prime(p)
                    continue

            p = previous_prime(p)

        if found > num_primes:
            num_primes = found

        verbose("computed echelon form mod %s primes" % num_primes,
                level=echelon_verbose_level)
        verbose("current product of primes used: %s" % prod,
                level=echelon_verbose_level)

        # Use CRT to lift back to ZZ
        mat_over_ZZ = matrix(ZZ, self._base_ring.degree(),
                             self._nrows * self._ncols)
        _lift_crt(mat_over_ZZ, mod_p_ech_ls)
        # note: saving the CRT intermediate MultiModularBasis does
        # not seem to affect the runtime at all

        # Attempt to use rational reconstruction to find
        # our echelon form
        try:
            verbose("attempting rational reconstruction ...",
                    level=echelon_verbose_level)
            res = Matrix_cyclo_dense.__new__(Matrix_cyclo_dense,
                                             self.parent(),
                                             None, None, None)
            res._matrix = <Matrix_rational_dense>matrix_integer_dense_rational_reconstruction(mat_over_ZZ, prod)

        except ValueError:
            # If a ValueError is raised here, it means that the
            # rational reconstruction failed. In this case, add
            # on a few more primes, and try again.

            num_primes += echelon_primes_increment
            verbose("rational reconstruction failed, trying with %s primes"%num_primes, level=echelon_verbose_level)
            continue

        verbose("rational reconstruction succeeded with %s primes!"%num_primes, level=echelon_verbose_level)

        if ((res * res.denominator()).coefficient_bound() *
            self.coefficient_bound() * self.ncols()) > prod:
            # In this case, we don't know the result to sufficient
            # "precision" (here precision is just the modulus,
            # prod) to guarantee its correctness, so loop.

            num_primes += echelon_primes_increment
            verbose("height not sufficient to determine echelon form",
                    level=echelon_verbose_level)
            continue

        verbose("found echelon form with %s primes, whose product is %s"%(num_primes, prod), level=echelon_verbose_level)
        self.cache('pivots', max_pivots)
        return res
