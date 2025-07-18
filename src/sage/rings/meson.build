py.install_sources(
  '__init__.py',
  'abc.pxd',
  'algebraic_closure_finite_field.py',
  'all.py',
  'all__sagemath_objects.py',
  'big_oh.py',
  'cc.py',
  'cfinite_sequence.py',
  'cif.py',
  'commutative_algebra.py',
  'complex_arb.pxd',
  'complex_conversion.pxd',
  'complex_double.pxd',
  'complex_interval.pxd',
  'complex_interval_field.py',
  'complex_mpc.pxd',
  'complex_mpfr.pxd',
  'continued_fraction.py',
  'continued_fraction_gosper.py',
  'derivation.py',
  'fast_arith.pxd',
  'fraction_field.py',
  'fraction_field_FpT.pxd',
  'generic.py',
  'homset.py',
  'ideal.py',
  'ideal_monoid.py',
  'imaginary_unit.py',
  'infinity.py',
  'integer.pxd',
  'integer.pyx',
  'integer_fake.h',
  'integer_fake.pxd',
  'integer_ring.pxd',
  'integer_ring.pyx',
  'laurent_series_ring.py',
  'laurent_series_ring_element.pxd',
  'lazy_series.py',
  'lazy_series_ring.py',
  'localization.py',
  'monomials.py',
  'morphism.pxd',
  'multi_power_series_ring.py',
  'multi_power_series_ring_element.py',
  'numbers_abc.py',
  'pari_ring.py',
  'power_series_mpoly.pxd',
  'power_series_pari.pxd',
  'power_series_poly.pxd',
  'power_series_ring.py',
  'power_series_ring_element.pxd',
  'puiseux_series_ring.py',
  'puiseux_series_ring_element.pxd',
  'qqbar.py',
  'qqbar_decorators.py',
  'quotient_ring.py',
  'quotient_ring_element.py',
  'rational.pxd',
  'rational.pyx',
  'rational_field.py',
  'real_arb.pxd',
  'real_double.pxd',
  'real_double_element_gsl.pxd',
  'real_field.py',
  'real_lazy.pxd',
  'real_mpfi.pxd',
  'real_mpfr.pxd',
  'ring.pxd',
  'ring_extension.pxd',
  'ring_extension_conversion.pxd',
  'ring_extension_element.pxd',
  'ring_extension_homset.py',
  'ring_extension_morphism.pxd',
  'species.py',
  'sum_of_squares.pxd',
  'tate_algebra.py',
  'tate_algebra_element.pxd',
  'tate_algebra_ideal.pxd',
  'tests.py',
  'universal_cyclotomic_field.py',
  subdir: 'sage/rings',
)

extension_data = {
  'abc' : files('abc.pyx'),
  'complex_arb' : files('complex_arb.pyx'),
  'complex_conversion' : files('complex_conversion.pyx'),
  'complex_interval' : files('complex_interval.pyx'),
  'complex_mpc' : files('complex_mpc.pyx'),
  'complex_mpfr' : files('complex_mpfr.pyx'),
  'factorint' : files('factorint.pyx'),
  'factorint_flint' : files('factorint_flint.pyx'),
  'factorint_pari' : files('factorint_pari.pyx'),
  'fast_arith' : files('fast_arith.pyx'),
  'fraction_field_element' : files('fraction_field_element.pyx'),
  'integer' : files('integer.pyx'),
  'integer_ring' : files('integer_ring.pyx'),
  'laurent_series_ring_element' : files('laurent_series_ring_element.pyx'),
  'morphism' : files('morphism.pyx'),
  'noncommutative_ideals' : files('noncommutative_ideals.pyx'),
  'power_series_mpoly' : files('power_series_mpoly.pyx'),
  'power_series_pari' : files('power_series_pari.pyx'),
  'power_series_poly' : files('power_series_poly.pyx'),
  'power_series_ring_element' : files('power_series_ring_element.pyx'),
  'puiseux_series_ring_element' : files('puiseux_series_ring_element.pyx'),
  'real_arb' : files('real_arb.pyx'),
  'real_double' : files('real_double.pyx'),
  'real_double_element_gsl' : files('real_double_element_gsl.pyx'),
  'real_interval_absolute' : files('real_interval_absolute.pyx'),
  'real_lazy' : files('real_lazy.pyx'),
  'real_mpfi' : files('real_mpfi.pyx'),
  'real_mpfr' : files('real_mpfr.pyx'),
  'ring' : files('ring.pyx'),
  'ring_extension' : files('ring_extension.pyx'),
  'ring_extension_conversion' : files('ring_extension_conversion.pyx'),
  'ring_extension_element' : files('ring_extension_element.pyx'),
  'ring_extension_morphism' : files('ring_extension_morphism.pyx'),
  'sum_of_squares' : files('sum_of_squares.pyx'),
  'tate_algebra_element' : files('tate_algebra_element.pyx'),
  'tate_algebra_ideal' : files('tate_algebra_ideal.pyx'),
}

