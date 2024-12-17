# sage_setup: distribution = sagemath-pari

from .pari_instance import Pari
from .handle_error import PariError
from .gen import Gen
from .custom_block import init_custom_block

init_custom_block()
