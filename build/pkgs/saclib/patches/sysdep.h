#include <endian.h>
#include <bits/wordsize.h>

#if __BYTE_ORDER == __LITTLE_ENDIAN
# define _LITTLE_ENDIAN_
# undef _BIG_ENDIAN_
#else
# undef _LITTLE_ENDIAN_
# define _BIG_ENDIAN_
#endif

/* Enable use of fesetround(FE_DOWNWARD) and fesetround(FE_UPWARD) where
 * supported.
 */
#include <fenv.h>
#if defined(FE_DOWNWARD) && defined(FE_UPWARD)
# define _X86_LINUX_
#endif
