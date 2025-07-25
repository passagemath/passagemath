# sage_setup: distribution = sagemath-schemes
"""
Cuspidal subgroups of modular abelian varieties

AUTHORS:

- William Stein (2007-03, 2008-02)

EXAMPLES: We compute the cuspidal subgroup of `J_1(13)`::

    sage: A = J1(13)
    sage: C = A.cuspidal_subgroup(); C
    Finite subgroup with invariants [19, 19] over QQ of Abelian variety J1(13) of dimension 2
    sage: C.gens()
    ([(1/19, 0, 9/19, 9/19)], [(0, 1/19, 0, 9/19)])
    sage: C.order()
    361
    sage: C.invariants()
    [19, 19]

We compute the cuspidal subgroup of `J_0(54)`::

    sage: A = J0(54)
    sage: C = A.cuspidal_subgroup(); C
    Finite subgroup with invariants [3, 3, 3, 3, 3, 9] over QQ of Abelian variety J0(54) of dimension 4
    sage: C.gens()
    ([(1/3, 0, 0, 0, 0, 1/3, 0, 2/3)], [(0, 1/3, 0, 0, 0, 2/3, 0, 1/3)], [(0, 0, 1/9, 1/9, 1/9, 1/9, 1/9, 2/9)], [(0, 0, 0, 1/3, 0, 1/3, 0, 0)], [(0, 0, 0, 0, 1/3, 1/3, 0, 1/3)], [(0, 0, 0, 0, 0, 0, 1/3, 2/3)])
    sage: C.order()
    2187
    sage: C.invariants()
    [3, 3, 3, 3, 3, 9]

We compute the subgroup of the cuspidal subgroup generated by
rational cusps.

::

    sage: C = J0(54).rational_cusp_subgroup(); C
    Finite subgroup with invariants [3, 3, 9] over QQ of Abelian variety J0(54) of dimension 4
    sage: C.gens()
    ([(1/3, 0, 0, 1/3, 2/3, 1/3, 0, 1/3)], [(0, 0, 1/9, 1/9, 7/9, 7/9, 1/9, 8/9)], [(0, 0, 0, 0, 0, 0, 1/3, 2/3)])
    sage: C.order()
    81
    sage: C.invariants()
    [3, 3, 9]

This might not give us the exact rational torsion subgroup, since
it might be bigger than order `81`::

    sage: J0(54).rational_torsion_subgroup().multiple_of_order()
    243

TESTS::

    sage: C = J0(54).cuspidal_subgroup()
    sage: loads(dumps(C)) == C
    True
    sage: D = J0(54).rational_cusp_subgroup()
    sage: loads(dumps(D)) == D
    True
"""

# *****************************************************************************
#       Copyright (C) 2007 William Stein <wstein@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

from sage.matrix.constructor import matrix
from sage.modular.arithgroup.all import Gamma0_class
from sage.modular.cusps import Cusp
from sage.rings.infinity import infinity
from sage.rings.integer_ring import ZZ
from sage.rings.rational_field import QQ

from .finite_subgroup import FiniteSubgroup


