# sage_setup: distribution = sagemath-flint
# Deprecated header file; use sage/libs/flint/acb_mat.pxd instead
# See https://github.com/sagemath/sage/pull/36449

from sage.libs.flint.types cimport acb_mat_struct, acb_mat_t

from sage.libs.flint.acb_mat cimport (
    acb_mat_nrows,
    acb_mat_ncols,
    acb_mat_entry,
    acb_mat_init,
    acb_mat_clear,
    acb_mat_allocated_bytes,
    acb_mat_set,
    acb_mat_printd,
    acb_mat_equal,
    acb_mat_overlaps,
    acb_mat_contains,
    acb_mat_eq,
    acb_mat_ne,
    acb_mat_is_real,
    acb_mat_is_empty,
    acb_mat_is_square,
    acb_mat_zero,
    acb_mat_one,
    acb_mat_transpose,
    acb_mat_frobenius_norm,
    acb_mat_neg,
    acb_mat_add,
    acb_mat_sub,
    acb_mat_mul,
    acb_mat_mul_classical,
    acb_mat_mul_threaded,
    acb_mat_mul_entrywise,
    acb_mat_sqr,
    acb_mat_pow_ui,
    acb_mat_scalar_mul_2exp_si,
    acb_mat_scalar_addmul_si,
    acb_mat_scalar_addmul_acb,
    acb_mat_scalar_mul_si,
    acb_mat_scalar_mul_acb,
    acb_mat_scalar_div_si,
    acb_mat_scalar_div_acb,
    acb_mat_lu,
    acb_mat_solve_lu_precomp,
    acb_mat_solve,
    acb_mat_inv,
    acb_mat_det,
    acb_mat_charpoly,
    acb_mat_exp_taylor_sum,
    acb_mat_exp,
    acb_mat_trace,
    acb_mat_get_mid,
    acb_mat_add_error_mag,
    acb_mat_approx_eig_qr,
    acb_mat_eig_global_enclosure,
    acb_mat_eig_enclosure_rump,
    acb_mat_eig_simple_rump,
    acb_mat_eig_simple_vdhoeven_mourrain,
    acb_mat_eig_simple,
    acb_mat_eig_multiple_rump,
    acb_mat_eig_multiple)
