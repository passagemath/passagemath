# sage_setup: distribution = sagemath-combinat
# sage.doctest: needs sage.combinat sage.modules
r"""
Fermionic Ghosts Super Lie Conformal Algebra

The *Fermionic-ghosts* or b--c system super Lie conformal algebra
with `2n` generators is the H-graded super Lie conformal algebra
generated by odd vectors `b_i, c_i, i = 1,\ldots,n` and a central
element `K`, with non-vanishing `\lambda`-brackets:

.. MATH::

    [{b_i}_\lambda c_j] = \delta_{ij} K.

The generators `b_i` have degree `1` while the generators `c_i`
have degree `0`.

AUTHORS:

- Reimundo Heluani (2020-06-03): Initial implementation.
"""
#******************************************************************************
#       Copyright (C) 2020 Reimundo Heluani <heluani@potuz.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

from .graded_lie_conformal_algebra import GradedLieConformalAlgebra


class FermionicGhostsLieConformalAlgebra(GradedLieConformalAlgebra):
    r"""
    The Fermionic ghosts or `bc`-system super Lie conformal algebra.

    INPUT:

    - ``R`` -- a commutative ring; the base ring of this Lie
      conformal algebra
    - ``ngens`` -- an even positive Integer (default: ``2``); the
      number of non-central generators of this Lie conformal
      algebra
    - ``names`` -- tuple of strings; alternative names for the
      generators
    - ``index_set`` -- an enumerated set; alternative indexing
      set for the generators

    OUTPUT:

    The Fermionic Ghosts super Lie conformal algebra with generators
    `b_i,c_i, i=1,\ldots,n` and `K` where `2n` is ``ngens``.

    EXAMPLES::

        sage: R = lie_conformal_algebras.FermionicGhosts(QQ); R
        The Fermionic ghosts Lie conformal algebra with generators (b, c, K) over Rational Field
        sage: R.inject_variables()
        Defining b, c, K
        sage: b.bracket(c) == c.bracket(b)
        True
        sage: b.degree()
        1
        sage: c.degree()
        0
        sage: R.category()
        Category of H-graded super finitely generated Lie conformal algebras with basis over Rational Field

        sage: R = lie_conformal_algebras.FermionicGhosts(QQbar, ngens=4, names = 'abcd');R
        The Fermionic ghosts Lie conformal algebra with generators (a, b, c, d, K) over Algebraic Field
        sage: R.structure_coefficients()
        Finite family {('a', 'c'): ((0, K),),  ('b', 'd'): ((0, K),),  ('c', 'a'): ((0, K),),  ('d', 'b'): ((0, K),)}
    """
    def __init__(self,R,ngens=2,names=None,index_set=None):
        """
        Initialize ``self``.

        TESTS::

            sage: V = lie_conformal_algebras.BosonicGhosts(QQ)
            sage: TestSuite(V).run()
        """
        try:
            assert (ngens > 0 and not ngens % 2)
        except AssertionError:
            raise ValueError("ngens should be an even positive integer, " +
                             "got {}".format(ngens))
        latex_names = None
        half = ngens // 2
        if (names is None) and (index_set is None):
            from sage.misc.defaults import variable_names as varnames
            from sage.misc.defaults import latex_variable_names as laxnames
            names = varnames(half, 'b') + varnames(half, 'c')
            latex_names = tuple(laxnames(half, 'b') +
                                laxnames(half, 'c')) + ('K',)

        from sage.structure.indexed_generators import \
            standardize_names_index_set
        names, index_set = standardize_names_index_set(names=names,
                                                       index_set=index_set,
                                                       ngens=ngens)
        from sage.matrix.special import identity_matrix
        A = identity_matrix(R, half)
        from sage.matrix.special import block_matrix
        gram_matrix = block_matrix([[R.zero(), A], [A, R.zero()]])
        ghostsdict = {(i, j): {0: {('K', 0): gram_matrix[index_set.rank(i),
                                                         index_set.rank(j)]}}
                      for i in index_set for j in index_set}
        weights = (1,) * half + (0,) * half
        parity = (1,) * ngens
        super().__init__(R,
                         ghostsdict, names=names,
                         latex_names=latex_names,
                         index_set=index_set,
                         weights=weights,
                         parity=parity,
                         central_elements=('K',))

    def _repr_(self):
        """
        String representation.

        EXAMPLES::

            sage: lie_conformal_algebras.FermionicGhosts(QQ)
            The Fermionic ghosts Lie conformal algebra with generators (b, c, K) over Rational Field
        """
        return "The Fermionic ghosts Lie conformal algebra with generators {} "\
               "over {}".format(self.gens(),self.base_ring())
