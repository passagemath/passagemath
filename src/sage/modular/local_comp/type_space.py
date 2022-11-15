r"""
Type spaces of newforms

Let `f` be a new modular eigenform of level `\Gamma_1(N)`, and `p` a prime
dividing `N`, with `N = Mp^r` (`M` coprime to `p`). Suppose the power of `p`
dividing the conductor of the character of `f` is `p^c` (so `c \le r`).

Then there is an integer `u`, which is `\operatorname{min}([r/2], r-c)`, such
that any twist of `f` by a character mod `p^u` also has level `N`. The *type
space* of `f` is the span of the modular eigensymbols corresponding to all of
these twists, which lie in a space of modular symbols for a suitable `\Gamma_H`
subgroup. This space is the key to computing the isomorphism class of the local
component of the newform at `p`.

"""

import operator

from sage.arith.misc import crt
from sage.matrix.constructor import matrix
from sage.misc.cachefunc import cached_method, cached_function
from sage.modular.arithgroup.all import GammaH
from sage.modular.modform.constructor import ModularForms
from sage.modular.modform.element import Newform
from sage.modular.modsym.modsym import ModularSymbols
from sage.rings.fast_arith import prime_range
from sage.rings.finite_rings.integer_mod_ring import Zmod
from sage.rings.integer_ring import ZZ
from sage.rings.rational_field import QQ
from sage.structure.sage_object import SageObject

from .liftings import lift_gen_to_gamma1, lift_ramified


@cached_function
def example_type_space(example_no=0):
    r"""
    Quickly return an example of a type space. Used mainly to speed up
    doctesting.

    EXAMPLES::

        sage: from sage.modular.local_comp.type_space import example_type_space
        sage: example_type_space()  # takes a while but caches stuff (21s on sage.math, 2012)
        6-dimensional type space at prime 7 of form q + ... + O(q^6)

    The above test takes a long time, but it precomputes and caches
    various things such that subsequent doctests can be very quick.
    So we don't want to mark it ``# long time``.
    """
    from sage.modular.modform.constructor import Newform as Newform_constructor
    if example_no == 0:
        # a fairly generic example
        return TypeSpace(Newform_constructor('98b', names='a'), 7)
    elif example_no == 1:
        # a non-minimal example
        return TypeSpace(Newform_constructor('98a', names='a'), 7)
    elif example_no == 2:
        # a smaller example with QQ coefficients
        return TypeSpace(Newform_constructor('50a'), 5)
    elif example_no == 3:
        # a ramified (odd p-power level) case
        return TypeSpace(Newform_constructor('27a'), 3)

