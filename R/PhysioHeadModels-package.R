#' PhysioHeadModels: EEG Forward Head Models and Leadfields
#'
#' Building blocks for the EEG forward problem: analytic concentric-sphere
#' leadfields, a boundary-element (BEM) solver for custom triangulated meshes,
#' cortical source-space helpers with surface normals, validation metrics, and
#' on-demand fetchers for large published head models. Leadfields use the
#' ecosystem convention `n_electrodes x (n_sources * 3)`, with the three
#' orientation (x, y, z) columns contiguous per source.
#'
#' @section Source-space and mesh geometry:
#' \itemize{
#'   \item [icosphere()] - triangulated sphere (subdivided icosahedron) for a
#'     scalp/skull/brain surface or electrode placement.
#'   \item [sphericalSourceSpace()] - dipole positions and radial normals on a
#'     spherical-cortex shell.
#' }
#'
#' @section Analytic forward model:
#' \itemize{
#'   \item [sphereLeadfield()] - Legendre-series leadfield for a homogeneous
#'     conducting sphere (the classic single-sphere analytic solution).
#' }
#'
#' @section Boundary-element forward model:
#' \itemize{
#'   \item [bemLeadfield()] - double-layer collocation BEM leadfield on one or
#'     more nested meshes.
#'   \item [solidAngle()] - van Oosterom-Strackee solid angle used by the solver.
#' }
#'
#' @section Orientation and validation:
#' \itemize{
#'   \item [constrainOrientation()] - collapse a free-orientation leadfield onto
#'     source normals.
#'   \item [leadfieldRDM()] - relative difference measure (topography) and
#'     magnitude ratio between two leadfields.
#' }
#'
#' @section Published head-model assets:
#' These are downloaded to a per-user cache on first use, not shipped with the
#' package.
#' \itemize{
#'   \item [fetchNYHead()], [nyHeadLeadfield()] - the New York Head precomputed
#'     leadfield (requires \pkg{hdf5r}).
#'   \item [fetchFsaverage()] - FreeSurfer fsaverage template surfaces.
#'   \item [headModelCache()] - the cache directory used by the fetchers.
#' }
#'
#' @section Where to go next:
#' The worked end-to-end workflow (sphere source space to analytic and BEM
#' leadfields to RDM validation) is in `vignette("forward-models",
#' package = "PhysioHeadModels")`. The leadfields and source spaces produced
#' here feed EEG signal processing and inverse-analysis workflows in the
#' \pkg{PhysioEEG} package.
#'
#' @keywords internal
"_PACKAGE"
