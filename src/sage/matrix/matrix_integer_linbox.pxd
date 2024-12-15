# sage_setup: distribution = sagemath-linbox

from sage.matrix.matrix_integer_dense cimport Matrix_integer_dense

cpdef _lift_crt(Matrix_integer_dense M, residues, moduli=*)
