# PhysioHeadModels: EEG Forward Head Models and Leadfields

Building blocks for the EEG forward problem: analytic concentric-sphere
leadfields, a boundary-element (BEM) solver for custom triangulated
meshes, cortical source-space helpers with surface normals, validation
metrics, and on-demand fetchers for large published head models.
Leadfields use the ecosystem convention
`n_electrodes x (n_sources * 3)`, with the three orientation (x, y, z)
columns contiguous per source.

## Source-space and mesh geometry

- [`icosphere()`](https://x-biosignal.github.io/PhysioHeadModels/reference/icosphere.md) -
  triangulated sphere (subdivided icosahedron) for a scalp/skull/brain
  surface or electrode placement.

- [`sphericalSourceSpace()`](https://x-biosignal.github.io/PhysioHeadModels/reference/sphericalSourceSpace.md) -
  dipole positions and radial normals on a spherical-cortex shell.

## Analytic forward model

- [`sphereLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/sphereLeadfield.md) -
  Legendre-series leadfield for a homogeneous conducting sphere (the
  classic single-sphere analytic solution).

## Boundary-element forward model

- [`bemLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/bemLeadfield.md) -
  double-layer collocation BEM leadfield on one or more nested meshes.

- [`solidAngle()`](https://x-biosignal.github.io/PhysioHeadModels/reference/solidAngle.md) -
  van Oosterom-Strackee solid angle used by the solver.

## Orientation and validation

- [`constrainOrientation()`](https://x-biosignal.github.io/PhysioHeadModels/reference/constrainOrientation.md) -
  collapse a free-orientation leadfield onto source normals.

- [`leadfieldRDM()`](https://x-biosignal.github.io/PhysioHeadModels/reference/leadfieldRDM.md) -
  relative difference measure (topography) and magnitude ratio between
  two leadfields.

## Published head-model assets

These are downloaded to a per-user cache on first use, not shipped with
the package.

- [`fetchNYHead()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchNYHead.md),
  [`nyHeadLeadfield()`](https://x-biosignal.github.io/PhysioHeadModels/reference/nyHeadLeadfield.md) -
  the New York Head precomputed leadfield (requires hdf5r).

- [`fetchFsaverage()`](https://x-biosignal.github.io/PhysioHeadModels/reference/fetchFsaverage.md) -
  FreeSurfer fsaverage template surfaces.

- [`headModelCache()`](https://x-biosignal.github.io/PhysioHeadModels/reference/headModelCache.md) -
  the cache directory used by the fetchers.

## Where to go next

The worked end-to-end workflow (sphere source space to analytic and BEM
leadfields to RDM validation) is in
[`vignette("forward-models", package = "PhysioHeadModels")`](https://x-biosignal.github.io/PhysioHeadModels/articles/forward-models.md).
The leadfields and source spaces produced here feed EEG signal
processing and inverse-analysis workflows in the PhysioEEG package.

## See also

Useful links:

- <https://github.com/x-biosignal/PhysioHeadModels>

- Report bugs at
  <https://github.com/x-biosignal/PhysioHeadModels/issues>

## Author

**Maintainer**: Yusuke Matsui <mail.to.matsui@gmail.com>
