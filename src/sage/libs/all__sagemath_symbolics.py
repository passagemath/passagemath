# sage_setup: distribution = sagemath-symbolics

try:
    from sage.libs.all__sagemath_giac import *
except ImportError:
    pass
