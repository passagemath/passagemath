# sage_setup: distribution = sagemath-categories
from sage.combinat.matrices.all__sagemath_categories import *

from sage.misc.lazy_import import lazy_import

# Integer lists
from sage.combinat.integer_lists import IntegerListsLex
from sage.combinat.integer_vector import IntegerVectors
lazy_import('sage.combinat.integer_vector_weighted', 'WeightedIntegerVectors')

from sage.combinat.combinat import (CombinatorialObject,
                                    bell_number, bell_polynomial, bernoulli_polynomial,
                                    catalan_number, euler_number,
                                    fibonacci, fibonacci_sequence, fibonacci_xrange,
                                    lucas_number1, lucas_number2,
                                    number_of_tuples, number_of_unordered_tuples,
                                    polygonal_number, stirling_number1, stirling_number2,
                                    tuples, unordered_tuples)

from sage.combinat.combination import Combinations
from sage.combinat.composition import Composition, Compositions
from sage.combinat.permutation import Permutation, Permutations, Arrangements, CyclicPermutations, CyclicPermutationsOfPartition
from sage.combinat.partition import (Partition, Partitions, PartitionsInBox,
                                     OrderedPartitions, PartitionsGreatestLE,
                                     PartitionsGreatestEQ, number_of_partitions)
from sage.combinat.subset import Subsets, subsets, powerset, uniq
from sage.combinat.tuple import Tuples, UnorderedTuples

lazy_import('sage.combinat.q_analogues', ['gaussian_binomial', 'q_binomial',
                                          'number_of_irreducible_polynomials'])

from sage.combinat.dlx import DLXMatrix, AllExactCovers, OneExactCover

del lazy_import
