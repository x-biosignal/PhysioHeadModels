# Load a New York Head leadfield for a montage

Reads the New York Head leadfield (fetched by
[`fetchNYHead()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchNYHead.md))
and extracts the sub-leadfield for a set of electrode labels, in the
n_electrodes x (n_sources \* 3) convention used across the ecosystem.
Requires the hdf5r package and the downloaded `.mat`; both are optional,
so this errors informatively when either is missing.

## Usage

``` r
nyHeadLeadfield(montage_labels, path = NULL, normal_only = FALSE)
```

## Arguments

- montage_labels:

  Character vector of electrode labels to extract.

- path:

  Path to `sa_nyhead.mat` (defaults to the cached download).

- normal_only:

  Return the surface-normal-constrained leadfield (n_electrodes x
  n_sources) instead of the free-orientation one (default: `FALSE`).

## Value

A list with `leadfield`, `source_positions`, `source_normals`,
`electrode_labels`, and `electrode_index`.

## See also

[`fetchNYHead()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchNYHead.md)

## Examples

``` r
if (FALSE) { # \dontrun{
lf <- nyHeadLeadfield(c("C3", "C4", "Cz"))
dim(lf$leadfield)
} # }
```
