# Cache directory for head-model downloads

Cache directory for head-model downloads

## Usage

``` r
headModelCache()
```

## Value

The per-user cache path (created if needed), from
[`tools::R_user_dir()`](https://rdrr.io/r/tools/userdir.html).

## Examples

``` r
# The cache normally lives under tools::R_user_dir(); redirect it to a
# temporary directory here so the example leaves nothing behind.
old <- Sys.getenv("R_USER_CACHE_DIR", unset = NA)
Sys.setenv(R_USER_CACHE_DIR = tempdir())
headModelCache()
#> [1] "/tmp/RtmpHVJtCA/R/PhysioHeadModels"
if (is.na(old)) Sys.unsetenv("R_USER_CACHE_DIR") else
  Sys.setenv(R_USER_CACHE_DIR = old)
```
