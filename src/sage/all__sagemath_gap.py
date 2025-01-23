# sage_setup: distribution = sagemath-gap
r"""
Top level of the distribution package sagemath-gap

This distribution makes the following feature available::

    sage: from sage.features.sagemath import *
    sage: sage__libs__gap().is_present()
    FeatureTestResult('sage.libs.gap', True)
"""
from sage.all__sagemath_categories import *

import sage.groups.perm_gps.permgroup_element

from sage.geometry.all__sagemath_gap import *

from sage.groups.all__sagemath_gap import *

import sage.libs.gap.element

from sage.libs.gap.libgap import libgap

from sage.rings.all__sagemath_gap import *