def find_in_space(f, A, base_extend=False):
    r"""
    Given a Newform object `f`, and a space `A` of modular symbols of the same
    weight and level, find the subspace of `A` which corresponds to the Hecke
    eigenvalues of `f`.

    If ``base_extend = True``, this will return a 2-dimensional space generated
    by the plus and minus eigensymbols of `f`. If ``base_extend = False`` it
    will return a larger space spanned by the eigensymbols of `f` and its
    Galois conjugates.

    (NB: "Galois conjugates" needs to be interpreted carefully -- see the last
    example below.)

    `A` should be an ambient space (because non-ambient spaces don't implement
    ``base_extend``).

    EXAMPLES::

        sage: from sage.modular.local_comp.type_space import find_in_space

    Easy case (`f` has rational coefficients)::

        sage: f = Newform('99a'); f
        q - q^2 - q^4 - 4*q^5 + O(q^6)
        sage: A = ModularSymbols(GammaH(99, [13]))
        sage: find_in_space(f, A)
        Modular Symbols subspace of dimension 2 of Modular Symbols space of dimension 25 for Congruence Subgroup Gamma_H(99) with H generated by [13] of weight 2 with sign 0 over Rational Field

    Harder case::

        sage: f = Newforms(23, names='a')[0]
        sage: A = ModularSymbols(Gamma1(23))
        sage: find_in_space(f, A, base_extend=True)
        Modular Symbols subspace of dimension 2 of Modular Symbols space of dimension 45 for Gamma_1(23) of weight 2 with sign 0 over Number Field in a0 with defining polynomial x^2 + x - 1
        sage: find_in_space(f, A, base_extend=False)
        Modular Symbols subspace of dimension 4 of Modular Symbols space of dimension 45 for Gamma_1(23) of weight 2 with sign 0 over Rational Field

    An example with character, indicating the rather subtle behaviour of
    ``base_extend``::

        sage: chi = DirichletGroup(5).0
        sage: f = Newforms(chi, 7, names='c')[0]; f  # long time (4s on sage.math, 2012)
        q + c0*q^2 + (zeta4*c0 - 5*zeta4 + 5)*q^3 + ((-5*zeta4 - 5)*c0 + 24*zeta4)*q^4 + ((10*zeta4 - 5)*c0 - 40*zeta4 - 55)*q^5 + O(q^6)
        sage: find_in_space(f, ModularSymbols(Gamma1(5), 7), base_extend=True)  # long time
        Modular Symbols subspace of dimension 2 of Modular Symbols space of dimension 12 for Gamma_1(5) of weight 7 with sign 0 over Number Field in c0 with defining polynomial x^2 + (5*zeta4 + 5)*x - 88*zeta4 over its base field
        sage: find_in_space(f, ModularSymbols(Gamma1(5), 7), base_extend=False)  # long time (27s on sage.math, 2012)
        Modular Symbols subspace of dimension 4 of Modular Symbols space of dimension 12 for Gamma_1(5) of weight 7 with sign 0 over Cyclotomic Field of order 4 and degree 2

    Note that the base ring in the second example is `\QQ(\zeta_4)` (the base
    ring of the character of `f`), *not* `\QQ`.
    """
    if not A.weight() == f.weight():
        raise ValueError( "Weight of space does not match weight of form" )
    if not A.level() == f.level():
        raise ValueError( "Level of space does not match level of form" )

    if base_extend:
        D = A.base_extend(f.hecke_eigenvalue_field())
    else:
        M = f.modular_symbols(sign=1)
        D = A.base_extend(M.base_ring())

    expected_dimension = 2 if base_extend else 2*M.dimension()

    for p in prime_range(1 + A.sturm_bound()):
        h = D.hecke_operator(p)
        if base_extend:
            hh = h - f[p]
        else:
            f = M.hecke_polynomial(p)
            hh = f(h)
        DD = hh.kernel()
        if DD.dimension() < D.dimension():
            D = DD

        if D.dimension() <= expected_dimension:
            break

    if D.dimension() != expected_dimension:
        raise ArithmeticError( "Error in find_in_space: "
            + "got dimension %s (should be %s)" % (D.dimension(), expected_dimension) )

    return D

