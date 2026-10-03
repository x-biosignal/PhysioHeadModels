# Solid angle subtended by a triangle at a point (van Oosterom-Strackee)

Solid angle subtended by a triangle at a point (van Oosterom-Strackee)

## Usage

``` r
solidAngle(v1, v2, v3, r)
```

## Arguments

- v1, v2, v3:

  Numeric length-3 triangle vertices.

- r:

  Numeric length-3 observation point.

## Value

The signed solid angle in steradians.

## Examples

``` r
# One face of the unit octahedron, seen from the centre, spans an eighth
# of the full sphere: pi / 2 steradians.
solidAngle(c(1, 0, 0), c(0, 1, 0), c(0, 0, 1), c(0, 0, 0))
#> [1] 1.570796
```
