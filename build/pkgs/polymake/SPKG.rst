polymake: Computations with polyhedra, fans, simplicial complexes, matroids, graphs, tropical hypersurfaces
===========================================================================================================

Description
-----------

polymake is open source software for research in polyhedral geometry. It
deals with polytopes, polyhedra and fans as well as simplicial
complexes, matroids, graphs, tropical hypersurfaces, and other objects.
Supported platforms include various flavors of Linux, Free BSD and Mac
OS.

License
-------

-  GPL v3


Upstream Contact
----------------

-  https://polymake.org/

Dependencies
------------

Polymake needs a working installation of Perl, including its shared
library and some modules (``XML::Writer XML::LibXML XML::LibXSLT
Term::ReadLine::Gnu JSON SVG``). The Sage distribution provides
these using Perlbrew.

Before installing the ``polymake`` package, refer to the SPKG pages for the following packages to ensure a more featureful Polymake installation:

- [4ti2](https://passagemath.org/docs/latest/html/en/reference/spkg/4ti2.html)
- [latte_int](https://passagemath.org/docs/latest/html/en/reference/spkg/latte_int.html)
- [topcom](https://passagemath.org/docs/latest/html/en/reference/spkg/topcom.html)
- [qhull](https://passagemath.org/docs/latest/html/en/reference/spkg/qhull.html)

For additional software that may enhance your Polymake installation (but for which no Sage package is available), you can manually install the following:

- ``azove``
- ``porta``
- ``vinci``
- ``SplitsTree4``

Information on missing Polymake prerequisites after installing polymake::

   $ sage -sh
   (sage-sh) $ polymake
   polytope> show_unconfigured;

In order to use Polymake from Sage, please install [passagemath-polymake](https://passagemath.org/docs/latest/html/en/reference/spkg/sagemath_polymake.html).



Debugging polymake install problems
-----------------------------------

::

  # apt-get install libdevel-trace-perl
  $ cd src
  $ perl -d:Trace support/configure.pl
