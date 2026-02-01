# sage_setup: distribution = sagemath-gsl
from sage.all__sagemath_modules import *

from sage.calculus.integration import numerical_integral, monte_carlo_integral
integral_numerical = numerical_integral

from sage.calculus.interpolation import spline, Spline

from sage.calculus.ode import ode_solver, ode_system

from sage.calculus.transforms.all import *

# We lazy_import the following modules since they import numpy which slows down sage startup
from sage.misc.lazy_import import lazy_import

lazy_import("sage.calculus.riemann", ["Riemann_Map"])

del lazy_import
