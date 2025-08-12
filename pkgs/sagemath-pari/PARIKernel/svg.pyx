# sage_setup: distribution = sagemath-pari
#cython: language_level=3
#
# Helper module to handle SVG images produced by PARI
#
# Copyright (C) 2017 Jeroen Demeyer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


from .paridecl cimport *

cdef pari_kernel


def init_svg(kernel):
    global pari_kernel
    pari_kernel = kernel
    pari_set_plot_engine(get_plot)


cdef void get_plot(PARI_plot* T) noexcept nogil:
    # Values copied from src/graph/plotsvg.c in PARI sources
    T.width = 480
    T.height = 320
    T.hunit = 3
    T.vunit = 3
    T.fwidth = 9
    T.fheight = 12

    T.draw = draw


cdef void draw(PARI_plot *T, GEN w, GEN x, GEN y) noexcept nogil:
    global avma
    cdef pari_sp av = avma
    cdef char* svg = rect2svg(w, x, y, T)
    with gil:
        pari_kernel.publish_svg(svg, T.width, T.height)
    avma = av
