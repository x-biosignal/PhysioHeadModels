# Boundary element method (BEM) EEG leadfield

Solves the piecewise-homogeneous EEG forward problem with the classic
collocation double-layer boundary element method (Geselowitz boundary
integral, van Oosterom-Strackee solid angles, average-reference
deflation) on one or more nested triangulated surfaces. Validated
against the analytic single-sphere solution: on a sphere mesh the
leadfield topography matches to a small relative difference measure
(RDM); absolute amplitude carries the usual coarse-collocation bias, so
use RDM (topography) for validation and note that source localization is
invariant to a global leadfield scale.

## Usage

``` r
bemLeadfield(surfaces, conductivities, electrodes, sources)
```

## Arguments

- surfaces:

  A single mesh (list with `vertices`, `faces`) or a list of nested
  meshes from innermost to outermost.

- conductivities:

  Conductivity of each region from innermost to the exterior; length
  `n_surfaces + 1` (the last is the exterior, usually 0 for air). For a
  single surface, a length-2 vector `c(sigma_in, sigma_out)`.

- electrodes:

  An n_electrodes x 3 matrix of electrode positions.

- sources:

  An n_sources x 3 matrix of dipole positions (in the innermost region).

## Value

An n_electrodes x (n_sources \* 3) leadfield matrix.

## References

Geselowitz, D. B. (1967). On bioelectric potentials in an inhomogeneous
volume conductor. Biophysical Journal, 7(1), 1-11.

Oostendorp, T. F., & van Oosterom, A. (1989). Source parameter
estimation in inhomogeneous volume conductors of arbitrary shape. IEEE
Transactions on Biomedical Engineering, 36(3), 382-391.

## See also

[`sphereLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/sphereLeadfield.md),
[`solidAngle()`](https://x-biosignal.github.io/PhysioHeadModels/reference/solidAngle.md)

## Examples

``` r
m <- icosphere(2)
e <- m$vertices[1:19, ]
s <- rbind(c(0, 0, 0.5), c(0.3, 0, 0.2))
dim(bemLeadfield(m, c(0.33, 0), e, s))
#> [1] 19  6
```