class CuspidalSubgroup_generic(FiniteSubgroup):
    def _compute_lattice(self, rational_only=False, rational_subgroup=False):
        r"""
        Return a list of vectors that define elements of the rational
        homology that generate this finite subgroup.

        INPUT:

        - ``rational_only`` -- boolean (default: ``False``); if
          ``True``, only use rational cusps

        OUTPUT: list of vectors

        EXAMPLES::

            sage: J = J0(37)
            sage: C = sage.modular.abvar.cuspidal_subgroup.CuspidalSubgroup(J)
            sage: C._compute_lattice()
            Free module of degree 4 and rank 4 over Integer Ring
            Echelon basis matrix:
            [  1   0   0   0]
            [  0   1   0   0]
            [  0   0   1   0]
            [  0   0   0 1/3]
            sage: J = J0(43)
            sage: C = sage.modular.abvar.cuspidal_subgroup.CuspidalSubgroup(J)
            sage: C._compute_lattice()
            Free module of degree 6 and rank 6 over Integer Ring
            Echelon basis matrix:
            [  1   0   0   0   0   0]
            [  0 1/7   0 6/7   0 5/7]
            [  0   0   1   0   0   0]
            [  0   0   0   1   0   0]
            [  0   0   0   0   1   0]
            [  0   0   0   0   0   1]
            sage: J = J0(22)
            sage: C = sage.modular.abvar.cuspidal_subgroup.CuspidalSubgroup(J)
            sage: C._compute_lattice()
            Free module of degree 4 and rank 4 over Integer Ring
            Echelon basis matrix:
            [1/5 1/5 4/5   0]
            [  0   1   0   0]
            [  0   0   1   0]
            [  0   0   0 1/5]
            sage: J = J1(13)
            sage: C = sage.modular.abvar.cuspidal_subgroup.CuspidalSubgroup(J)
            sage: C._compute_lattice()
            Free module of degree 4 and rank 4 over Integer Ring
            Echelon basis matrix:
            [1/19    0 9/19 9/19]
            [   0 1/19    0 9/19]
            [   0    0    1    0]
            [   0    0    0    1]

        We compute with and without the optional
        ``rational_only`` option.

        ::

            sage: J = J0(27); G = sage.modular.abvar.cuspidal_subgroup.CuspidalSubgroup(J)
            sage: G._compute_lattice()
            Free module of degree 2 and rank 2 over Integer Ring
            Echelon basis matrix:
            [1/3   0]
            [  0 1/3]
            sage: G._compute_lattice(rational_only=True)
            Free module of degree 2 and rank 2 over Integer Ring
            Echelon basis matrix:
            [1/3   0]
            [  0   1]
        """
        A = self.abelian_variety()
        Cusp = A.modular_symbols()
        Amb = Cusp.ambient_module()
        Eis = Amb.eisenstein_submodule()

        C = Amb.cusps()
        N = Amb.level()

        if rational_subgroup:
            # QQ-rational subgroup of cuspidal subgroup
            assert A.is_ambient()
            Q = Cusp.abvarquo_rational_cuspidal_subgroup()
            return Q.V()

        if rational_only:
            # subgroup generated by differences of rational cusps
            if not isinstance(A.group(), Gamma0_class):
                raise NotImplementedError('computation of rational cusps only implemented in Gamma0 case.')
            if not N.is_squarefree():
                data = [n for n in N.coprime_integers(N) if n >= 2]
                C = [c for c in C if is_rational_cusp_gamma0(c, N, data)]

        v = [Amb([infinity, alpha]).element() for alpha in C]
        cusp_matrix = matrix(QQ, len(v), Amb.dimension(), v)

        # TODO -- refactor something out here
        # Now we project onto the cuspidal part.
        B = Cusp.free_module().basis_matrix().stack(Eis.free_module().basis_matrix())
        X = B.solve_left(cusp_matrix)
        X = X.matrix_from_columns(range(Cusp.dimension()))
        return X.row_module(ZZ) + A.lattice()


class CuspidalSubgroup(CuspidalSubgroup_generic):
    """
    EXAMPLES::

        sage: a = J0(65)[2]
        sage: t = a.cuspidal_subgroup()
        sage: t.order()
        6
    """
    def _repr_(self):
        """
        String representation of the cuspidal subgroup.

        EXAMPLES::

            sage: G = J0(27).cuspidal_subgroup()
            sage: G._repr_()
            'Finite subgroup with invariants [3, 3] over QQ of Abelian variety J0(27) of dimension 1'
        """
        return "Cuspidal subgroup %sover QQ of %s" % (self._invariants_repr(), self.abelian_variety())

    def lattice(self):
        """
        Returned cached tuple of vectors that define elements of the
        rational homology that generate this finite subgroup.

        OUTPUT: tuple (cached)

        EXAMPLES::

            sage: J = J0(27)
            sage: G = J.cuspidal_subgroup()
            sage: G.lattice()
            Free module of degree 2 and rank 2 over Integer Ring
            Echelon basis matrix:
            [1/3   0]
            [  0 1/3]

        Test that the result is cached::

            sage: G.lattice() is G.lattice()
            True
        """
        try:
            return self.__lattice
        except AttributeError:
            lattice = self._compute_lattice(rational_only=False)
            self.__lattice = lattice
            return lattice