foreach name, pyx : extension_data
  deps = [py_dep, cysignals, gmp]
  if name == 'complex_arb'
    deps += [
      flint,
      mpfi,
      gsl,  # Runtime dependency
    ]
  elif name == 'complex_conversion'
    deps += [gsl, mpfr]
  elif name == 'complex_interval'
    deps += [
      mpfi,
      flint,  # Runtime dependency
    ]
  elif name == 'complex_mpc'
    deps += [gmpy2, mpfr, mpc]
  elif name == 'complex_mpfr'
    deps += [gmpy2, mpfr]
  elif name == 'factorint_flint'
    deps += [flint]
  elif name == 'integer'
    deps += [gmpy2]
  elif name == 'power_series_pari'
    deps += [cypari2]
  elif name == 'real_arb'
    deps += [flint, mpfi]
  elif name == 'real_double'
    deps += [gmpy2]
  elif name == 'real_double_element_gsl'
    deps += [gsl]
  elif name == 'real_mpfi'
    deps += [mpfi]
  elif name == 'real_mpfr'
    deps += [gmpy2, mpfr]
  elif name == 'tate_algebra_element'
    deps += [
      ntl,  # Indirect dependency
    ]
  endif
  py.extension_module(
    name,
    sources: pyx,
    subdir: 'sage/rings',
    install: true,
    include_directories: [
      inc_cpython,
      inc_ext,
      inc_flint,
      inc_gsl,
      inc_ntl,
      inc_rings,
      inc_rings_finite,
    ],
    dependencies: deps,
  )
endforeach

extension_data_cpp = {
  'bernmm': files(
    'bernmm.pyx',
    'bernmm/bern_modp.cpp',
    'bernmm/bern_modp_util.cpp',
    'bernmm/bern_rat.cpp',
  ),
  'bernoulli_mod_p': files('bernoulli_mod_p.pyx'),
  # Has to be compiled as c++ due to https://github.com/cython/cython/issues/6524
  'complex_double' : files('complex_double.pyx'),
  'fraction_field_FpT': files('fraction_field_FpT.pyx'),
  'rational': files('rational.pyx'),
}

foreach name, pyx : extension_data_cpp
  deps = [py_dep, cysignals, gmp]
  if name == 'bernmm'
    deps += [ntl]
  elif name == 'bernoulli_mod_p'
    deps += [ntl]
  elif name == 'complex_double'
    deps += [gmpy2, gsl]
  elif name == 'fraction_field_FpT'
    deps += [flint]
  elif name == 'rational'
    deps += [gmpy2]
  endif

  py.extension_module(
    name,
    sources: pyx,
    subdir: 'sage/rings',
    install: true,
    cpp_args: ['-DUSE_THREADS=1', '-DTHREAD_STACK_SIZE=4096'],
    override_options: ['cython_language=cpp'],
    include_directories: [
      inc_cpython,
      inc_ext,
      inc_flint,
      inc_gsl,
      inc_ntl,
      inc_rings,
      inc_rings_finite,
    ],
    dependencies: deps,
  )
endforeach

install_subdir('asymptotic', install_dir: sage_install_dir / 'rings')
subdir('convert')
subdir('finite_rings')
subdir('function_field')
install_subdir('invariants', install_dir: sage_install_dir / 'rings')
subdir('number_field')
subdir('padics')
subdir('polynomial')
subdir('semirings')
install_subdir('valuation', install_dir: sage_install_dir / 'rings')
