# EEG forward models: from a source space to a validated leadfield

`PhysioHeadModels` builds the EEG *forward* operator - the leadfield
that maps cortical dipole sources to scalp potentials. This vignette
walks the whole task end to end using only the analytic and
boundary-element solvers, so everything below runs offline with no
downloads.

Every leadfield here follows the ecosystem convention: an
`n_electrodes x (n_sources * 3)` matrix, with the three orientation (x,
y, z) columns stored contiguously per source.

``` r

library(PhysioHeadModels)
```

## 1. A head surface and an electrode montage

A subdivided icosahedron gives a nearly uniform triangulated sphere. We
use it both as the conducting surface for the boundary-element solver
and as a place to put electrodes (here, a handful of its vertices).

``` r

mesh <- icosphere(subdivisions = 2)      # 320 triangles, 162 vertices
c(vertices = nrow(mesh$vertices), faces = nrow(mesh$faces))
#> vertices    faces 
#>      162      320

electrodes <- mesh$vertices[1:19, ]      # 19 scalp electrodes on the unit sphere
```

## 2. A cortical source space

[`sphericalSourceSpace()`](https://x-biosignal.github.io/PhysioHeadModels/reference/sphericalSourceSpace.md)
lays sources out on an inner shell and returns the outward radial normal
at each one - the orientation a surface-constrained forward model
assumes.

``` r

ss <- sphericalSourceSpace(n_sources = 60, radius = 0.6)
dim(ss$positions)
#> [1] 60  3
dim(ss$normals)
#> [1] 60  3
```

## 3. The analytic single-sphere leadfield

For a homogeneous sphere there is a closed-form (Legendre-series)
solution. It is fast and exact for this geometry, so it doubles as a
reference when checking numerical solvers.

``` r

lf <- sphereLeadfield(electrodes, ss$positions)
dim(lf)                                   # 19 electrodes x (60 sources * 3)
#> [1]  19 180
```

If each source’s orientation is fixed to its surface normal, collapse
the three orientation columns into one with
[`constrainOrientation()`](https://x-biosignal.github.io/PhysioHeadModels/reference/constrainOrientation.md):

``` r

lf_fixed <- constrainOrientation(lf, ss$normals)
dim(lf_fixed)                             # 19 electrodes x 60 sources
#> [1] 19 60
```

## 4. A boundary-element leadfield, and validating it

[`bemLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/bemLeadfield.md)
solves the same problem numerically with a double-layer collocation BEM,
which is what you would use for a *realistic* (non-spherical) head. On a
sphere mesh we can score it against the analytic answer with
[`leadfieldRDM()`](https://x-biosignal.github.io/PhysioHeadModels/reference/leadfieldRDM.md):
the relative difference measure (RDM) captures topography error (0 =
identical), while the magnitude ratio (MAG) captures amplitude.

``` r

few_sources <- rbind(c(0, 0, 0.5), c(0.3, 0, 0.2), c(0, 0.35, 0.1))

bem <- bemLeadfield(mesh, conductivities = c(0.33, 0), electrodes, few_sources)
ana <- sphereLeadfield(electrodes, few_sources)

leadfieldRDM(bem, ana)
#>       RDM       MAG 
#> 0.2172864 0.4273529
```

The topography (RDM) is already close and *improves as the mesh is
refined*, while the amplitude (MAG) carries the well-known
coarse-collocation bias:

``` r

rdm_at <- function(sub) {
  m <- icosphere(sub)
  e <- m$vertices
  leadfieldRDM(bemLeadfield(m, c(0.33, 0), e, few_sources),
               sphereLeadfield(e, few_sources))
}
rbind(`icosphere(1)` = rdm_at(1),
      `icosphere(2)` = rdm_at(2))
#>                    RDM       MAG
#> icosphere(1) 0.4335262 0.4546159
#> icosphere(2) 0.2178245 0.4244965
```

Because source localization is invariant to a global leadfield scale,
RDM is the metric to trust for validation; the absolute amplitude bias
does not affect the inverse solution.

## Where to go next

- Published, precomputed head models (the New York Head, FreeSurfer
  fsaverage) are fetched on demand with
  [`fetchNYHead()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchNYHead.md)
  /
  [`nyHeadLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/nyHeadLeadfield.md)
  and
  [`fetchFsaverage()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchFsaverage.md);
  they are downloaded to
  [`headModelCache()`](https://x-biosignal.github.io/PhysioHeadModels/reference/headModelCache.md)
  rather than shipped, and the New York Head reader needs the **hdf5r**
  package.
- The leadfields and source spaces produced here feed EEG signal
  processing and inverse-analysis workflows in the **PhysioEEG**
  package.

Forward-model geometry, coordinate frames, conductivity assumptions, and
the reference convention should always be checked against the needs of
each study.
