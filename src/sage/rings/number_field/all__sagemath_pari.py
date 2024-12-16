# sage_setup: distribution = sagemath-pari

from sage.misc.lazy_import import lazy_import

lazy_import('sage.rings.number_field.totallyreal', 'enumerate_totallyreal_fields_prim')
lazy_import('sage.rings.number_field.totallyreal_data', 'hermite_constant')
lazy_import('sage.rings.number_field.totallyreal_rel',
            'enumerate_totallyreal_fields_all')
lazy_import('sage.rings.number_field.totallyreal_rel',
            'enumerate_totallyreal_fields_rel')

lazy_import('sage.rings.number_field.unit_group', 'UnitGroup')

del lazy_import
