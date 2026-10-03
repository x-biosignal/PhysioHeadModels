# PhysioHeadModels

[![r-universe](https://x-biosignal.r-universe.dev/badges/PhysioHeadModels)](https://x-biosignal.r-universe.dev/PhysioHeadModels)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

`PhysioHeadModels` provides EEG forward-model building blocks: analytic sphere
leadfields, boundary-element leadfields for custom meshes, source-space and
orientation helpers, and on-demand access to published head-model assets.

## Installation

```r
# the containers build on Bioconductor, so its repositories are needed too
install.packages("BiocManager", repos = "https://cloud.r-project.org")
options(repos = c(
  xbiosignal = "https://x-biosignal.r-universe.dev",
  BiocManager::repositories()
))
install.packages("PhysioHeadModels")
```

## Quick start

```r
library(PhysioHeadModels)

electrodes <- icosphere(2)$vertices[1:19, ]
sources <- sphericalSourceSpace(n_sources = 40, radius = 0.6)

leadfield <- sphereLeadfield(electrodes, sources$positions)
normal_leadfield <- constrainOrientation(leadfield, sources$normals)

dim(leadfield)
dim(normal_leadfield)
```

## Main functions

| Area | Functions |
|---|---|
| Mesh and source space | `icosphere()`, `sphericalSourceSpace()` |
| Analytic model | `sphereLeadfield()` |
| Boundary-element model | `bemLeadfield()`, `solidAngle()` |
| Orientation and comparison | `constrainOrientation()`, `leadfieldRDM()` |
| Published assets | `fetchNYHead()`, `nyHeadLeadfield()`, `fetchFsaverage()`, `headModelCache()` |

Large published assets are downloaded to a user cache and are not bundled with
the package. `hdf5r` is required for New York Head data. Forward-model geometry,
coordinates, conductivity assumptions, and reference convention must be
checked for each study.

## Ecosystem role

The package produces leadfields and source spaces for EEG forward and source
analysis. Signal processing and inverse-analysis workflows are handled by
`PhysioEEG` and related ecosystem packages.

## Documentation

- [Function reference](https://x-biosignal.r-universe.dev/PhysioHeadModels)
- [Source repository](https://github.com/x-biosignal/PhysioHeadModels)
- [Issue tracker](https://github.com/x-biosignal/PhysioHeadModels/issues)

## Citation

```r
citation("PhysioHeadModels")
```

See the ecosystem [governance](https://github.com/x-biosignal/PhysioExperiment/blob/main/GOVERNANCE.md),
[support policy](https://github.com/x-biosignal/PhysioExperiment/blob/main/SUPPORT.md),
and [contribution guide](https://github.com/x-biosignal/PhysioExperiment/blob/main/CONTRIBUTING.md).

## Author and license

Author and maintainer: **Yusuke Matsui**. Licensed under the [MIT License](LICENSE).
