# sage_setup: distribution = sagemath-repl
"""
This file (./combinat_doctest.sage) was *autogenerated* from ./combinat.tex,
with sagetex.sty version 2011/05/27 v2.3.1.
It contains the contents of all the sageexample environments from this file.
You should be able to doctest this file with:
sage -t ./combinat_doctest.sage
It is always safe to delete this file; it is not used in typesetting your
document.

Sage example in ./combinat.tex, line 147::

  sage: Suits = Set(["Hearts", "Diamonds", "Spades", "Clubs"])
  sage: Values = Set([2, 3, 4, 5, 6, 7, 8, 9, 10,
  ....:               "Jack", "Queen", "King", "Ace"])
  sage: Cards = cartesian_product([Values, Suits])

Sage example in ./combinat.tex, line 167::

  sage: Suits.cardinality()
  4
  sage: Values.cardinality()
  13
  sage: Cards.cardinality()
  52

Sage example in ./combinat.tex, line 184::

  sage: Cards.random_element()                      # random
  (6, 'Clubs')

Sage example in ./combinat.tex, line 196::

  sage: Set([Cards.random_element(), Cards.random_element()]) # random
  {(2, 'Hearts'), (4, 'Spades')}

Sage example in ./combinat.tex, line 221::

  sage: Hands = Subsets(Cards, 5)
  sage: Hands.random_element()                      # random
  {(4, 'Hearts'), (9, 'Diamonds'), (8, 'Spades'),
   (9, 'Clubs'), (7, 'Hearts')}

Sage example in ./combinat.tex, line 236::

  sage: binomial(52, 5)
  2598960

Sage example in ./combinat.tex, line 250::

  sage: Hands.cardinality()
  2598960

Sage example in ./combinat.tex, line 283::

  sage: Flushes = cartesian_product([Subsets(Values, 5), Suits])
  sage: Flushes.cardinality()
  5148

Sage example in ./combinat.tex, line 305::

  sage: Flushes.cardinality()  / Hands.cardinality()
  33/16660

Sage example in ./combinat.tex, line 310::

  sage: 1000.0 * Flushes.cardinality()  / Hands.cardinality()
  1.98079231692677

Sage example in ./combinat.tex, line 345::

  sage: def is_flush(hand):
  ....:     return len(set(suit for (val, suit) in hand)) == 1

Sage example in ./combinat.tex, line 354::

  sage: n = 10000
  sage: nflush = 0
  sage: for i in range(n):
  ....:    hand = Hands.random_element()
  ....:    if is_flush(hand):
  ....:        nflush += 1
  sage: print(n, nflush)                              # random
  10000, 18

Sage example in ./combinat.tex, line 600::

  sage: C, z = var('C, z'); sys = [ C == z + C*C ]

Sage example in ./combinat.tex, line 605::

  sage: sol = solve(sys, C, solution_dict=True); sol
  [{C: -1/2*sqrt(-4*z + 1) + 1/2}, {C: 1/2*sqrt(-4*z + 1) + 1/2}]
  sage: s0 = sol[0][C]; s1 = sol[1][C]

Sage example in ./combinat.tex, line 612::

  sage: s0.series(z, 6)
  1*z + 1*z^2 + 2*z^3 + 5*z^4 + 14*z^5 + Order(z^6)
  sage: s1.series(z, 6)
  1 + (-1)*z + (-1)*z^2 + (-2)*z^3 + (-5)*z^4 + (-14)*z^5 + Order(z^6)

Sage example in ./combinat.tex, line 622::

  sage: C = s0

Sage example in ./combinat.tex, line 627::

  sage: C.series(z, 11)
  1*z + 1*z^2 + 2*z^3 + 5*z^4 + 14*z^5 + 42*z^6 +
  132*z^7 + 429*z^8 + 1430*z^9 + 4862*z^10 + Order(z^11)

Sage example in ./combinat.tex, line 634::

  sage: C.series(z, 101).coefficient(z,100)
  227508830794229349661819540395688853956041682601541047340

Sage example in ./combinat.tex, line 654::

  sage: L.<z> = LazyPowerSeriesRing(QQ)

Sage example in ./combinat.tex, line 661::

  sage: C = L.undefined(valuation=1)
  sage: C.define( z + C * C )

Sage example in ./combinat.tex, line 666::

  sage: [C.coefficient(i) for i in range(11)]
  [0, 1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862]

Sage example in ./combinat.tex, line 674::

  sage: C.coefficient(100)
  227508830794229349661819540395688853956041682601541047340

Sage example in ./combinat.tex, line 684::

  sage: C.coefficient(200)
  129013158064429114001222907669676675134349530552728882499810851598901419013348319045534580850847735528275750122188940

Sage example in ./combinat.tex, line 693::

  sage: z = var('z'); C = s0; C
  -1/2*sqrt(-4*z + 1) + 1/2

Sage example in ./combinat.tex, line 703::

  sage: derivative(C, z, 1)
  1/sqrt(-4*z + 1)
  sage: derivative(C, z, 2)
  2/(-4*z + 1)^(3/2)
  sage: derivative(C, z, 3)
  12/(-4*z + 1)^(5/2)

Sage example in ./combinat.tex, line 716::

  sage: def d(n): return derivative(C, n).subs(z=0)

Sage example in ./combinat.tex, line 721::

  sage: [ (d(n+1) / d(n)) for n in range(1,17) ]
  [2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62]

Sage example in ./combinat.tex, line 737::

  sage: def c(n): return 1/n*binomial(2*(n-1),n-1)
  sage: [c(k) for k in range(1, 11)]
  [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862]
  sage: [catalan_number(k-1) for k in range(1, 11)]
  [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862]

Sage example in ./combinat.tex, line 814::

  sage: x, y, z = var('x, y, z')
  sage: P = function('P')(x, y); C = function('C')(z)
  sage: equation = P(x=z, y=C) == 0
  sage: diff(equation, z)
  diff(C(z), z)*D[1](P)(z, C(z)) + D[0](P)(z, C(z)) == 0

Sage example in ./combinat.tex, line 834::

  sage: P = y^2 - y + x; Px = diff(P, x); Py = diff(P, y)
  sage: - Px / Py
  -1/(2*y - 1)

Sage example in ./combinat.tex, line 847::

  sage: Qx = QQ['x'].fraction_field(); Qxy = Qx['y']
  sage: R = Qxy.quo(P); R
  Univariate Quotient Polynomial Ring in ybar
  over Fraction Field of Univariate Polynomial Ring in x
  over Rational Field with modulus y^2 - y + x

Sage example in ./combinat.tex, line 863::

  sage: fraction = R( - Px / Py ); fraction
  Traceback (most recent call last):
  ...
  TypeError: unable to convert -1/(2*y - 1) to an element of Univariate Quotient Polynomial Ring in ybar over Fraction Field of Univariate Polynomial Ring in x over Rational Field with modulus y^2 - y + x

Sage example in ./combinat.tex, line 869::

  sage: fraction = - R(Px) / R(Py); fraction
  (1/2/(x - 1/4))*ybar - 1/4/(x - 1/4)

Sage example in ./combinat.tex, line 877::

  sage: fraction = fraction.lift(); fraction
  (1/2/(x - 1/4))*y - 1/4/(x - 1/4)
  sage: fraction(x=z, y=C)
  2*C(z)/(4*z - 1) - 1/(4*z - 1)

Sage example in ./combinat.tex, line 894::

  sage: equadiff = diff(C,z) == fraction(x=z, y=C); equadiff
  diff(C(z), z) == 2*C(z)/(4*z - 1) - 1/(4*z - 1)
  sage: equadiff = equadiff.simplify_rational()
  sage: equadiff = equadiff * equadiff.rhs().denominator()
  sage: equadiff = equadiff - equadiff.rhs()
  sage: equadiff
  (4*z - 1)*diff(C(z), z) - 2*C(z) + 1 == 0

Sage example in ./combinat.tex, line 913::

  sage: Cf = sage.symbolic.function_factory.function('C')
  sage: equadiff.substitute_function(Cf, lambda z: s0(z=z))
  (4*z - 1)/sqrt(-4*z + 1) + sqrt(-4*z + 1) == 0

Sage example in ./combinat.tex, line 923::

  sage: Cf = sage.symbolic.function_factory.function('C')
  sage: bool(equadiff.substitute_function(Cf, lambda z: s0(z=z)))
  True

Sage example in ./combinat.tex, line 959::

  sage: def C(n): return n if n <= 1 else (4*n-6)/n * C(n-1)
  sage: [ C(i) for i in range(10) ]
  [0, 1, 1, 2, 5, 14, 42, 132, 429, 1430]

Sage example in ./combinat.tex, line 1078::

  sage: binomial(4, 2)
  6

Sage example in ./combinat.tex, line 1088::

  sage: S = Subsets([1,2,3,4], 2); S.cardinality()
  6

Sage example in ./combinat.tex, line 1097::

  sage: S.list()
  [{1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4}]
  sage: S.random_element()                 # random
  {1, 4}
  sage: S.an_element()
  {2, 3}

Sage example in ./combinat.tex, line 1118::

  sage: S.unrank(4)
  {2, 4}
  sage: S[4]
  {2, 4}

Sage example in ./combinat.tex, line 1133::

  sage: s = S([2,4]); S.rank(s)
  4

Sage example in ./combinat.tex, line 1145::

  sage: E = Set([1,2,3,4])
  sage: S = Subsets(Subsets(Subsets(E))); S.cardinality()
  2003529930406846464979072351560255750447825475569751419265016...736

Sage example in ./combinat.tex, line 1167::

  sage: S.cardinality().ndigits()
  19729

Sage example in ./combinat.tex, line 1179::

  sage: sorted(sorted(sorted(x) for x in y) for y in S.unrank(237102123) )
  [[[], [1, 2, 4], [1, 3], [1, 3, 4], [1, 4], [2], [2, 3], [2, 4], [4]],
   [[], [1, 2, 4], [1, 3], [2, 4], [3, 4]]]

Sage example in ./combinat.tex, line 1237::

  sage: P5 = Partitions(5); P5
  Partitions of the integer 5

Sage example in ./combinat.tex, line 1243::

  sage: P5.cardinality()
  7

Sage example in ./combinat.tex, line 1251::

  sage: P5.list()
  [[5], [4, 1], [3, 2], [3, 1, 1], [2, 2, 1], [2, 1, 1, 1],
   [1, 1, 1, 1, 1]]

Sage example in ./combinat.tex, line 1279::

  sage: Partitions(100000).cardinality()
  27493510569775696512677516320986352688173429315980054758203125984302147328114964173055050741660736621590157844774296248940493063070200461792764493033510116079342457190155718943509725312466108452006369558934464248716828789832182345009262853831404597021307130674510624419227311238999702284408609370935531629697851569569892196108480158600569421098519

Sage example in ./combinat.tex, line 1291::

  sage: P7 = Partitions(7); p = P7.unrank(5); p
  [4, 2, 1]

Sage example in ./combinat.tex, line 1295::

  sage: type(p)
  <class 'sage.combinat.partition.Partitions_n_with_category.element_class'>

Sage example in ./combinat.tex, line 1302::

  sage: print(p.ferrers_diagram())
  ****
  **
  *

Sage example in ./combinat.tex, line 1315::

  sage: Partition([4,2,1])
  [4, 2, 1]
  sage: P7([4,2,1])
  [4, 2, 1]

Sage example in ./combinat.tex, line 1330::

  sage: WeightedIntegerVectors(8, [2,3,5]).list()
  [[0, 1, 1], [1, 2, 0], [4, 0, 0]]

Sage example in ./combinat.tex, line 1343::

  sage: C5 = Compositions(5); C5
  Compositions of 5
  sage: C5.cardinality()
  16
  sage: C5.list()
  [[1, 1, 1, 1, 1], [1, 1, 1, 2], [1, 1, 2, 1], [1, 1, 3],
   [1, 2, 1, 1], [1, 2, 2], [1, 3, 1], [1, 4], [2, 1, 1, 1],
   [2, 1, 2], [2, 2, 1], [2, 3], [3, 1, 1], [3, 2], [4, 1], [5]]

Sage example in ./combinat.tex, line 1360::

  sage: [ Compositions(n).cardinality() for n in range(10) ]
  [1, 1, 2, 4, 8, 16, 32, 64, 128, 256]

Sage example in ./combinat.tex, line 1368::

  sage: x = var('x'); sum( x^len(c) for c in C5 )
  x^5 + 4*x^4 + 6*x^3 + 4*x^2 + x

Sage example in ./combinat.tex, line 1414::

  sage: C = IntegerRange(3, 21, 2); C
  {3, 5, ..., 19}
  sage: C.cardinality()
  9
  sage: C.list()
  [3, 5, 7, 9, 11, 13, 15, 17, 19]

Sage example in ./combinat.tex, line 1424::

  sage: C = Permutations(4); C
  Standard permutations of 4
  sage: C.cardinality()
  24
  sage: C.list()
  [[1, 2, 3, 4], [1, 2, 4, 3], [1, 3, 2, 4], [1, 3, 4, 2],
   [1, 4, 2, 3], [1, 4, 3, 2], [2, 1, 3, 4], [2, 1, 4, 3],
   [2, 3, 1, 4], [2, 3, 4, 1], [2, 4, 1, 3], [2, 4, 3, 1],
   [3, 1, 2, 4], [3, 1, 4, 2], [3, 2, 1, 4], [3, 2, 4, 1],
   [3, 4, 1, 2], [3, 4, 2, 1], [4, 1, 2, 3], [4, 1, 3, 2],
   [4, 2, 1, 3], [4, 2, 3, 1], [4, 3, 1, 2], [4, 3, 2, 1]]

Sage example in ./combinat.tex, line 1455::

  sage: C = SetPartitions([1,2,3]); C
  Set partitions of {1, 2, 3}
  sage: C.cardinality()
  5
  sage: C.list()                       # random
  [{{1, 2, 3}}, {{1}, {2, 3}}, {{1, 3}, {2}}, {{1, 2}, {3}}, {{1}, {2}, {3}}]

Sage example in ./combinat.tex, line 1466::

  sage: C = Posets(8); C
  Posets containing 8 elements
  sage: C.cardinality()
  16999

Sage example in ./combinat.tex, line 1475::

  sage: show(C.unrank(20))
  Finite poset containing 8 elements

Sage example in ./combinat.tex, line 1496::

  sage: len(list(graphs(5)))
  34

Sage example in ./combinat.tex, line 1504::

  sage: for g in graphs(5, lambda G: G.size() <= 4):
  ....:     show(g)

Sage example in ./combinat.tex, line 1528::

  sage: G = DihedralGroup(4); G
  Dihedral group of order 8 as a permutation group
  sage: G.cardinality()
  8
  sage: sorted(G.list(), key=str)
  [(), (1,2)(3,4), (1,2,3,4), (1,3), (1,3)(2,4), (1,4)(2,3), (1,4,3,2), (2,4)]

Sage example in ./combinat.tex, line 1542::

  sage: import sage.repl.display.util
  sage: sage.repl.display.util.TallListFormatter.MAX_COLUMN = 67

Sage example in ./combinat.tex, line 1547::

  sage: C = MatrixSpace(GF(2), 2); C.list()
  [
  [0 0]  [1 0]  [0 1]  [0 0]  [0 0]  [1 1]  [1 0]  [1 0]  [0 1]
  [0 0], [0 0], [0 0], [1 0], [0 1], [0 0], [1 0], [0 1], [1 0],
  <BLANKLINE>
  [0 1]  [0 0]  [1 1]  [1 1]  [1 0]  [0 1]  [1 1]
  [0 1], [1 1], [1 0], [0 1], [1 1], [1 1], [1 1]
  ]

Sage example in ./combinat.tex, line 1557::

  sage: C.cardinality()
  16

Sage example in ./combinat.tex, line 1634::

  sage: [ i^2 for i in [1, 3, 7] ]
  [1, 9, 49]

Sage example in ./combinat.tex, line 1640::

  sage: [ i^2 for i in range(1,10) ]
  [1, 4, 9, 16, 25, 36, 49, 64, 81]

Sage example in ./combinat.tex, line 1651::

  sage: [ i^2 for i in range(1,10) if is_prime(i) ]
  [4, 9, 25, 49]

Sage example in ./combinat.tex, line 1661::

  sage: [ (i,j) for i in range(1,6) for j in range(1,i) ]
  [(2, 1), (3, 1), (3, 2), (4, 1), (4, 2), (4, 3),
   (5, 1), (5, 2), (5, 3), (5, 4)]

Sage example in ./combinat.tex, line 1668::

  sage: [[binomial(n, i) for i in range(n+1)] for n in range(10)]
  [[1],
   [1, 1],
   [1, 2, 1],
   [1, 3, 3, 1],
   [1, 4, 6, 4, 1],
   [1, 5, 10, 10, 5, 1],
   [1, 6, 15, 20, 15, 6, 1],
   [1, 7, 21, 35, 35, 21, 7, 1],
   [1, 8, 28, 56, 70, 56, 28, 8, 1],
   [1, 9, 36, 84, 126, 126, 84, 36, 9, 1]]

Sage example in ./combinat.tex, line 1718::

  sage: it = (binomial(3, i) for i in range(4))

Sage example in ./combinat.tex, line 1724::

  sage: next(it)
  1
  sage: next(it)
  3
  sage: next(it)
  3
  sage: next(it)
  1

Sage example in ./combinat.tex, line 1736::

  sage: next(it)
  Traceback (most recent call last):
    ...
  StopIteration

Sage example in ./combinat.tex, line 1754::

  sage: for s in Subsets(3): s
  {}
  {1}
  {2}
  {3}
  {1, 2}
  {1, 3}
  {2, 3}
  {1, 2, 3}

Sage example in ./combinat.tex, line 1765::

  sage: [ s.cardinality() for s in Subsets(3) ]
  [0, 1, 1, 1, 2, 2, 2, 3]

Sage example in ./combinat.tex, line 1772::

  sage: sum( [ binomial(8, i) for i in range(9) ] )
  256

Sage example in ./combinat.tex, line 1784::

  sage: sum( binomial(8, i) for i in range(9) )
  256

Sage example in ./combinat.tex, line 1811::

  sage: list(binomial(8, i) for i in range(9))
  [1, 8, 28, 56, 70, 56, 28, 8, 1]
  sage: tuple(binomial(8, i) for i in range(9))
  (1, 8, 28, 56, 70, 56, 28, 8, 1)

Sage example in ./combinat.tex, line 1823::

  sage: all([True, True, True, True])
  True
  sage: all([True, False, True, True])
  False
  sage: any([False, False, False, False])
  False
  sage: any([False, False, True, False])
  True

Sage example in ./combinat.tex, line 1839::

  sage: all( is_odd(p) for p in range(3,100) if is_prime(p) )
  True

Sage example in ./combinat.tex, line 1852::

  sage: def mersenne(p): return 2^p - 1
  sage: [ is_prime(p) for p in range(1000) if is_prime(mersenne(p)) ]
  [True, True, True, True, True, True, True, True, True, True,
   True, True, True, True]

Sage example in ./combinat.tex, line 1867::

  sage: all( [ is_prime(mersenne(p)) for p in range(1000) if is_prime(p)] )
  False
  sage: all(   is_prime(mersenne(p)) for p in range(1000) if is_prime(p)  )
  False

Sage example in ./combinat.tex, line 1879::

  sage: exists( (p for p in range(1000) if is_prime(p)),
  ....:         lambda p: not is_prime(mersenne(p)) )
  (True, 11)

Sage example in ./combinat.tex, line 1895::

  sage: counter_examples = \
  ....:   (p for p in range(1000)
  ....:      if is_prime(p) and not is_prime(mersenne(p)))
  sage: next(counter_examples)
  11
  sage: next(counter_examples)
  23

Sage example in ./combinat.tex, line 1909::

  sage: cubes = [t**3 for t in range(-999,1000)]
  sage: exists([(x,y) for x in cubes for y in cubes], lambda xy: sum(xy) == 218)  # long time
  (True, (-125, 343))
  sage: exists(((x,y) for x in cubes for y in cubes), lambda xy: sum(xy) == 218)  # long time
  (True, (-125, 343))

Sage example in ./combinat.tex, line 1927::

  sage: x = var('x'); sum( x^len(s) for s in Subsets(8) )
  x^8 + 8*x^7 + 28*x^6 + 56*x^5 + 70*x^4 + 56*x^3 + 28*x^2 + 8*x + 1

Sage example in ./combinat.tex, line 1931::

  sage: sum( x^p.length() for p in Permutations(3) )
  x^3 + 2*x^2 + 2*x + 1

Sage example in ./combinat.tex, line 1940::

  sage: P = Permutations(5)
  sage: all( p in P for p in P )
  True

Sage example in ./combinat.tex, line 1945::

  sage: for p in GL(2, 2): print(p); print("-----")
  [1 0]
  [0 1]
  -----
  [0 1]
  [1 0]
  -----
  [0 1]
  [1 1]
  -----
  [1 1]
  [0 1]
  -----
  [1 1]
  [1 0]
  -----
  [1 0]
  [1 1]
  -----

Sage example in ./combinat.tex, line 1966::

  sage: for p in Partitions(3): print(p)
  [3]
  [2, 1]
  [1, 1, 1]

Sage example in ./combinat.tex, line 1987::

  sage: exists( Primes(), lambda p: not is_prime(mersenne(p)) )
  (True, 11)

Sage example in ./combinat.tex, line 2026::

  sage: import itertools

Sage example in ./combinat.tex, line 2033::

  sage: list(Permutations(3))
  [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]

Sage example in ./combinat.tex, line 2039::

  sage: list(enumerate(Permutations(3)))
  [(0, [1, 2, 3]), (1, [1, 3, 2]), (2, [2, 1, 3]),
   (3, [2, 3, 1]), (4, [3, 1, 2]), (5, [3, 2, 1])]

Sage example in ./combinat.tex, line 2048::

  sage: list(itertools.islice(Permutations(3), 1r, 4r))
  [[1, 3, 2], [2, 1, 3], [2, 3, 1]]

Sage example in ./combinat.tex, line 2054::

  sage: list(map(lambda z: z.cycle_type(), Permutations(3)))
  [[1, 1, 1], [2, 1], [2, 1], [3], [3], [2, 1]]

Sage example in ./combinat.tex, line 2060::

  sage: list(filter(lambda z: z.has_pattern([1,2]),
  ....:                        Permutations(3)))
  [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2]]

Sage example in ./combinat.tex, line 2069::

  sage: list(map(attrcall("cycle_type"), Permutations(3)))
  [[1, 1, 1], [2, 1], [2, 1], [3], [3], [2, 1]]

Sage example in ./combinat.tex, line 2084::

  sage: def f(n):
  ....:    for i in range(n):
  ....:        yield i

Sage example in ./combinat.tex, line 2097::

  sage: g = f(4)
  sage: next(g)
  0
  sage: next(g)
  1
  sage: next(g)
  2
  sage: next(g)
  3

Sage example in ./combinat.tex, line 2108::

  sage: next(g)
  Traceback (most recent call last):
    ...
  StopIteration

Sage example in ./combinat.tex, line 2116::

  sage: [ x for x in f(5) ]
  [0, 1, 2, 3, 4]

Sage example in ./combinat.tex, line 2130::

  sage: def words(alphabet, l):
  ....:    if l == 0: yield []
  ....:    else:
  ....:        for word in words(alphabet, l-1):
  ....:            for l in alphabet: yield word + [l]
  sage: [ w for w in words(['a','b'], 3) ]
  [['a', 'a', 'a'], ['a', 'a', 'b'], ['a', 'b', 'a'], ['a', 'b', 'b'],
   ['b', 'a', 'a'], ['b', 'a', 'b'], ['b', 'b', 'a'], ['b', 'b', 'b']]

Sage example in ./combinat.tex, line 2142::

  sage: sum(1 for w in words(['a','b','c','d'], 10))
  1048576

Sage example in ./combinat.tex, line 2169::

  sage: def dyck_words(l):
  ....:     if l == 0: yield ''
  ....:     else:
  ....:         for k in range(l):
  ....:             for w1 in dyck_words(k):
  ....:                 for w2 in dyck_words(l-k-1):
  ....:                     yield '(' + w1 + ')' + w2

Sage example in ./combinat.tex, line 2180::

  sage: list(dyck_words(4))
  ['()()()()', '()()(())', '()(())()', '()(()())', '()((()))',
   '(())()()', '(())(())', '(()())()', '((()))()', '(()()())',
   '(()(()))', '((())())', '((()()))', '(((())))']

Sage example in ./combinat.tex, line 2188::

  sage: [ sum(1 for w in dyck_words(l)) for l in range(10) ]
  [1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862]

Sage example in ./combinat.tex, line 2208::

  sage: BT = BinaryTree
  sage: BT()
  .
  sage: t = BT([BT([BT(), BT([BT(),BT()])]), BT()]); t
  [[., [., .]], .]

Sage example in ./combinat.tex, line 2261::

  sage: C = cartesian_product([Compositions(8), Permutations(20)]); C
  The Cartesian product of (Compositions of 8, Standard permutations of 20)
  sage: C.cardinality()
  311411457046609920000

Sage example in ./combinat.tex, line 2274::

  sage: C.random_element()                        # random
  ([2, 3, 2, 1], [10, 6, 11, 13, 14, 3, 4, 19, 5, 12, 7, 18, 15, 8, 20, 1, 17, 2, 9, 16])

Sage example in ./combinat.tex, line 2288::

  sage: G = DihedralGroup(4)
  sage: H = cartesian_product([G,G])
  sage: H.cardinality()
  64
  sage: H in Sets().Enumerated().Finite()
  True
  sage: H in Groups()
  True

Sage example in ./combinat.tex, line 2305::

  sage: C = DisjointUnionEnumeratedSets([Compositions(4),Permutations(3)])
  sage: C
  Disjoint union of Family (Compositions of 4, Standard permutations of 3)
  sage: C.cardinality()
  14
  sage: C.list()
  [[1, 1, 1, 1], [1, 1, 2], [1, 2, 1], [1, 3], [2, 1, 1], [2, 2], [3, 1],
  [4], [1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]

Sage example in ./combinat.tex, line 2328::

  sage: F = Family(NonNegativeIntegers(), Permutations); F
  Lazy family (<class 'sage.combinat.permutation.Permutations'>(i))_{i in Non negative integers}
  sage: F.keys()
  Non negative integers
  sage: F[1000]
  Standard permutations of 1000

Sage example in ./combinat.tex, line 2339::

  sage: U = DisjointUnionEnumeratedSets(F); U
  Disjoint union of
  Lazy family (<class 'sage.combinat.permutation.Permutations'>(i))_{i in Non negative integers}

Sage example in ./combinat.tex, line 2346::

  sage: U.cardinality()
  +Infinity

Sage example in ./combinat.tex, line 2372::

  sage: U = Permutations(); U
  Standard permutations

Sage example in ./combinat.tex, line 2450::

  sage: IntegerVectors(10, 3, min_part = 2, max_part = 5,
  ....:                inner = [2, 4, 2]).list()
  [[4, 4, 2], [3, 5, 2], [3, 4, 3], [2, 5, 3], [2, 4, 4]]

Sage example in ./combinat.tex, line 2459::

  sage: Compositions(5, max_part = 3,
  ....:              min_length = 2, max_length = 3).list()
  [[3, 2], [3, 1, 1], [2, 3], [2, 2, 1], [2, 1, 2], [1, 3, 1],
   [1, 2, 2], [1, 1, 3]]

Sage example in ./combinat.tex, line 2467::

  sage: Partitions(5, max_slope = -1).list()
  [[5], [4, 1], [3, 2]]

Sage example in ./combinat.tex, line 2484::

  sage: IntegerListsLex(10, length=3, min_part = 2, max_part = 5,
  ....:                 floor = [2, 4, 2]).list()
  [[4, 4, 2], [3, 5, 2], [3, 4, 3], [2, 5, 3], [2, 4, 4]]

Sage example in ./combinat.tex, line 2489::

  sage: IntegerListsLex(5, min_part = 1, max_part = 3,
  ....:                 min_length = 2, max_length = 3).list()
  [[3, 2], [3, 1, 1], [2, 3], [2, 2, 1], [2, 1, 2], [1, 3, 1],
   [1, 2, 2], [1, 1, 3]]

Sage example in ./combinat.tex, line 2495::

  sage: IntegerListsLex(5, min_part = 1, max_slope = -1).list()
  [[5], [4, 1], [3, 2]]

Sage example in ./combinat.tex, line 2499::

  sage: list(Compositions(5, max_length=2))
  [[5], [4, 1], [3, 2], [2, 3], [1, 4]]

Sage example in ./combinat.tex, line 2503::

  sage: list(IntegerListsLex(5, max_length=2, min_part=1))
  [[5], [4, 1], [3, 2], [2, 3], [1, 4]]

Sage example in ./combinat.tex, line 2625::

  sage: A = random_matrix(ZZ, 6, 3, x=7)
  sage: L = LatticePolytope(A.rows())
  sage: L.points()                               # random
  M(1, 4, 3),
  M(6, 4, 1),
  ...
  M(3, 5, 5)
  in 3-d lattice M
  sage: L.points().cardinality()                 # random
  23

Sage example in ./combinat.tex, line 2637::

  sage: L.points()
  M(...),
  M(...),
  ...
  M(...)
  in 3-d lattice M

Sage example in ./combinat.tex, line 2647::

  sage: L.plot3d()
  Graphics3d Object

Sage example in ./combinat.tex, line 2688::

  sage: from sage.combinat.species.library import *
  sage: o = var('o')

Sage example in ./combinat.tex, line 2697::

  sage: BT = CombinatorialSpecies(min=1)
  sage: Leaf =  SingletonSpecies()
  sage: BT.define( Leaf + (BT*BT) )

Sage example in ./combinat.tex, line 2707::

  sage: BT5 = BT.isotypes([o]*5); BT5.cardinality()
  14
  sage: BT5.list()
  [o*(o*(o*(o*o))), o*(o*((o*o)*o)), o*((o*o)*(o*o)), o*((o*(o*o))*o),
   o*(((o*o)*o)*o), (o*o)*(o*(o*o)), (o*o)*((o*o)*o), (o*(o*o))*(o*o),
   ((o*o)*o)*(o*o), (o*(o*(o*o)))*o, (o*((o*o)*o))*o, ((o*o)*(o*o))*o,
   ((o*(o*o))*o)*o, (((o*o)*o)*o)*o]

Sage example in ./combinat.tex, line 2727::

  sage: g = BT.isotype_generating_series(); g
  z + z^2 + 2*z^3 + 5*z^4 + 14*z^5 + 42*z^6 + 132*z^7 + O(z^8)

Sage example in ./combinat.tex, line 2733::

  sage: g[100]
  227508830794229349661819540395688853956041682601541047340

Sage example in ./combinat.tex, line 2743::

  sage: Eps = EmptySetSpecies(); Z0 = SingletonSpecies()
  sage: Z1 = Eps*SingletonSpecies()
  sage: FW  = CombinatorialSpecies()
  sage: FW.define(Eps + Z0*FW  +  Z1*Eps + Z1*Z0*FW)

Sage example in ./combinat.tex, line 2752::

  sage: L = FW.isotype_generating_series()[:15]; L
  [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987]

Sage example in ./combinat.tex, line 2769::

  sage: FW3 = FW.isotypes([o]*3)
  sage: FW3.list()
  [o*(o*(o*{})), o*(o*(({}*o)*{})), o*((({}*o)*o)*{}),
   (({}*o)*o)*(o*{}), (({}*o)*o)*(({}*o)*{})]

Sage example in ./combinat.tex, line 3007::

  sage: [len(list(graphs(n, property = lambda G: G.is_planar())))
  ....:  for n in range(7)]
  [1, 1, 2, 4, 11, 33, 142]

Sage example in ./combinat.tex, line 3066::

  sage: V = [1,2,3,4]
  sage: F = Subsets(V, 2); F.list()
  [{1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4}]

Sage example in ./combinat.tex, line 3072::

  sage: S = SymmetricGroup(V)

Sage example in ./combinat.tex, line 3077::

  sage: def on_pair(sigma, pair):
  ....:     return Set(sigma(i) for i in pair)
  sage: def on_pairs(sigma):
  ....:     return [on_pair(sigma, e) for e in F]

Sage example in ./combinat.tex, line 3086::

  sage: sigma = S([(1,2,3,4)]); sigma
  (1,2,3,4)
  sage: for e in F: print((e, on_pair(sigma, e)))
  ({1, 2}, {2, 3})
  ({1, 3}, {2, 4})
  ({1, 4}, {1, 2})
  ({2, 3}, {3, 4})
  ({2, 4}, {1, 3})
  ({3, 4}, {1, 4})
  sage: on_pairs(sigma)
  [{2, 3}, {2, 4}, {1, 2}, {3, 4}, {1, 3}, {1, 4}]

Sage example in ./combinat.tex, line 3102::

  sage: G = PermutationGroup([ on_pairs(sigma) for sigma in S.gens() ],
  ....:                      domain=F)

Sage example in ./combinat.tex, line 3109::

  sage: Z = G.cycle_index(); Z
  1/24*p[1, 1, 1, 1, 1, 1] + 3/8*p[2, 2, 1, 1] + 1/3*p[3, 3] + 1/4*p[4, 2]

Sage example in ./combinat.tex, line 3117::

  sage: sorted(sigma for sigma in G if sigma.cycle_type() == [4,2])
  [({1,2},{1,3},{3,4},{2,4})({1,4},{2,3}),
   ({1,2},{1,4},{3,4},{2,3})({1,3},{2,4}),
   ({1,2},{2,3},{3,4},{1,4})({1,3},{2,4}),
   ({1,2},{2,4},{3,4},{1,3})({1,4},{2,3}),
   ({1,2},{3,4})({1,3},{1,4},{2,4},{2,3}),
   ({1,2},{3,4})({1,3},{2,3},{2,4},{1,4})]

Sage example in ./combinat.tex, line 3136::

  sage: q,t = QQ['q,t'].gens()
  sage: p = Z.expand(2, [q,t]); p
  q^6 + q^5*t + 2*q^4*t^2 + 3*q^3*t^3 + 2*q^2*t^4 + q*t^5 + t^6

Sage example in ./combinat.tex, line 3146::

  sage: p(q=1,t=1)
  11

Sage example in ./combinat.tex, line 3159::

  sage: q = var('q')
  sage: H = sum( c * prod( 1/(1-q^k) for k in partition )
  ....:          for partition, c in Z )
  sage: H
  1/3/(q^3 - 1)^2 + 1/4/((q^4 - 1)*(q^2 - 1))
  + 3/8/((q^2 - 1)^2*(q - 1)^2) + 1/24/(q - 1)^6

Sage example in ./combinat.tex, line 3171::

  sage: H.series(q)
  1 + 1*q + 3*q^2 + 6*q^3 + 11*q^4 + 18*q^5 + 32*q^6 + 48*q^7
  + 75*q^8 + 111*q^9 + 160*q^10 + 224*q^11 + 313*q^12 + 420*q^13
  + 562*q^14 + 738*q^15 + 956*q^16 + 1221*q^17 + 1550*q^18 + 1936*q^19
  + Order(q^20)

Sage example in ./combinat.tex, line 3185::

  sage: n = 10
  sage: V = range(1,n+1)
  sage: F = Subsets(V, 2)
  sage: S = SymmetricGroup(V)
  sage: G = PermutationGroup([ on_pairs(sigma) for sigma in S.gens() ],
  ....:                      domain=F)
  sage: q,t = QQ['q,t'].gens()
  sage: Z = G.cycle_index()
  sage: Z.expand(2, [q,t])(q=1,t=1)
  12005168

Sage example in ./combinat.tex, line 3202::

  sage: n = 20
  sage: V = range(1,n+1)
  sage: F = Subsets(V, 2)
  sage: S = SymmetricGroup(V)
  sage: CC = S.conjugacy_classes(); CC  # long time
  [...
   Conjugacy class of cycle type [19, 1] in Symmetric group of order 20! as a permutation group,
   Conjugacy class of cycle type [20] in Symmetric group of order 20! as a permutation group]

Sage example in ./combinat.tex, line 3214::

  sage: p = SymmetricFunctions(QQ).powersum()
  sage: G = PermutationGroup([ on_pairs(sigma) for sigma in S.gens() ],
  ....:                      domain=F)
  sage: Z = p.sum_of_terms([G(on_pairs(c.representative())).cycle_type(),  # long time
  ....:                     c.cardinality()]
  ....:                    for c in CC) / factorial(n)
  sage: Z.expand(2, [q,t])(q=1,t=1)  # long time
  645490122795799841856164638490742749440
"""
