/*
 * Additional macros and fixes for the PARI headers. This is meant to
 * be included after including <pari/pari.h>
 */

#undef coeff  /* Conflicts with NTL (which is used by SageMath) */
