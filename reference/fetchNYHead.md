# Fetch the New York Head model on demand

Downloads the New York Head leadfield (`sa_nyhead.mat`, about 678 MB,
Huang, Parra & Haufe 2016) to the per-user cache the first time it is
needed. The file is a MATLAB v7.3 (HDF5) file and requires the hdf5r
package to read; it is deliberately not shipped with this package.

## Usage

``` r
fetchNYHead(dest = NULL, quiet = FALSE, timeout = 3600)
```

## Arguments

- dest:

  Optional destination path (defaults to the cache).

- quiet:

  Suppress the download progress bar (default: `FALSE`).

- timeout:

  Download timeout in seconds (default: 3600).

## Value

The path to the downloaded `.mat` file.

## References

Huang, Y., Parra, L. C., & Haufe, S. (2016). The New York Head - a
precise standardized volume conductor model for EEG source localization
and tES targeting. NeuroImage, 140, 150-162.

## See also

[`nyHeadLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/nyHeadLeadfield.md),
[`fetchFsaverage()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchFsaverage.md)

## Examples

``` r
if (FALSE) { # \dontrun{
path <- fetchNYHead()
} # }
```
