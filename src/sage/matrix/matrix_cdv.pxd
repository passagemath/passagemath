# sage_setup: distribution = sagemath-modules
from sage.matrix.matrix_generic_dense cimport Matrix_generic_dense

cpdef hessenbergize_cdvf(Matrix_generic_dense)
