# sage_setup: distribution = sagemath-flint
# distutils: libraries = flint
# distutils: depends = flint/fexpr.h

################################################################################
# This file is auto-generated by the script
#   SAGE_ROOT/src/sage_setup/autogen/flint_autogen.py.
# From the commit 3e2c3a3e091106a25ca9c6fba28e02f2cbcd654a
# Do not modify by hand! Fix and rerun the script instead.
################################################################################

from libc.stdio cimport FILE
from sage.libs.gmp.types cimport *
from sage.libs.mpfr.types cimport *
from sage.libs.flint.types cimport *

cdef extern from "flint_wrap.h":
    void fexpr_init(fexpr_t expr) noexcept
    void fexpr_clear(fexpr_t expr) noexcept
    fexpr_ptr _fexpr_vec_init(slong len) noexcept
    void _fexpr_vec_clear(fexpr_ptr vec, slong len) noexcept
    void fexpr_fit_size(fexpr_t expr, slong size) noexcept
    void fexpr_set(fexpr_t res, const fexpr_t expr) noexcept
    void fexpr_swap(fexpr_t a, fexpr_t b) noexcept
    slong fexpr_depth(const fexpr_t expr) noexcept
    slong fexpr_num_leaves(const fexpr_t expr) noexcept
    slong fexpr_size(const fexpr_t expr) noexcept
    slong fexpr_size_bytes(const fexpr_t expr) noexcept
    slong fexpr_allocated_bytes(const fexpr_t expr) noexcept
    bint fexpr_equal(const fexpr_t a, const fexpr_t b) noexcept
    bint fexpr_equal_si(const fexpr_t expr, slong c) noexcept
    bint fexpr_equal_ui(const fexpr_t expr, ulong c) noexcept
    ulong fexpr_hash(const fexpr_t expr) noexcept
    int fexpr_cmp_fast(const fexpr_t a, const fexpr_t b) noexcept
    bint fexpr_is_integer(const fexpr_t expr) noexcept
    bint fexpr_is_symbol(const fexpr_t expr) noexcept
    bint fexpr_is_string(const fexpr_t expr) noexcept
    bint fexpr_is_atom(const fexpr_t expr) noexcept
    void fexpr_zero(fexpr_t res) noexcept
    bint fexpr_is_zero(const fexpr_t expr) noexcept
    bint fexpr_is_neg_integer(const fexpr_t expr) noexcept
    void fexpr_set_si(fexpr_t res, slong c) noexcept
    void fexpr_set_ui(fexpr_t res, ulong c) noexcept
    void fexpr_set_fmpz(fexpr_t res, const fmpz_t c) noexcept
    int fexpr_get_fmpz(fmpz_t res, const fexpr_t expr) noexcept
    void fexpr_set_symbol_builtin(fexpr_t res, slong id) noexcept
    bint fexpr_is_builtin_symbol(const fexpr_t expr, slong id) noexcept
    bint fexpr_is_any_builtin_symbol(const fexpr_t expr) noexcept
    void fexpr_set_symbol_str(fexpr_t res, const char * s) noexcept
    char * fexpr_get_symbol_str(const fexpr_t expr) noexcept
    void fexpr_set_string(fexpr_t res, const char * s) noexcept
    char * fexpr_get_string(const fexpr_t expr) noexcept
    void fexpr_write(calcium_stream_t stream, const fexpr_t expr) noexcept
    void fexpr_print(const fexpr_t expr) noexcept
    char * fexpr_get_str(const fexpr_t expr) noexcept
    void fexpr_write_latex(calcium_stream_t stream, const fexpr_t expr, ulong flags) noexcept
    void fexpr_print_latex(const fexpr_t expr, ulong flags) noexcept
    char * fexpr_get_str_latex(const fexpr_t expr, ulong flags) noexcept
    slong fexpr_nargs(const fexpr_t expr) noexcept
    void fexpr_func(fexpr_t res, const fexpr_t expr) noexcept
    void fexpr_view_func(fexpr_t view, const fexpr_t expr) noexcept
    void fexpr_arg(fexpr_t res, const fexpr_t expr, slong i) noexcept
    void fexpr_view_arg(fexpr_t view, const fexpr_t expr, slong i) noexcept
    void fexpr_view_next(fexpr_t view) noexcept
    bint fexpr_is_builtin_call(const fexpr_t expr, slong id) noexcept
    bint fexpr_is_any_builtin_call(const fexpr_t expr) noexcept
    void fexpr_call0(fexpr_t res, const fexpr_t f) noexcept
    void fexpr_call1(fexpr_t res, const fexpr_t f, const fexpr_t x1) noexcept
    void fexpr_call2(fexpr_t res, const fexpr_t f, const fexpr_t x1, const fexpr_t x2) noexcept
    void fexpr_call3(fexpr_t res, const fexpr_t f, const fexpr_t x1, const fexpr_t x2, const fexpr_t x3) noexcept
    void fexpr_call4(fexpr_t res, const fexpr_t f, const fexpr_t x1, const fexpr_t x2, const fexpr_t x3, const fexpr_t x4) noexcept
    void fexpr_call_vec(fexpr_t res, const fexpr_t f, fexpr_srcptr args, slong len) noexcept
    void fexpr_call_builtin1(fexpr_t res, slong f, const fexpr_t x1) noexcept
    void fexpr_call_builtin2(fexpr_t res, slong f, const fexpr_t x1, const fexpr_t x2) noexcept
    bint fexpr_contains(const fexpr_t expr, const fexpr_t x) noexcept
    int fexpr_replace(fexpr_t res, const fexpr_t expr, const fexpr_t x, const fexpr_t y) noexcept
    int fexpr_replace2(fexpr_t res, const fexpr_t expr, const fexpr_t x1, const fexpr_t y1, const fexpr_t x2, const fexpr_t y2) noexcept
    int fexpr_replace_vec(fexpr_t res, const fexpr_t expr, const fexpr_vec_t xs, const fexpr_vec_t ys) noexcept
    void fexpr_set_fmpq(fexpr_t res, const fmpq_t x) noexcept
    void fexpr_set_arf(fexpr_t res, const arf_t x) noexcept
    void fexpr_set_d(fexpr_t res, double x) noexcept
    void fexpr_set_re_im_d(fexpr_t res, double x, double y) noexcept
    void fexpr_neg(fexpr_t res, const fexpr_t a) noexcept
    void fexpr_add(fexpr_t res, const fexpr_t a, const fexpr_t b) noexcept
    void fexpr_sub(fexpr_t res, const fexpr_t a, const fexpr_t b) noexcept
    void fexpr_mul(fexpr_t res, const fexpr_t a, const fexpr_t b) noexcept
    void fexpr_div(fexpr_t res, const fexpr_t a, const fexpr_t b) noexcept
    void fexpr_pow(fexpr_t res, const fexpr_t a, const fexpr_t b) noexcept
    bint fexpr_is_arithmetic_operation(const fexpr_t expr) noexcept
    void fexpr_arithmetic_nodes(fexpr_vec_t nodes, const fexpr_t expr) noexcept
    int fexpr_get_fmpz_mpoly_q(fmpz_mpoly_q_t res, const fexpr_t expr, const fexpr_vec_t vars, const fmpz_mpoly_ctx_t ctx) noexcept
    void fexpr_set_fmpz_mpoly(fexpr_t res, const fmpz_mpoly_t poly, const fexpr_vec_t vars, const fmpz_mpoly_ctx_t ctx) noexcept
    void fexpr_set_fmpz_mpoly_q(fexpr_t res, const fmpz_mpoly_q_t frac, const fexpr_vec_t vars, const fmpz_mpoly_ctx_t ctx) noexcept
    int fexpr_expanded_normal_form(fexpr_t res, const fexpr_t expr, ulong flags) noexcept
    void fexpr_vec_init(fexpr_vec_t vec, slong len) noexcept
    void fexpr_vec_clear(fexpr_vec_t vec) noexcept
    void fexpr_vec_print(const fexpr_vec_t vec) noexcept
    void fexpr_vec_swap(fexpr_vec_t x, fexpr_vec_t y) noexcept
    void fexpr_vec_fit_length(fexpr_vec_t vec, slong len) noexcept
    void fexpr_vec_set(fexpr_vec_t dest, const fexpr_vec_t src) noexcept
    void fexpr_vec_append(fexpr_vec_t vec, const fexpr_t expr) noexcept
    slong fexpr_vec_insert_unique(fexpr_vec_t vec, const fexpr_t expr) noexcept
    void fexpr_vec_set_length(fexpr_vec_t vec, slong len) noexcept
    void _fexpr_vec_sort_fast(fexpr_ptr vec, slong len) noexcept
