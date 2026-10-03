# Constrain a free-orientation leadfield to surface normals

Collapses the three orientation columns of each source to a single
surface-normal-oriented column, giving an n_electrodes x n_sources
leadfield.

## Usage

``` r
constrainOrientation(leadfield, normals)
```

## Arguments

- leadfield:

  An n_electrodes x (n_sources \* 3) free-orientation leadfield.

- normals:

  An n_sources x 3 matrix of unit source normals.

## Value

An n_electrodes x n_sources orientation-constrained leadfield.

## Examples

``` r
ss <- sphericalSourceSpace(40, radius = 0.6)
e <- icosphere(2)$vertices[1:19, ]
lf <- sphereLeadfield(e, ss$positions)
lc <- constrainOrientation(lf, ss$normals)
dim(lc)
#> [1] 19 40
```