class RationalCuspSubgroup(CuspidalSubgroup_generic):
    """
    EXAMPLES::

        sage: a = J0(65)[2]
        sage: t = a.rational_cusp_subgroup()
        sage: t.order()
        6
    """
    def _repr_(self):
        """
        String representation of the cuspidal subgroup.

        EXAMPLES::

            sage: G = J0(27).rational_cusp_subgroup()
            sage: G._repr_()
            'Finite subgroup with invariants [3] over QQ of Abelian variety J0(27) of dimension 1'
        """
        return "Subgroup generated by differences of rational cusps %sover QQ of %s" % (self._invariants_repr(), self.abelian_variety())

    def lattice(self):
        """
        Return lattice that defines this group.

        OUTPUT: lattice

        EXAMPLES::

            sage: G = J0(27).rational_cusp_subgroup()
            sage: G.lattice()
            Free module of degree 2 and rank 2 over Integer Ring
            Echelon basis matrix:
            [1/3   0]
            [  0   1]

        Test that the result is cached.

        ::

            sage: G.lattice() is G.lattice()
            True
        """
        try:
            return self.__lattice
        except AttributeError:
            lattice = self._compute_lattice(rational_only=True)
            self.__lattice = lattice
            return lattice


class RationalCuspidalSubgroup(CuspidalSubgroup_generic):
    """
    EXAMPLES::

        sage: a = J0(65)[2]
        sage: t = a.rational_cuspidal_subgroup()
        sage: t.order()
        6
    """
    def _repr_(self):
        """
        String representation of the cuspidal subgroup.

        EXAMPLES::

            sage: G = J0(27).rational_cuspidal_subgroup()
            sage: G._repr_()
            'Finite subgroup with invariants [3] over QQ of Abelian variety J0(27) of dimension 1'
        """
        return "Rational cuspidal subgroup %sover QQ of %s" % (self._invariants_repr(), self.abelian_variety())

    def lattice(self):
        """
        Return lattice that defines this group.

        OUTPUT: lattice

        EXAMPLES::

            sage: G = J0(27).rational_cuspidal_subgroup()
            sage: G.lattice()
            Free module of degree 2 and rank 2 over Integer Ring
            Echelon basis matrix:
            [1/3   0]
            [  0   1]

        Test that the result is cached.

        ::

            sage: G.lattice() is G.lattice()
            True
        """
        try:
            return self.__lattice
        except AttributeError:
            lattice = self._compute_lattice(rational_subgroup=True)
            self.__lattice = lattice
            return lattice


def is_rational_cusp_gamma0(c, N, data) -> bool:
    """
    Return ``True`` if the rational number c is a rational cusp of level N.

    This uses remarks in Glenn Steven's Ph.D. thesis.

    INPUT:

    - ``c`` -- a cusp

    - ``N`` -- positive integer

    - ``data`` -- the list [n for n in range(2,N) if gcd(n,N) == 1], which is
      passed in as a parameter purely for efficiency reasons.

    EXAMPLES::

        sage: from sage.modular.abvar.cuspidal_subgroup import is_rational_cusp_gamma0
        sage: N = 27
        sage: data = [n for n in range(2,N) if gcd(n,N) == 1]
        sage: is_rational_cusp_gamma0(Cusp(1/3), N, data)
        False
        sage: is_rational_cusp_gamma0(Cusp(1), N, data)
        True
        sage: is_rational_cusp_gamma0(Cusp(oo), N, data)
        True
        sage: is_rational_cusp_gamma0(Cusp(2/9), N, data)
        False
    """
    num = c.numerator()
    den = c.denominator()
    return all(c.is_gamma0_equiv(Cusp(num, d * den), N) for d in data)
