# tdlib is a header-only library
if cc.has_header('treedec/combinations.hpp')
  tdlib = declare_dependency()
else
  tdlib = disabler()
endif
# Cannot be found via pkg-config
rw = cc.find_library('rw', required: false, disabler: true)

py.install_sources(
  '__init__.py',
  'all.py',
  'all__sagemath_tdlib.py',
  'fast_digraph.pxd',
  'modular_decomposition.pxd',
  'rankwidth.pxd',
  'slice_decomposition.pxd',
  'tree_decomposition.pxd',
  'vertex_separation.pxd',
  subdir: 'sage/graphs/graph_decompositions',
)

extension_data = {
  'bandwidth' : files('bandwidth.pyx'),
  'cutwidth' : files('cutwidth.pyx'),
  'fast_digraph' : files('fast_digraph.pyx'),
  'graph_products' : files('graph_products.pyx'),
  'rankwidth' : files('rankwidth.pyx'),
  'tree_decomposition' : files('tree_decomposition.pyx'),
  'vertex_separation' : files('vertex_separation.pyx'),
}

foreach name, pyx : extension_data
  deps = [py_dep, cysignals, gmp]
  if name == 'rankwidth'
    deps += [rw]
  endif
  py.extension_module(
    name,
    sources: pyx,
    subdir: 'sage/graphs/graph_decompositions',
    install: true,
    include_directories: [inc_cpython, inc_data_structures],
    dependencies: deps,
  )
endforeach

extension_data_cpp = {
  'clique_separators': files('clique_separators.pyx'),
  'slice_decomposition' : files('slice_decomposition.pyx'),
  'modular_decomposition' : files('modular_decomposition.pyx'),
}

foreach name, pyx : extension_data_cpp
  py.extension_module(
    name,
    sources: pyx,
    subdir: 'sage/graphs/graph_decompositions',
    install: true,
    override_options: ['cython_language=cpp'],
    include_directories: [inc_cpython, inc_data_structures],
    dependencies: [py_dep, cysignals, gmp],
  )
endforeach

py.extension_module(
  'tdlib',
  sources: 'tdlib.pyx',
  subdir: 'sage/graphs/graph_decompositions',
  install: true,
  override_options: ['cython_language=cpp'],
  include_directories: [inc_cpython, inc_data_structures],
  dependencies: [py_dep, cysignals, tdlib],
)

