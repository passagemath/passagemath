# sage_setup: distribution = sagemath-pari
from .kernel import PARIKernel

from ipykernel.kernelapp import IPKernelApp
IPKernelApp.launch_instance(kernel_class=PARIKernel)
