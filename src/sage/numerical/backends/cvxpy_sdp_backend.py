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
        self._update_problem()

    def _update_problem(self):
        """
        Hook that is called when problem data are updated.
        """
        self._problem = None
        self._variables = None

    def __repr__(self):
        s = self.__class__.__name__
        s += "("
        s += f"maximization={self.is_maximization()}"
        if self._cvxpy_solver:
            s += f", cvxpy_solver={self._cvxpy_solver}"
        s += ")"
        return s

    def cvxpy_variables(self):
        if self._variables is None:
            self._variables = tuple(cp.Variable(name=self.col_name(j), nonneg=True)
                                    for j in range(self.ncols()))
        return self._variables

    def cvxpy_problem(self):
        """
        Return a ``cvxpy.Problem`` corresponding to ``self``

        EXAMPLES::

            sage: p = SemidefiniteProgram(solver="CVXPY")
            sage: x = p.new_variable()
            sage: p.set_objective(x[1] - x[0])
            sage: a1 = matrix(RDF, [[1, 2.], [2., 3.]])
            sage: a2 = matrix(RDF, [[3, 4.], [4., 5.]])
            sage: a3 = matrix(RDF, [[5, 6.], [6., 7.]])
            sage: b1 = matrix(RDF, [[1, 1.], [1., 1.]])
            sage: b2 = matrix(RDF, [[2, 2.], [2., 2.]])
            sage: b3 = matrix(RDF, [[3, 3.], [3., 3.]])
            sage: c1 = matrix(RDF, [[1.0, 0],[0,0]],sparse=True)
            sage: c2 = matrix(RDF, [[0.0, 0],[0,1]],sparse=True)
            sage: p.add_constraint(a1*x[0] + a2*x[1] <= a3)
            sage: p.add_constraint(b1*x[0] + b2*x[1] <= b3)
            sage: p.add_constraint(c1*x[0] + c2*x[1] >= matrix.zero(2,2,sparse=True))
            sage: print("possible deprecation warning"); cvxpy_problem = p.get_backend().cvxpy_problem(); cvxpy_problem
            possible deprecation warning...
            Problem(Maximize(Expression(AFFINE, UNKNOWN, ())),
             [PSD(Expression(AFFINE, UNKNOWN, (2, 2))),
              PSD(Expression(AFFINE, UNKNOWN, (2, 2))),
              PSD(Expression(AFFINE, NONNEGATIVE, (2, 2)))])
            sage: cvxpy_problem.solve()                           # rel tol 1e-6
            0.9999999998879393

        The :func:`Lovasz theta <sage.graphs.lovasz_theta.lovasz_theta>` of the 7-gon::

            sage: c=graphs.CycleGraph(7)
            sage: c2=c.distance_graph(2).adjacency_matrix()
            sage: c3=c.distance_graph(3).adjacency_matrix()
            sage: p.<y>=SemidefiniteProgram(solver="CVXPY")
            sage: p.add_constraint((1/7)*matrix.identity(7)>=-y[0]*c2-y[1]*c3)
            sage: p.set_objective(y[0]*(c2**2).trace()+y[1]*(c3**2).trace())
            sage: cvxpy_problem = p.get_backend().cvxpy_problem(); cvxpy_problem
            Problem(Maximize(Expression(AFFINE, NONNEGATIVE, ())),
             [PSD(Expression(AFFINE, NONNEGATIVE, (7, 7)))])
            sage: cvxpy_problem.solve() + 1                       # rel tol 1e-6
            3.3176672076690505
        """
        if self._problem is None:
            variables = self.cvxpy_variables()
            constraints = []
            for i in range(self.nrows()):
                indices, matrices = self.row(i)
                constraint = (sum((variables[j] if j >= 0 else 1) * matrix.numpy()
                                  for j, matrix in zip(indices, matrices))
                              << 0)
                constraints.append(constraint)
            objective_function = sum(variables[j] * float(self.objective_coefficient(j))
                                     for j in range(self.ncols()))
            if self.is_maximization():
                objective = cp.Maximize(objective_function)
            else:
                objective = cp.Minimize(objective_function)
            self._problem = cp.Problem(objective, constraints)
        return self._problem

    def solve(self, cvxpy_solver=None, cvxpy_solver_args=None):
        problem = self.cvxpy_problem()
        if cvxpy_solver is None:
            cvxpy_solver = self._cvxpy_solver
        if cvxpy_solver_args is None:
            cvxpy_solver_args = self._cvxpy_solver_args
            if cvxpy_solver_args is None:
                cvxpy_solver_args = dict()
        result = problem.solve(solver=cvxpy_solver, **cvxpy_solver_args)
        if isinstance(result, str):
            raise SDPSolverException(str)
        return 0

    def get_objective_value(self):
        """
        Return the value of the objective function.

        .. NOTE::

           Behaviour is undefined unless ``solve`` has been called before.

        EXAMPLES::

            sage: p = SemidefiniteProgram(solver="cvxpy", maximization=False)
            sage: x = p.new_variable()
            sage: p.set_objective(x[0] - x[1] + x[2])
            sage: a1 = matrix([[-7., -11.], [-11., 3.]])
            sage: a2 = matrix([[7., -18.], [-18., 8.]])
            sage: a3 = matrix([[-2., -8.], [-8., 1.]])
            sage: a4 = matrix([[33., -9.], [-9., 26.]])
            sage: b1 = matrix([[-21., -11., 0.], [-11., 10., 8.], [0.,   8., 5.]])
            sage: b2 = matrix([[0.,  10.,  16.], [10., -10., -10.], [16., -10., 3.]])
            sage: b3 = matrix([[-5.,   2., -17.], [2.,  -6.,   8.], [-17.,  8., 6.]])
            sage: b4 = matrix([[14., 9., 40.], [9., 91., 10.], [40., 10., 15.]])
            sage: p.add_constraint(a1*x[0] + a2*x[1] + a3*x[2] <= a4)
            sage: p.add_constraint(b1*x[0] + b2*x[1] + b3*x[2] <= b4)
            sage: N(p.solve(), digits=4)
            -3.154
            sage: N(p.get_backend().get_objective_value(), digits=4)
            -3.154
        """
        return self.cvxpy_problem().value

    def get_variable_value(self, variable):
        """
        Return the value of a variable given by the solver.

        .. NOTE::

           Behaviour is undefined unless ``solve`` has been called before.

        EXAMPLES::

            sage: from sage.numerical.backends.generic_sdp_backend import get_solver
            sage: p = SemidefiniteProgram(solver = "cvxpy", maximization=False)
            sage: x = p.new_variable()
            sage: p.set_objective(x[0] - x[1] + x[2])
            sage: a1 = matrix([[-7., -11.], [-11., 3.]])
            sage: a2 = matrix([[7., -18.], [-18., 8.]])
            sage: a3 = matrix([[-2., -8.], [-8., 1.]])
            sage: a4 = matrix([[33., -9.], [-9., 26.]])
            sage: b1 = matrix([[-21., -11., 0.], [-11., 10., 8.], [0.,   8., 5.]])
            sage: b2 = matrix([[0.,  10.,  16.], [10., -10., -10.], [16., -10., 3.]])
            sage: b3 = matrix([[-5.,   2., -17.], [2.,  -6.,   8.], [-17.,  8., 6.]])
            sage: b4 = matrix([[14., 9., 40.], [9., 91., 10.], [40., 10., 15.]])
            sage: p.add_constraint(a1*x[0] + a2*x[1] + a3*x[2] <= a4)
            sage: p.add_constraint(b1*x[0] + b2*x[1] + b3*x[2] <= b4)
            sage: N(p.solve(), digits=4)
            -3.154
            sage: N(p.get_backend().get_variable_value(0), digits=3)
            -0.368
            sage: N(p.get_backend().get_variable_value(1), digits=4)
            1.898
            sage: N(p.get_backend().get_variable_value(2), digits=3)
            -0.888
        """
        raise NotImplementedError

    def dual_variable(self, i, sparse=False):
        """
        The `i`-th dual variable

        Available after self.solve() is called, otherwise the result is undefined

        - ``index`` (integer) -- the constraint's id.

        OUTPUT:

        The matrix of the `i`-th dual variable

        EXAMPLES::

            sage: p = SemidefiniteProgram(maximization=False, solver='cvxpy')
            sage: x = p.new_variable()
            sage: p.set_objective(x[0] - x[1])
            sage: a1 = matrix([[1, 2.], [2., 3.]])
            sage: a2 = matrix([[3, 4.], [4., 5.]])
            sage: a3 = matrix([[5, 6.], [6., 7.]])
            sage: b1 = matrix([[1, 1.], [1., 1.]])
            sage: b2 = matrix([[2, 2.], [2., 2.]])
            sage: b3 = matrix([[3, 3.], [3., 3.]])
            sage: p.add_constraint(a1*x[0] + a2*x[1] <= a3)
            sage: p.add_constraint(b1*x[0] + b2*x[1] <= b3)
            sage: p.solve()                                     # tol 1e-08
            -3.0
            sage: B=p.get_backend()
            sage: x=p.get_values(x).values()
            sage: -(a3*B.dual_variable(0)).trace()-(b3*B.dual_variable(1)).trace()  # tol 1e-07
            -3.0
            sage: g = sum((B.slack(j)*B.dual_variable(j)).trace() for j in range(2)); g  # tol 1.5e-08
            0.0

        TESTS::

            sage: B.dual_variable(7)
            Traceback (most recent call last):
            ...
            IndexError: list index out of range
            sage: abs(g - B._get_answer()['gap'])   # tol 1e-22
            0.0

        """
        raise NotImplementedError

    def slack(self, i, sparse=False):
        """
        Slack of the `i`-th constraint

        Available after self.solve() is called, otherwise the result is undefined

        - ``index`` (integer) -- the constraint's id.

        OUTPUT:

        The matrix of the slack of the `i`-th constraint

        EXAMPLES::

            sage: p = SemidefiniteProgram(maximization=False, solver='cvxpy')
            sage: x = p.new_variable()
            sage: p.set_objective(x[0] - x[1])
            sage: a1 = matrix([[1, 2.], [2., 3.]])
            sage: a2 = matrix([[3, 4.], [4., 5.]])
            sage: a3 = matrix([[5, 6.], [6., 7.]])
            sage: b1 = matrix([[1, 1.], [1., 1.]])
            sage: b2 = matrix([[2, 2.], [2., 2.]])
            sage: b3 = matrix([[3, 3.], [3., 3.]])
            sage: p.add_constraint(a1*x[0] + a2*x[1] <= a3)
            sage: p.add_constraint(b1*x[0] + b2*x[1] <= b3)
            sage: p.solve()                         # tol 1e-08
            -3.0
            sage: B = p.get_backend()
            sage: B1 = B.slack(1); B1               # tol 1e-08
            [0.0 0.0]
            [0.0 0.0]
            sage: B1.is_positive_definite()
            True
            sage: x = sorted(p.get_values(x).values())
            sage: x[0]*b1 + x[1]*b2 - b3 + B1       # tol 1e-09
            [0.0 0.0]
            [0.0 0.0]

        TESTS::

            sage: B.slack(7)
            Traceback (most recent call last):
            ...
            IndexError: list index out of range

        """
        raise NotImplementedError
