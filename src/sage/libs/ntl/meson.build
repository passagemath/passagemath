py.install_sources(
  'GF2.pxd',
  'GF2E.pxd',
  'GF2EX.pxd',
  'GF2X.pxd',
  'ZZ.pxd',
  'ZZX.pxd',
  'ZZ_p.pxd',
  'ZZ_pE.pxd',
  'ZZ_pEX.pxd',
  'ZZ_pX.pxd',
  '__init__.py',
  'all.py',
  'conversion.pxd',
  'convert.pxd',
  'lzz_p.pxd',
  'lzz_pX.pxd',
  'mat_GF2.pxd',
  'mat_GF2E.pxd',
  'mat_ZZ.pxd',
  'ntl_GF2.pxd',
  'ntl_GF2E.pxd',
  'ntl_GF2EContext.pxd',
  'ntl_GF2EX.pxd',
  'ntl_GF2X.pxd',
  'ntl_ZZ.pxd',
  'ntl_ZZX.pxd',
  'ntl_ZZ_p.pxd',
  'ntl_ZZ_pContext.pxd',
  'ntl_ZZ_pE.pxd',
  'ntl_ZZ_pEContext.pxd',
  'ntl_ZZ_pEX.pxd',
  'ntl_ZZ_pX.pxd',
  'ntl_lzz_p.pxd',
  'ntl_lzz_pContext.pxd',
  'ntl_lzz_pX.pxd',
  'ntl_mat_GF2.pxd',
  'ntl_mat_GF2E.pxd',
  'ntl_mat_ZZ.pxd',
  'ntl_tools.pxd',
  'ntlwrap.h',
  'ntlwrap_impl.h',
  'types.pxd',
  'vec_GF2.pxd',
  'vec_GF2E.pxd',
  subdir: 'sage/libs/ntl',
)

extension_data_cpp = {
  'convert': files('convert.pyx'),
  'error': files('error.pyx'),
  'ntl_GF2': files('ntl_GF2.pyx'),
  'ntl_GF2E': files('ntl_GF2E.pyx'),
  'ntl_GF2EContext': files('ntl_GF2EContext.pyx'),
  'ntl_GF2EX': files('ntl_GF2EX.pyx'),
  'ntl_GF2X': files('ntl_GF2X.pyx'),
  'ntl_ZZ': files('ntl_ZZ.pyx'),
  'ntl_ZZX': files('ntl_ZZX.pyx'),
  'ntl_ZZ_p': files('ntl_ZZ_p.pyx'),
  'ntl_ZZ_pContext': files('ntl_ZZ_pContext.pyx'),
  'ntl_ZZ_pE': files('ntl_ZZ_pE.pyx'),
  'ntl_ZZ_pEContext': files('ntl_ZZ_pEContext.pyx'),
  'ntl_ZZ_pEX': files('ntl_ZZ_pEX.pyx'),
  'ntl_ZZ_pX': files('ntl_ZZ_pX.pyx'),
  'ntl_lzz_p': files('ntl_lzz_p.pyx'),
  'ntl_lzz_pContext': files('ntl_lzz_pContext.pyx'),
  'ntl_lzz_pX': files('ntl_lzz_pX.pyx'),
  'ntl_mat_GF2': files('ntl_mat_GF2.pyx'),
  'ntl_mat_GF2E': files('ntl_mat_GF2E.pyx'),
  'ntl_mat_ZZ': files('ntl_mat_ZZ.pyx'),
}

foreach name, pyx : extension_data_cpp
  py.extension_module(
    name,
    sources: pyx,
    subdir: 'sage/libs/ntl',
    install: true,
    override_options: ['cython_language=cpp'],
    include_directories: [
      inc_cpython,
      inc_ext,
      inc_ntl,
      inc_rings,
      inc_rings_finite,
    ],
    dependencies: [py_dep, cysignals, gmp, m, ntl],
  )
endforeach

