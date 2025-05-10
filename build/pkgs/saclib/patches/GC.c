/*======================================================================
                           GC()

Garbage collection entry-point.

This is a system- and compiler-dependent function which ensures that all
registers get pushed onto the stack. This is necessary since the GC-proper
GCSI() assumes that all GC roots are either located on the stack or in the
global variables.
======================================================================*/

#include <ucontext.h>
#include "saclib.h"

void GC(void)
{
  ucontext_t context;

  getcontext (&context);
  GCSI(sizeof(Word), (char *)&context);
}
