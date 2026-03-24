# sage_setup: distribution = sagemath-giac
# sage.doctest: needs sage.libs.giac
try:
    from sage.libs.giac.gb import *
    from sage.libs.giac.context import *
except ImportError:
    pass
