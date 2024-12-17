# sage_setup: distribution = sagemath-pari

from .types cimport GEN, pari_sp
from .gen cimport Gen_base, Gen


cdef Gen new_gen(GEN x)
cdef new_gens2(GEN x, GEN y)
cdef Gen new_gen_noclear(GEN x)
cdef Gen clone_gen(GEN x)
cdef Gen clone_gen_noclear(GEN x)

cdef void clear_stack() noexcept
cdef void reset_avma() noexcept

cdef void remove_from_pari_stack(Gen self) noexcept
cdef int move_gens_to_heap(pari_sp lim) except -1

cdef int before_resize() except -1
cdef int set_pari_stack_size(size_t size, size_t sizemax) except -1
cdef void after_resize() noexcept


cdef class DetachGen:
    cdef source

    cdef GEN detach(self) except NULL
