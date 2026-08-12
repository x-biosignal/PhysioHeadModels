# Triangulated sphere (subdivided icosahedron)

Builds a geodesic sphere mesh by recursively subdividing an icosahedron,
giving nearly uniform triangles - a convenient scalp/skull/brain surface
for the BEM solver or for placing electrodes.

## Usage

``` r
icosphere(subdivisions = 2L, radius = 1)
```

## Arguments

- subdivisions:

  Number of subdivision passes (default: 2; 0 gives the 20-face
  icosahedron, each pass multiplies faces by 4).

- radius:

  Sphere radius (default: 1).

## Value

A list with `vertices` (n x 3) and `faces` (m x 3 integer vertex
indices, outward winding).

## Examples

``` r
m <- icosphere(2)
nrow(m$faces)
#> [1] 320
```
