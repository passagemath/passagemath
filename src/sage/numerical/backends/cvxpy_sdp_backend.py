from sage.numerical.sdp import SDPSolverException
from sage.matrix.all import Matrix
from .matrix_sdp_backend import MatrixSDPBackend
from sage.structure.unique_representation import UniqueRepresentation

import cvxpy as cp


class CVXPYSDPBackend(MatrixSDPBackend):
    """
    The CVXPY SDP middle-end

    https://www.cvxpy.org/tutorial/advanced/index.html#choosing-a-solver

    INPUT:

    - ``cvxpy_solver`` -- either ``None``, one of the values ``cvxpy.CVXOPT``,
      ``cvxpy.SCS``, or ``cvxpy.MOSEK``, or one of the strings ``"CVXOPT"``,
      ``"SCS"``, ``"MOSEK"``.

    - ``cvxpy_solver_args`` -- either ``None`` or a dictionary providing
      default keyword arguments for the ``solve`` method.

    See https://www.cvxpy.org/tutorial/advanced/index.html#choosing-a-solver for more
    information.

    EXAMPLES::

        sage: from sage.numerical.backends.generic_sdp_backend import get_solver
        sage: get_solver("CVXPY")
        CVXPYSDPBackend(maximization=True)
        sage: get_solver("cvxpy/CVXOPT")
        CVXPYSDPBackend(maximization=True, cvxpy_solver=CVXOPT)
        sage: get_solver("cvxpy/SCS")
        CVXPYSDPBackend(maximization=True, cvxpy_solver=SCS)

    """
    def __init__(self, maximization=True, base_ring=None, *, cvxpy_solver=None, cvxpy_solver_args=None):
        """
        EXAMPLES::

            sage: from sage.numerical.backends.generic_sdp_backend import get_solver
            sage: p = get_solver(solver="CVXPY")
        """
        from sage.rings.all import RDF
        if base_ring is None:
            base_ring = RDF
        if base_ring is not RDF:
            raise ValueError("only base_ring=RDF is supported")
        MatrixSDPBackend.__init__(self, maximization, base_ring=base_ring)
        if isinstance(cvxpy_solver, str):
            import cvxpy as cp
            cvxpy_solver = getattr(cp, cvxpy_solver.upper())
        self._cvxpy_solver = cvxpy_solver
        self._cvxpy_solver_args = cvxpy_solver_args

    def __repr__(self):
        s = self.__class__.__name__
        s += "("
        s += f"maximization={self.is_maximization()}"
        if self._cvxpy_solver:
            s += f", cvxpy_solver={self._cvxpy_solver}"
        s += ")"
        return s

    def solve(self):
        raise NotImplementedError

    def get_objective_value(self):
        """
        Return the value of the objective function.

        .. NOTE::

           Behaviour is undefined unless ``solve`` has been called before.
        """
        raise NotImplementedError
