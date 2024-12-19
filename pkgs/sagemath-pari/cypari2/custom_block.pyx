# sage_setup: distribution = sagemath-pari
# distutils: libraries = gmp pari

#*****************************************************************************
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

from cysignals.signals cimport add_custom_signals

cdef extern from "pari/pari.h":
    int     PARI_SIGINT_block, PARI_SIGINT_pending

cdef int custom_signal_is_blocked() noexcept:
    return PARI_SIGINT_block

cdef void custom_signal_unblock() noexcept:
    global PARI_SIGINT_block
    PARI_SIGINT_block = 0

cdef void custom_set_pending_signal(int sig) noexcept:
    global PARI_SIGINT_pending
    PARI_SIGINT_pending = sig

def init_custom_block():
    add_custom_signals(&custom_signal_is_blocked,
                       &custom_signal_unblock,
                       &custom_set_pending_signal)