class TypeSpace(SageObject):
    r"""
    The modular symbol type space associated to a newform, at a prime dividing
    the level.
    """
    #################################################
    # Basic initialisation and data-access functions
    #################################################

    def __init__(self, f, p, base_extend=True):
        r"""
        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space() # indirect doctest
            6-dimensional type space at prime 7 of form q + ... + O(q^6)
        """
        self._p = p
        self._f = f
        if f.level() % p:
            raise ValueError( "p must divide level" )

        amb = ModularSymbols(self.group(), f.weight())
        self.e_space = find_in_space(f, amb, base_extend=base_extend).sign_submodule(1)
        R = self.e_space.base_ring()
        mat = amb._action_on_modular_symbols([p**self.u(), 1, 0, p**self.u()])
        V = amb.free_module().base_extend(R)
        bvecs = []
        for v in self.e_space.free_module().basis():
            bvecs += mat.maxspin(v)
        T = V.submodule(bvecs)
        self._unipmat = mat.change_ring(R).restrict(T).transpose() / ZZ(p ** (self.u() * (f.weight() - 2)))
        self.t_space = amb.base_extend(R).submodule(T, check=False)

    def _repr_(self):
        r"""
        String representation of self.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space()._repr_()
            '6-dimensional type space at prime 7 of form q + ... + O(q^6)'
        """
        return "%s-dimensional type space at prime %s of form %s" % (self.t_space.rank(), self.prime(), self.form())

    def prime(self):
        r"""
        Return the prime `p`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().prime()
            7
        """
        return self._p

    def form(self):
        r"""
        The newform of which this is the type space.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().form()
            q + ... + O(q^6)
        """
        return self._f

    def conductor(self):
        r"""
        Exponent of `p` dividing the level of the form.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().conductor()
            2
        """
        return self.form().level().valuation(self.prime())

    def character_conductor(self):
        r"""
        Exponent of `p` dividing the conductor of the character of the form.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().character_conductor()
            0
        """
        return ZZ(self.form().character().conductor()).valuation(self.prime())

    def u(self):
        r"""
        Largest integer `u` such that level of `f_\chi` = level of `f` for all
        Dirichlet characters `\chi` modulo `p^u`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().u()
            1
            sage: from sage.modular.local_comp.type_space import TypeSpace
            sage: f = Newforms(Gamma1(5), 5, names='a')[0]
            sage: TypeSpace(f, 5).u()
            0
        """
        return min(self.conductor() - self.character_conductor(), self.conductor() // 2)

    def free_module(self):
        r"""
        Return the underlying vector space of this type space.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().free_module()
            Vector space of dimension 6 over Number Field in a1 with defining polynomial ...
        """
        return self.t_space.nonembedded_free_module()

    def eigensymbol_subspace(self):
        r"""
        Return the subspace of self corresponding to the plus eigensymbols of
        `f` and its Galois conjugates (as a subspace of the vector space
        returned by :meth:`~free_module`).

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(); T.eigensymbol_subspace()
            Vector space of degree 6 and dimension 1 over Number Field in a1 with defining polynomial ...
            Basis matrix:
            [...]
            sage: T.eigensymbol_subspace().is_submodule(T.free_module())
            True
        """
        V = self.t_space.free_module()
        vecs = [V.coordinate_vector(x) for x in self.e_space.free_module().basis()]
        return vecs[0].parent().submodule(vecs)

    def tame_level(self):
        r"""
        The level away from `p`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().tame_level()
            2
        """
        return self.form().level() // self.prime() ** self.conductor()

    def group(self):
        r"""
        Return a `\Gamma_H` group which is the level of all of the relevant
        twists of `f`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().group()
            Congruence Subgroup Gamma_H(98) with H generated by [15, 29, 43]
        """
        # Implementation here is not the most efficient but this is heavily not
        # time-critical, and getting it wrong can lead to subtle bugs.
        p = self.prime()
        r = self.conductor()
        d = max(self.character_conductor(), r//2)
        n = self.tame_level()
        chi = self.form().character()
        tame_H = [i for i in chi.kernel() if (i % p**r) == 1]
        wild_H = [crt(x, 1, p**r, n) for x in range(p**r) if x % (p**d) == 1]
        return GammaH(n * p**r, tame_H + wild_H)

    ###############################################################################
    # Testing minimality: is this form a twist of a form of strictly smaller level?
    ###############################################################################

    @cached_method
    def is_minimal(self):
        r"""
        Return True if there exists a newform `g` of level strictly smaller
        than `N`, and a Dirichlet character `\chi` of `p`-power conductor, such
        that `f = g \otimes \chi` where `f` is the form of which this is the
        type space. To find such a form, use :meth:`~minimal_twist`.

        The result is cached.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space().is_minimal()
            True
            sage: example_type_space(1).is_minimal()
            False
        """
        return self.t_space.is_submodule(self.t_space.ambient().new_submodule())

    def minimal_twist(self):
        r"""
        Return a newform (not necessarily unique) which is a twist of the
        original form `f` by a Dirichlet character of `p`-power conductor, and
        which has minimal level among such twists of `f`.

        An error will be raised if `f` is already minimal.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import TypeSpace, example_type_space
            sage: T = example_type_space(1)
            sage: T.form().q_expansion(12)
            q - q^2 + 2*q^3 + q^4 - 2*q^6 - q^8 + q^9 + O(q^12)
            sage: g = T.minimal_twist()
            sage: g.q_expansion(12)
            q - q^2 - 2*q^3 + q^4 + 2*q^6 + q^7 - q^8 + q^9 + O(q^12)
            sage: g.level()
            14
            sage: TypeSpace(g, 7).is_minimal()
            True

        Test that :trac:`13158` is fixed::

            sage: f = Newforms(256,names='a')[0]
            sage: T = TypeSpace(f,2)
            sage: g = T.minimal_twist()
            sage: g[0:3]
            [0, 1, 0]
            sage: str(g[3]) in ('a', '-a', '-1/2*a', '1/2*a')
            True
            sage: g[4:]
            []
            sage: g.level()
            64
        """
        if self.is_minimal():
            raise ValueError( "Form is already minimal" )

        NN = self.form().level()
        V = self.t_space
        A = V.ambient()

        while not V.is_submodule(A.new_submodule()):
            NN = NN / self.prime()
            D1 = A.degeneracy_map(NN, 1)
            Dp = A.degeneracy_map(NN, self.prime())
            A = D1.codomain()
            vecs = [D1(v).element() for v in V.basis()] + [Dp(v).element() for v in V.basis()]
            VV = A.free_module().submodule(vecs)
            V = A.submodule(VV, check=False)

        D = V.decomposition()[0]
        #if len(D.star_eigenvalues()) == 2:
        #    D = D.sign_submodule(1)
        D1 = D.modular_symbols_of_sign(1)
        M = ModularForms(D1.group(), D1.weight(), D1.base_ring())
        ff = Newform(M, D1, names='a')
        return ff

    #####################################
    # The group action on the type space.
    #####################################

    def _rho_s(self, g):
        r"""
        Calculate the action of ``g`` on the type space, where ``g`` has determinant `1`.
        For internal use; this gets called by :meth:`~rho`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(2)
            sage: TT = T._rho_s([1,1,0,1]); TT
            [ 0  0  1  0]
            [ 1  0 -1  1]
            [ 0  0 -2  1]
            [ 0 -1 -2  1]
            sage: TT**5 == 1
            True
            sage: TS = T._rho_s([0,-1,1,0]); TS
            [ 0  0  1  0]
            [ 0  0  1 -1]
            [ 1  0  0  0]
            [ 1 -1  0  0]
            sage: TS**2 == 1
            True
            sage: example_type_space(3)._rho_s([1,1,0,1])
            [-1 -1]
            [ 1  0]
        """
        if self.conductor() % 2 == 1:
            return self._rho_ramified(g)

        else:
            return self._rho_unramified(g)

    @cached_method
    def _second_gen_unramified(self):
        r"""
        Calculate the action of the matrix [0, -1; 1, 0] on the type space,
        in the unramified (even level) case.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(2)
            sage: TS = T._second_gen_unramified(); TS
            [ 0  0  1  0]
            [ 0  0  1 -1]
            [ 1  0  0  0]
            [ 1 -1  0  0]
            sage: TS**2 == 1
            True
        """
        f = self.prime() ** self.u()
        g2 = lift_gen_to_gamma1(f, self.tame_level())

        g3 = [f * g2[0], g2[1], f**2 * g2[2], f*g2[3]]
        A = self.t_space.ambient()
        mm = A._action_on_modular_symbols(g3).restrict(self.t_space.free_module()).transpose()
        m = mm / ZZ(f**(self.form().weight()-2))
        return m

    def _rho_unramified(self, g):
        r"""
        Calculate the action of ``g`` on the type space, in the unramified (even
        level) case. Uses the two standard generators, and a solution of the
        word problem in `\SL_2(\ZZ / p^u \ZZ)`.

        INPUT:

        - ``g`` -- 4-tuple of integers (or more generally anything that can be
          converted into an element of the matrix group `\SL_2(\ZZ / p^u
          \ZZ)`).

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(2)
            sage: T._rho_unramified([2,1,1,1])
            [-1  0  0 -1]
            [ 0 -1  1  0]
            [ 1 -1  0  1]
            [ 2 -1  1  1]
            sage: T._rho_unramified([1,-2,1,-1]) == T._rho_unramified([2,1,1,1]) * T._rho_unramified([0,-1,1,0])
            True
        """
        f = self.prime() ** self.u()
        from sage.groups.matrix_gps.all import SL
        G = SL(2, Zmod(f))
        gg = G(g)
        s = G([1,1,0,1])
        t = G([0,-1,1,0])
        S = self._unipmat
        T = self._second_gen_unramified()

        w = gg.word_problem([s,t])
        answer = S**0
        for (x, n) in w:
            if x == s:
                answer = answer * S**n
            elif x == t:
                answer = answer * T**n
        return answer

    def _rho_ramified(self, g):
        r"""
        Calculate the action of a group element on the type space in the
        ramified (odd conductor) case.

        For internal use (called by :meth:`~rho`).

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(3)
            sage: T._rho_ramified([1,0,3,1])
            [ 0  1]
            [-1 -1]
            sage: T._rho_ramified([1,3,0,1]) == 1
            True
        """
        A = self.t_space.ambient()
        g = [ZZ(_) for _ in g]
        p = self.prime()
        assert g[2] % p == 0
        gg = lift_ramified(g, p, self.u(), self.tame_level())
        g3 = [p**self.u() * gg[0], gg[1], p**(2*self.u()) * gg[2], p**self.u() * gg[3]]
        return A._action_on_modular_symbols(g3).restrict(self.t_space.free_module()).transpose() / ZZ(p**(self.u() * (self.form().weight()-2) ) )

    def _group_gens(self):
        r"""
        Return a set of generators of the group `S(K_0) / S(K_u)` (which is
        either `\SL_2(\ZZ / p^u \ZZ)` if the conductor is even, and a
        quotient of an Iwahori subgroup if the conductor is odd).

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space()._group_gens()
            [[1, 1, 0, 1], [0, -1, 1, 0]]
            sage: example_type_space(3)._group_gens()
            [[1, 1, 0, 1], [1, 0, 3, 1], [2, 0, 0, 5]]
        """
        if (self.conductor() % 2) == 0:
            return [ [ZZ(1), ZZ(1), ZZ(0), ZZ(1)], [ZZ(0), ZZ(-1), ZZ(1), ZZ(0)] ]
        else:
            p = self.prime()
            if p == 2:
                return [ [ZZ(1), ZZ(1), ZZ(0), ZZ(1)], [ZZ(1), ZZ(0), ZZ(p), ZZ(1)] ]
            else:
                a = Zmod(p**(self.u() + 1))(ZZ(Zmod(p).unit_gens()[0]))
                return [ [ZZ(1), ZZ(1), ZZ(0), ZZ(1)], [ZZ(1), ZZ(0), ZZ(p), ZZ(1)],
                         [ZZ(a), 0, 0, ZZ(~a)] ]

    def _intertwining_basis(self, a):
        r"""
        Return a basis for the set of homomorphisms between
        this representation and the same representation conjugated by
        [a,0; 0,1], where a is a generator of `(Z/p^uZ)^\times`. These are
        the "candidates" for extending the rep to a `\mathrm{GL}_2`-rep.

        Depending on the example, the hom-space has dimension either `1` or `2`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space(2)._intertwining_basis(2)
            [
            [ 1 -1  0  1]
            [ 0  0  1 -1]
            [ 0  1  1 -1]
            [-1  1  2 -2]
            ]
            sage: example_type_space(3)._intertwining_basis(2)
            [
            [ 1  0]  [0 1]
            [-1 -1], [1 0]
            ]
        """
        if self.conductor() % 2:
            f = self.prime() ** (self.u() + 1)
        else:
            f = self.prime() ** self.u()

        # f is smallest p-power such that rho is trivial modulo f
        ainv = (~Zmod(f)(a)).lift()
        gens = self._group_gens()
        gensconj = [[x[0], ainv*x[1], a*x[2], x[3]] for x in gens]
        rgens = [self._rho_s(x) for x in gens]
        rgensinv = [operator.inv(_) for _ in rgens]
        rgensconj = [self._rho_s(x) for x in gensconj]

        rows = []
        MS = rgens[0].parent()
        for m in MS.basis():
            rows.append([])
            for i in range(len(gens)):
                rows[-1] += (m - rgensinv[i] * m * rgensconj[i]).list()
        S = matrix(rows).left_kernel()
        return [MS(u.list()) for u in S.gens()]

    def _discover_torus_action(self):
        r"""
        Calculate and store the data necessary to extend the action of `S(K_0)`
        to `K_0`.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: example_type_space(2).rho([2,0,0,1]) # indirect doctest
            [-1  1  0 -1]
            [ 0  0 -1  1]
            [ 0 -1 -1  1]
            [ 1 -1 -2  2]
        """
        f = self.prime() ** self.u()
        if not (f % 8):
            a = ZZ(5)
        else:
            a = ZZ(Zmod(f).unit_gens()[0])

        mats = self._intertwining_basis(a)
        V = self.t_space.nonembedded_free_module()
        v = self.eigensymbol_subspace().gen(0)
        w = V.submodule_with_basis([m * v for m in mats]).coordinates(v) #v * self.e_space.diamond_eigenvalue(crt(a, 1, f, self.tame_level())))
        self._a = a
        self._amat = sum([mats[i] * w[i] for i in range(len(mats))])

    def rho(self, g):
        r"""
        Calculate the action of the group element `g` on the type space.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(2)
            sage: m = T.rho([2,0,0,1]); m
            [-1  1  0 -1]
            [ 0  0 -1  1]
            [ 0 -1 -1  1]
            [ 1 -1 -2  2]
            sage: v = T.eigensymbol_subspace().basis()[0]
            sage: m * v == v
            True

        We test that it is a left action::

            sage: T = example_type_space(0)
            sage: a = [0,5,4,3]; b = [0,2,3,5]; ab = [1,4,2,2]
            sage: T.rho(ab) == T.rho(a) * T.rho(b)
            True

        An odd level example::

            sage: from sage.modular.local_comp.type_space import TypeSpace
            sage: T = TypeSpace(Newform('54a'), 3)
            sage: a = [0,1,3,0]; b = [2,1,0,1]; ab = [0,1,6,3]
            sage: T.rho(ab) == T.rho(a) * T.rho(b)
            True
        """
        if not self.is_minimal():
            raise NotImplementedError("Group action on non-minimal type space not implemented")

        if self.u() == 0:
            # silly special case: rep is principal series or special, so SL2
            # action on type space is trivial
            raise ValueError("Representation is not supercuspidal")

        p = self.prime()
        f = p**self.u()
        g = [ZZ(_) for _ in g]
        d = (g[0] * g[3] - g[2] * g[1])

        # g is in S(K_0) (easy case)
        if d % f == 1:
            return self._rho_s(g)

        # g is in K_0, but not in S(K_0)

        if d % p != 0:
            try:
                a = self._a
            except AttributeError:
                self._discover_torus_action()
                a = self._a

            if not (f % 8):
                if d % 4 == 3:
                    return (self.rho([-g[0], g[1], -g[2], g[3]]) *
                            self.t_space.star_involution().matrix().transpose())

            i = 0
            while (d * a**i) % f != 1:
                i += 1
                if i > f:
                    raise ArithmeticError
            return self._rho_s([a**i*g[0], g[1], a**i*g[2], g[3]]) * self._amat**(-i)

        # det(g) is not a unit

        if (self.conductor() % 2 == 0):
            if all(x.valuation(p) > 0 for x in g):
                eps = self.form().character()(crt(1, p, f, self.tame_level()))
                return ~eps * p**(self.form().weight() - 2) * self.rho([x // p for x in g])
            else:
                raise ArithmeticError( "g(={0}) not in K".format(g) )

        else:
            m = matrix(ZZ, 2, g)
            s = m.det().valuation(p)
            mm = (matrix(QQ, 2, [0, -1, p, 0])**(-s) * m).change_ring(ZZ)
            return self._unif_ramified()**s * self.rho(mm.list())

    def _unif_ramified(self):
        r"""
        Return the action of [0,-1,p,0], in the ramified (odd p-power level)
        case.

        EXAMPLES::

            sage: from sage.modular.local_comp.type_space import example_type_space
            sage: T = example_type_space(3)
            sage: T._unif_ramified()
            [-1  0]
            [ 0 -1]

        """
        p = self.prime()
        k = self.form().weight()
        return (self.t_space.atkin_lehner_operator(p).matrix().transpose()
                * p ** ( -(k-2)*self.u() )
                * self.t_space.diamond_bracket_matrix(
                    crt(1, p**self.u(), p**self.u(), self.tame_level())).transpose())
