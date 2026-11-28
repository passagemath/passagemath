# sage_setup: distribution = sagemath-pari
# Save and restore the enclosing cysignals frame across Python callbacks.
from cysignals.signals cimport cysigs

cdef extern from *:
    """
    #include <stdlib.h>
    #include <string.h>
    #include "struct_signals.h"

    typedef struct
    {
        cyjmp_buf env;
        int sig_on_count;
        int block_sigint;
        const char *message;
    } cypari2_callback_signal_frame;

    static void *
    cypari2_callback_signal_push(void *opaque)
    {
        cysigs_t *state = (cysigs_t *)opaque;
        cypari2_callback_signal_frame *frame =
            (cypari2_callback_signal_frame *)malloc(sizeof(*frame));
        if (frame == NULL)
            return NULL;
        memcpy(frame->env, state->env, sizeof(frame->env));
        frame->sig_on_count = state->sig_on_count;
        frame->block_sigint = state->block_sigint;
        frame->message = state->s;

        /* A PARI call made by the Python callback must establish its own
         * jump target.  Otherwise nested sig_on() merely increments the
         * outer counter and an error jumps across live Python frames. */
        state->sig_on_count = 0;
        /* call_python() blocks interrupts around arbitrary Python code.  A
         * deliberate nested PARI call needs a complete inner signal frame,
         * though, otherwise SIGINT/SIGALRM remain deferred forever while the
         * nested computation runs.  With count == 0, signals received by
         * ordinary Python code are still recorded rather than long-jumping. */
        state->block_sigint = 0;
        return frame;
    }

    static void
    cypari2_callback_signal_pop(void *opaque, void *saved)
    {
        cysigs_t *state = (cysigs_t *)opaque;
        cypari2_callback_signal_frame *frame =
            (cypari2_callback_signal_frame *)saved;
        if (frame == NULL)
            return;
        memcpy(state->env, frame->env, sizeof(frame->env));
        state->sig_on_count = frame->sig_on_count;
        state->block_sigint = frame->block_sigint;
        state->s = frame->message;
        free(frame);
    }
    """
    void *cypari2_callback_signal_push(void *state) noexcept
    void cypari2_callback_signal_pop(void *state, void *saved) noexcept


cdef void *callback_signal_push() except NULL:
    """Allow PARI calls in a Python callback to use a nested jump target."""
    cdef void *saved = cypari2_callback_signal_push(<void *>&cysigs)
    if saved is NULL:
        raise MemoryError
    return saved


cdef void callback_signal_pop(void *saved) noexcept:
    """Restore the PARI caller's cysignals jump target."""
    cypari2_callback_signal_pop(<void *>&cysigs, saved)
