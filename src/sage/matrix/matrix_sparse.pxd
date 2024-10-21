# sage_setup: distribution = sagemath-modules
<<<<<<< HEAD

from sage.matrix.matrix cimport Matrix
||||||| merged common ancestors
from .matrix cimport Matrix
=======
from .matrix cimport Matrix
>>>>>>> main

cdef class Matrix_sparse(Matrix):
    pass
