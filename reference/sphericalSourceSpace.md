# Spherical cortical source space

Places dipole sources on a sphere (a spherical-cortex approximation),
returning vertex positions and outward surface normals - the structured
source space a realistic forward model uses in place of a random source
cloud.

## Usage

``` r
sphericalSourceSpace(n_sources = 400L, radius = 0.7)
```

## Arguments

- n_sources:

  Approximate number of sources (default: 400).

- radius:

  Source-shell radius (default: 0.7).

## Value

A list with `positions` (n x 3) and `normals` (n x 3, unit radial).

## Examples

``` r
ss <- sphericalSourceSpace(200)
nrow(ss$positions)
#> [1] 200
```
