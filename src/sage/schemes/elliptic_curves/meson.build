py.install_sources(
  'BSD.py',
  'Qcurves.py',
  '__init__.py',
  'addition_formulas_ring.py',
  'all.py',
  'cardinality.py',
  'cm.py',
  'constructor.py',
  'ec_database.py',
  'ell_curve_isogeny.py',
  'ell_egros.py',
  'ell_field.py',
  'ell_finite_field.py',
  'ell_generic.py',
  'ell_local_data.py',
  'ell_modular_symbols.py',
  'ell_number_field.py',
  'ell_padic_field.py',
  'ell_point.py',
  'ell_rational_field.py',
  'ell_tate_curve.py',
  'ell_torsion.py',
  'ell_wp.py',
  'formal_group.py',
  'gal_reps.py',
  'gal_reps_number_field.py',
  'gp_simon.py',
  'heegner.py',
  'height.py',
  'hom.py',
  'hom_composite.py',
  'hom_frobenius.py',
  'hom_scalar.py',
  'hom_sum.py',
  'hom_velusqrt.py',
  'homset.py',
  'isogeny_class.py',
  'isogeny_small_degree.py',
  'jacobian.py',
  'kodaira_symbol.py',
  'kraus.py',
  'lseries_ell.py',
  'mod5family.py',
  'mod_poly.py',
  'modular_parametrization.py',
  'padic_lseries.py',
  'padics.py',
  'period_lattice.py',
  'saturation.py',
  'sha_tate.py',
  'weierstrass_morphism.py',
  'weierstrass_transform.py',
  subdir: 'sage/schemes/elliptic_curves',
)

extension_data = {
  'descent_two_isogeny' : files('descent_two_isogeny.pyx'),
  'mod_sym_num' : files('mod_sym_num.pyx'),
  'period_lattice_region' : files('period_lattice_region.pyx'),
}

foreach name, pyx : extension_data
  py.extension_module(
    name,
    sources: pyx,
    subdir: 'sage/schemes/elliptic_curves',
    install: true,
    include_directories: [inc_cpython, inc_flint, inc_rings],
    dependencies: [py_dep, cypari2, cysignals, flint, gmp, mpfr, numpy, pari],
  )
endforeach

