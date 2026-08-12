# Relative difference measure and magnitude ratio between two leadfields

Standard BEM validation metrics on average-referenced potentials: RDM
(topography error, 0 = identical) and MAG (amplitude ratio, 1 =
identical).

## Usage

``` r
leadfieldRDM(test, reference)
```

## Arguments

- test, reference:

  Leadfield matrices of the same shape.

## Value

A named numeric vector `c(RDM, MAG)` (means over columns).
