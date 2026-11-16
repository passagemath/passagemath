# sage_setup: distribution = sagemath-mathilda

from sage.misc.lazy_import import lazy_import

lazy_import('sage.interfaces.mathilda', ['mathilda', 'Mathilda'])
