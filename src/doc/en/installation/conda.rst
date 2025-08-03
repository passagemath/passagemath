.. _sec-installation-conda:

Installation on top of conda-forge
==================================

You will need a working Conda installation: either Miniforge, Miniconda or
Anaconda. If you don't have one yet, we recommend installing `Miniforge
<https://github.com/conda-forge/miniforge>`_ as follows. In a terminal,

.. code-block:: shell

    $ curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
    $ bash Miniforge3-$(uname)-$(uname -m).sh

* Miniforge uses conda-forge as the default channel. However, if you are using
  Miniconda or Anaconda, set it up to use conda-forge:

  * Add the conda-forge channel: ``conda config --add channels conda-forge``

  * Change channel priority to strict: ``conda config --set channel_priority strict``

If you installed Miniforge (or Mambaforge), we recommend to use
`mamba <https://mamba.readthedocs.io/en/latest/index.html>`_ in the following,
which uses a faster dependency solver than ``conda``.

Then continue with the normal installation.
