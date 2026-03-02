# sage_setup: distribution = sagemath-categories
class CallableDict(dict):
    def __call__(self, key: object) -> object:
        ...

    def __repr__(self) -> str:
        ...
