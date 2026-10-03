# On-demand fetchers for large published head models. The datasets (hundreds of
# MB) are NOT shipped in the package; they are downloaded to a per-user cache on
# first use, following the idiom used by MNE/FieldTrip.

NYHEAD_URL <- "https://www.parralab.org/nyhead/sa_nyhead.mat"

#' Cache directory for head-model downloads
#'
#' @return The per-user cache path (created if needed), from
#'   [tools::R_user_dir()].
#' @export
#' @examples
#' # The cache normally lives under tools::R_user_dir(); redirect it to a
#' # temporary directory here so the example leaves nothing behind.
#' old <- Sys.getenv("R_USER_CACHE_DIR", unset = NA)
#' Sys.setenv(R_USER_CACHE_DIR = tempdir())
#' headModelCache()
#' if (is.na(old)) Sys.unsetenv("R_USER_CACHE_DIR") else
#'   Sys.setenv(R_USER_CACHE_DIR = old)
headModelCache <- function() {
  d <- tools::R_user_dir("PhysioHeadModels", "cache")
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
  d
}

#' Fetch the New York Head model on demand
#'
#' Downloads the New York Head leadfield (\code{sa_nyhead.mat}, about 678 MB,
#' Huang, Parra & Haufe 2016) to the per-user cache the first time it is needed.
#' The file is a MATLAB v7.3 (HDF5) file and requires the \pkg{hdf5r} package to
#' read; it is deliberately not shipped with this package.
#'
#' @param dest Optional destination path (defaults to the cache).
#' @param quiet Suppress the download progress bar (default: \code{FALSE}).
#' @param timeout Download timeout in seconds (default: 3600).
#' @return The path to the downloaded \code{.mat} file.
#' @references
#' Huang, Y., Parra, L. C., & Haufe, S. (2016). The New York Head - a precise
#' standardized volume conductor model for EEG source localization and tES
#' targeting. NeuroImage, 140, 150-162.
#' @seealso [nyHeadLeadfield()], [fetchFsaverage()]
#' @export
#' @examples
#' \dontrun{
#' path <- fetchNYHead()
#' }
fetchNYHead <- function(dest = NULL, quiet = FALSE, timeout = 3600) {
  if (is.null(dest)) dest <- file.path(headModelCache(), "sa_nyhead.mat")
  if (file.exists(dest) && file.info(dest)$size > 1e8) return(dest)
  old <- options(timeout = timeout); on.exit(options(old), add = TRUE)
  utils::download.file(NYHEAD_URL, dest, mode = "wb", quiet = quiet)
  dest
}

#' Fetch the FreeSurfer fsaverage surfaces on demand
#'
#' A thin placeholder fetcher for the FreeSurfer / MNE \code{fsaverage} template
#' surfaces. Because \code{fsaverage} is distributed through FreeSurfer / MNE
#' (with its own licence and download mechanism), this returns the cache
#' directory into which the user should place (or a future version will fetch)
#' the surfaces, and errors informatively if they are absent.
#'
#' @param dest Optional destination directory (defaults to the cache).
#' @return The path to the fsaverage directory in the cache.
#' @seealso [fetchNYHead()]
#' @export
#' @examples
#' # With the surfaces already in place the fetcher just resolves their path.
#' # Here a temporary stand-in directory shows that resolution offline (a real
#' # run needs the FreeSurfer/MNE fsaverage surfaces placed in the directory).
#' dir <- file.path(tempdir(), "fsaverage")
#' dir.create(dir, showWarnings = FALSE)
#' fetchFsaverage(dest = dir)
fetchFsaverage <- function(dest = NULL) {
  if (is.null(dest)) dest <- file.path(headModelCache(), "fsaverage")
  if (!dir.exists(dest)) {
    stop("fsaverage surfaces are not present in the cache (", dest, "). ",
         "Obtain them via FreeSurfer or MNE (mne.datasets.fetch_fsaverage) and ",
         "place them there.", call. = FALSE)
  }
  dest
}

#' Load a New York Head leadfield for a montage
#'
#' Reads the New York Head leadfield (fetched by [fetchNYHead()]) and extracts
#' the sub-leadfield for a set of electrode labels, in the
#' n_electrodes x (n_sources * 3) convention used across the ecosystem. Requires
#' the \pkg{hdf5r} package and the downloaded \code{.mat}; both are optional, so
#' this errors informatively when either is missing.
#'
#' @param montage_labels Character vector of electrode labels to extract.
#' @param path Path to \code{sa_nyhead.mat} (defaults to the cached download).
#' @param normal_only Return the surface-normal-constrained leadfield
#'   (n_electrodes x n_sources) instead of the free-orientation one
#'   (default: \code{FALSE}).
#' @return A list with \code{leadfield}, \code{source_positions},
#'   \code{source_normals}, \code{electrode_labels}, and \code{electrode_index}.
#' @seealso [fetchNYHead()]
#' @export
#' @examples
#' \dontrun{
#' lf <- nyHeadLeadfield(c("C3", "C4", "Cz"))
#' dim(lf$leadfield)
#' }
nyHeadLeadfield <- function(montage_labels, path = NULL, normal_only = FALSE) {
  if (!requireNamespace("hdf5r", quietly = TRUE)) {
    stop("Package 'hdf5r' is required to read the New York Head .mat file.",
         call. = FALSE)
  }
  if (is.null(path)) path <- file.path(headModelCache(), "sa_nyhead.mat")
  if (!file.exists(path)) {
    stop("New York Head file not found at ", path,
         ". Run fetchNYHead() first.", call. = FALSE)
  }
  f <- hdf5r::H5File$new(path, mode = "r")
  on.exit(f$close_all(), add = TRUE)
  clab <- as.character(f[["sa/clab_electrodes"]][])
  idx <- match(montage_labels, clab)
  if (anyNA(idx)) {
    stop("labels not in the New York Head montage: ",
         paste(montage_labels[is.na(idx)], collapse = ", "), call. = FALSE)
  }
  field <- if (normal_only) "sa/cortex75K/V_fem_normal" else "sa/cortex75K/V_fem"
  vfem <- f[[field]]
  # V_fem dims: n_electrodes x n_sources x 3 (orientation); subset electrodes.
  lf_sub <- vfem[idx, , , drop = FALSE]
  pos <- t(f[["sa/cortex75K/vc"]][, ])
  nrm <- t(f[["sa/cortex75K/normals"]][, ])
  leadfield <- if (normal_only) {
    matrix(lf_sub, nrow = length(idx))
  } else {
    ns <- dim(lf_sub)[2]
    L <- matrix(0, length(idx), ns * 3)
    for (a in 1:3) L[, seq(a, ns * 3, by = 3)] <- lf_sub[, , a]
    L
  }
  list(leadfield = leadfield, source_positions = pos, source_normals = nrm,
       electrode_labels = montage_labels, electrode_index = idx)
}
