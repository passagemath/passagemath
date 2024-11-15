# sage_setup: distribution = sagemath-groups
r"""
Type ``groups.misc.<tab>`` to access examples
of various groups not listed elsewhere.
"""

# groups imported here will be available
# via  groups.misc.<tab>
#
# Do not use this file for code
#
# If you import a new group, then add an
# entry to the list in the module-level
# docstring of groups/groups_catalog.py

from sage.misc.lazy_import import lazy_import

lazy_import('sage.groups.additive_abelian.additive_abelian_group', 'AdditiveAbelianGroup', as_='AdditiveAbelian')
lazy_import('sage.groups.abelian_gps.abelian_group', 'AbelianGroup', as_='MultiplicativeAbelian')
lazy_import('sage.rings.finite_rings.integer_mod_ring', 'IntegerModRing', as_='AdditiveCyclic')
lazy_import('sage.groups.free_group', 'FreeGroup', as_='Free')
lazy_import('sage.groups.artin', 'ArtinGroup', as_='Artin')
lazy_import('sage.groups.braid', 'BraidGroup', as_='Braid')
lazy_import('sage.groups.semimonomial_transformations.semimonomial_transformation_group', 'SemimonomialTransformationGroup', as_='SemimonomialTransformation')
lazy_import('sage.combinat.root_system.coxeter_group', 'CoxeterGroup')
lazy_import('sage.combinat.root_system.weyl_group', 'WeylGroup')
lazy_import('sage.combinat.colored_permutations', 'ShephardToddFamilyGroup', as_='ShephardToddFamily')
lazy_import('sage.groups.raag', 'RightAngledArtinGroup', as_='RightAngledArtin')
lazy_import('sage.combinat.root_system.reflection_group_real', 'ReflectionGroup')
lazy_import('sage.groups.cactus_group', 'CactusGroup', as_='Cactus')
lazy_import('sage.groups.cactus_group', 'PureCactusGroup', as_='PureCactus')

del lazy_import
