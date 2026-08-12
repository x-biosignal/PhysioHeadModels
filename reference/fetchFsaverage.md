# Fetch the FreeSurfer fsaverage surfaces on demand

A thin placeholder fetcher for the FreeSurfer / MNE `fsaverage` template
surfaces. Because `fsaverage` is distributed through FreeSurfer / MNE
(with its own licence and download mechanism), this returns the cache
directory into which the user should place (or a future version will
fetch) the surfaces, and errors informatively if they are absent.

## Usage

``` r
fetchFsaverage(dest = NULL)
```

## Arguments

- dest:

  Optional destination directory (defaults to the cache).

## Value

The path to the fsaverage directory in the cache.

## See also

[`fetchNYHead()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchNYHead.md)
