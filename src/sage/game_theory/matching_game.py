from sage.structure.sage_object import SageObject
from sage.rings.integer import Integer
from copy import deepcopy, copy
from sage.matrix.constructor import matrix
from sage.graphs.bipartite_graph import BipartiteGraph


class MatchingGame(SageObject):
    r"""
    EXAMPLES:

        quick test. ::

            sage: suitr_pref = {'J': ['A', 'D', 'C', 'B'],
            ....:               'K': ['A', 'B', 'C', 'D'],
            ....:               'L': ['B', 'D', 'C', 'A'],
            ....:               'M': ['C', 'A', 'B', 'D']}
            sage: reviewr_pref = {'A': ['L', 'J', 'K', 'M'],
            ....:                 'B': ['J', 'M', 'L', 'K'],
            ....:                 'C': ['K', 'M', 'L', 'J'],
            ....:                 'D': ['M', 'K', 'J', 'L']}
            sage: m = MatchingGame([suitr_pref, reviewr_pref])
            sage: m.suitors
            ['K', 'J', 'M', 'L']
            sage: m.reviewers
            ['A', 'C', 'B', 'D']
            sage: m.solve()
            {'A': ['J'],
             'C': ['K'],
             'B': ['M'],
             'D': ['L'],
             'K': ['C'],
             'J': ['A'],
             'M': ['B'],
             'L': ['D']}
            sage: plot(m)
            sage: graph = m.bi_partite()
            sage: graph
            Bipartite graph on 8 vertices

        works for numbers too. ::

            sage: suit = {0: [3, 4],
            ....:         1: [3, 4]}
            sage: revr = {3: [0, 1],
            ....:         4: [1, 0]}
            sage: g = MatchingGame([suit, revr])
    """
    def __init__(self, generator):
        r"""
        Initializes a Matching Game and checks the inputs.

        TESTS:

        8 player letter game. ::

            sage: suitr_pref = {'J': ['A', 'D', 'C', 'B'],
            ....:               'K': ['A', 'B', 'C', 'D'],
            ....:               'L': ['B', 'D', 'C', 'A'],
            ....:               'M': ['C', 'A', 'B', 'D']}
            sage: reviewr_pref = {'A': ['L', 'J', 'K', 'M'],
            ....:                 'B': ['J', 'M', 'L', 'K'],
            ....:                 'C': ['K', 'M', 'L', 'J'],
            ....:                 'D': ['M', 'K', 'J', 'L']}
            sage: m = MatchingGame([suitr_pref, reviewr_pref])
            sage: m.suitors
            ['K', 'J', 'M', 'L']
            sage: m.reviewers
            ['A', 'C', 'B', 'D']

        Also works for numbers. ::

            sage: suit = {0: [3, 4],
            ....:         1: [3, 4]}
            sage: revr = {3: [0, 1],
            ....:         4: [1, 0]}
            sage: g = MatchingGame([suit, revr])
        """
        self.suitors = []
        self.reviewers = []
        if type(generator) is Integer:
            for i in range(generator):
                self.add_suitor()
                self.add_reviewer()
        if type(generator[0]) is dict and type(generator[1]) is dict:
            self._dict_game(generator[0], generator[1])
        else:
            raise TypeError("generator must be an integer or a list of 2 dictionaries.")

    def _dict_game(self, suitor_dict, reviwer_dict):
        r"""
        Populates the game from 2 dictionaries. One for reviewers and one for
        suitors.
        """
        for i in suitor_dict:
            self.add_suitor(i)
        for k in reviwer_dict:
            self.add_reviewer(k)

        for i in self.suitors:
            i.pref = suitor_dict[i.name]
        for k in self.reviewers:
            k.pref = reviwer_dict[k.name]

    def _repr_(self):
        r"""
        """
        pass

    def _latex_(self):
        r"""
        """
        pass

    def plot(self):
        r"""
        Creates the plot representing the stable matching for the game.
        """
        pl = self.bi_partite()
        return pl.plot()

    def bi_partite(self):
        r"""
        Constructs a ``BipartiteGraph`` Object of the game.
        """
        self._is_sovled()

        sol_dict = self._sol_dict()
        graph = BipartiteGraph(sol_dict)
        return(graph)

    def _is_sovled(self):
        r"""
        Checks if the Game has been solved yet.
        """
        suitor_check = all(s.partner for s in self.suitors)
        reviewer_check = all(r.partner for r in self.reviewers)
        if not suitor_check or not reviewer_check:
            raise ValueError("Game has not been solved yet")

    def _is_complete(self):
        r"""
        Checks that all players have acceptable preferences.
        """
        if len(self.suitors) != len(self.reviewers):
            raise ValueError("Must have the same number of reviewers as suitors")

        for suitor in self.suitors:
            if list(suitor.pref).sort() != self.reviewers.sort():
                raise ValueError("Suitor preferences incomplete")

        for reviewer in self.reviewers:
            if list(reviewer.pref).sort() != self.suitors.sort():
                raise ValueError("Reviewer preferences incomplete")

    def add_suitor(self, name=False):
        r"""
        Adds a suitor to the game.

        INPUTS:

        -``name`` - Can be a string or numer. If left blank will automatically
                    generate an integer.
        """
        if name is False:
            name = len(self.suitors)
        new_suitor = _Player(name, 'suitor', len(self.reviewers))
        self.suitors.append(new_suitor)
        for r in self.reviewers:
            r.pref = [-1 for s in self.suitors]

    def add_reviewer(self, name=False):
        r"""
        Adds a reviewer to the game.

        INPUTS:

        -``name`` - Can be a string or numer. If left blank will automatically
                    generate an integer.
        """
        if name is False:
            name = len(self.reviewers)
        new_reviewer = _Player(name, 'reviewer', len(self.suitors))
        self.reviewers.append(new_reviewer)
        for s in self.suitors:
            s.pref = [-1 for r in self.reviewers]

    def _sol_dict(self):
        r"""
        Creates a dictionary of the stable matching. Keys are the player,
        values are their partner as a single element list. This is to allow
        the creation of ``BipartiteGraph``.
        """
        self._is_sovled()

        sol_dict = {}
        for s in self.suitors:
            sol_dict[s] = [s.partner]
        for r in self.reviewers:
            sol_dict[r] = [r.partner]
        return sol_dict

    def solve(self, invert=False):
        r"""
        Computes a stable matching for the game using the Gale-Shapley
        algorithm.

        EXAMPLES:

        6 player game. ::

            sage: left_dict = {'a': ('A', 'B', 'C'),
            ....:              'b': ('B', 'C', 'A'),
            ....:              'c': ('B', 'A', 'C')}
            sage: right_dict = {'A': ('b', 'c', 'a'),
            ....:               'B': ('a', 'c', 'b'),
            ....:               'C': ('a', 'b', 'c')}
            sage: quick_game = MatchingGame([left_dict, right_dict])
            sage: quick_game.solve()
            {'a': ['A'],
             'A': ['a'],
             'c': ['B'],
             'b': ['C'],
             'C': ['b'],
             'B': ['c']}
            sage: quick_game.solve(invert=True)
            {'a': ['B'],
             'A': ['c'],
             'c': ['A'],
             'b': ['C'],
             'C': ['b'],
             'B': ['a']}

        """
        self._is_complete()

        for s in self.suitors:
            s.partner = False
        for r in self.reviewers:
            r.partner = False

        if invert:
            reviewers = deepcopy(self.suitors)
            suitors = deepcopy(self.reviewers)
        else:
            suitors = deepcopy(self.suitors)
            reviewers = deepcopy(self.reviewers)

        while len([s for s in suitors if s.partner is False]) != 0:
            s = [s for s in suitors if s.partner is False][0]
            r = next((x for x in reviewers if x.name == s.pref[0]), None)
            if r.partner is False:
                r.partner = s
                s.partner = r
            elif r.pref.index(s) < r.pref.index(r.partner):
                r.partner.partner = False
                r.partner = s
                s.partner = r
            else:
                s.pref = s.pref[1:]

        if invert:
            suitors, reviewers = reviewers, suitors

        for i, j in zip(self.suitors, suitors):
            i.partner = j.partner
        for i, j in zip(self.reviewers, reviewers):
            i.partner = j.partner

        return self._sol_dict()


class _Player():
    def __init__(self, name, player_type, len_pref):
        self.name = name
        self.type = player_type
        self.pref = [-1 for i in range(len_pref)]
        self.partner = False

    def __hash__(self):
        return hash(self.name)

    def __repr__(self):
        return repr(self.name)

    def __eq__(self, other):
        return self.__repr__() == other.__repr__()

