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

## Examples

``` r
e <- icosphere(2)$vertices[1:19, ]
s <- rbind(c(0, 0, 0.5), c(0.3, 0, 0.2))
lf <- sphereLeadfield(e, s)
# A leadfield compared with itself is identical: RDM 0, MAG 1.
leadfieldRDM(lf, lf)
#> RDM MAG 
#>   0   1 
```
