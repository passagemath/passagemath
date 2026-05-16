def _enable_graver_patch():
    from . import matrix_integer_dense as mid
    from sage.rings.integer_ring import ZZ
    from sage.modules.free_module import vector

    class GraverBasis(object):
        def __init__(self, A, engine='auto', **kwds):
            try:
                import py4ti2 as _py4ti2
            except Exception:
                import Py4ti2 as _py4ti2  # may raise again
            M = [[int(a) for a in row] for row in A.rows()]
            raw = _py4ti2.graver(M)
            n = A.ncols()
            self._vecs = [vector(ZZ, g) for g in raw]
            self._n = n
        def __iter__(self): return iter(self._vecs)
        def __len__(self): return len(self._vecs)
        def orthogonal_range_search(self, l, u):
            l = vector(ZZ, l); u = vector(ZZ, u)
            for v in self._vecs:
                if all(l[i] <= v[i] <= u[i] for i in range(self._n)):
                    yield v

    def graver_basis(self, engine='auto', **kwds):
        return GraverBasis(self, engine=engine, **kwds)

    mid.Matrix_integer_dense.graver_basis = graver_basis