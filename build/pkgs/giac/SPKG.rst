giac: A general purpose computer algebra system
===============================================

Description
-----------

Giac is a general purpose Computer algebra system by Bernard Parisse.

It consists of:

-  a C++ library (libgiac).

-  a command line interpreter (icas or giac).

-  the build of the FLTK-based GUI (xcas) has been disabled in the
   spkg-install file.

-  The english documentation will be installed in:

   $SAGE_LOCAL/share/giac/doc/en/cascmd_en/index.html

-  Author's website with debian, ubuntu, macosx, windows package:

   http://www-fourier.ujf-grenoble.fr/~parisse/giac.html

-  The Freebsd port is math/giacxcas

Licence
-------

GPLv3+

Note: except the french html documentation which is freely
redistributable for non commercial only purposes. This doc has been
removed in the released tarball used by Sage.


Upstream Contact
----------------

-  Bernard Parisse:
   http://www-fourier.ujf-grenoble.fr/~parisse/giac.html

-  Source file (giac-x.y.z-t.tar.gz) in:
   http://www-fourier.ujf-grenoble.fr/~parisse/debian/dists/stable/main/source/

-  We use a release tarball prepared at https://github.com/passagemath/giac


Dependencies
------------

-  The Documentation is pre-built, hevea or latex or ... are not needed
   to install the package.


Special Update/Build Instructions
---------------------------------

-  To build the gui (xcas), use::

     export GIAC_CONFIGURE="--enable-fltk"
