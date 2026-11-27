/*
 * Additional macros and fixes for the PARI headers. This is meant to
 * be included after including <pari/pari.h>
 */

#undef coeff  /* Conflicts with NTL (which is used by SageMath) */


/* Array element assignment */
#define set_gel(x, n, z)         (gel((x), (n)) = (z))
#define set_gmael(x, i, j, z)    (gmael((x), (i), (j)) = (z))
#define set_gcoeff(x, i, j, z)   (gcoeff((x), (i), (j)) = (z))
#define set_uel(x, n, z)         (uel((x), (n)) = (z))

/* PARI 2.19 precision arguments are exact bit counts. Older versions
 * expect a t_REAL word length, including its two header words. */
static inline long
cypari2_prec_bits_to_pari(long bits)
{
#if PARI_VERSION_CODE >= PARI_VERSION(2,19,0)
    return bits;
#else
    return nbits2prec(bits);
#endif
}
