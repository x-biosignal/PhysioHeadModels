# Analytic single-sphere EEG leadfield

Computes the leadfield for a homogeneous conducting sphere with an
insulating outer boundary, using the Legendre-series solution (the
classic analytic forward model, e.g. FieldTrip's single sphere). Each
source contributes three contiguous columns (x, y, z unit dipoles).

## Usage

``` r
sphereLeadfield(electrodes, sources, radius = 1, sigma = 0.33, n_terms = 60L)
```

## Arguments

- electrodes:

  An n_electrodes x 3 matrix of electrode positions (on the sphere of
  radius `radius`).

- sources:

  An n_sources x 3 matrix of dipole positions (inside the sphere).

- radius:

  Sphere radius (default: 1).

- sigma:

  Conductivity in S/m (default: 0.33).

- n_terms:

  Legendre series truncation (default: 60).

## Value

An n_electrodes x (n_sources \* 3) leadfield matrix.

## Examples

``` r
e <- icosphere(2)$vertices[1:19, ]
s <- rbind(c(0, 0, 0.5), c(0.4, 0, 0.2))
dim(sphereLeadfield(e, s))
#> [1] 19  6
```
