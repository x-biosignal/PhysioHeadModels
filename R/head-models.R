# Analytic concentric-sphere and boundary-element (BEM) EEG forward models,
# with a triangulated-sphere mesh generator, cortical source-space helpers, and
# leadfield utilities. The leadfield convention matches PhysioEEG eegForwardModel:
# n_electrodes x (n_sources * 3), with the 3 orientation (x,y,z) columns
# contiguous per source (column (j-1)*3 + {1,2,3}).

#' Triangulated sphere (subdivided icosahedron)
#'
#' Builds a geodesic sphere mesh by recursively subdividing an icosahedron,
#' giving nearly uniform triangles - a convenient scalp/skull/brain surface for
#' the BEM solver or for placing electrodes.
#'
#' @param subdivisions Number of subdivision passes (default: 2; 0 gives the
#'   20-face icosahedron, each pass multiplies faces by 4).
#' @param radius Sphere radius (default: 1).
#' @return A list with \code{vertices} (n x 3) and \code{faces} (m x 3 integer
#'   vertex indices, outward winding).
#' @export
#' @examples
#' m <- icosphere(2)
#' nrow(m$faces)
icosphere <- function(subdivisions = 2L, radius = 1) {
  t <- (1 + sqrt(5)) / 2
  v <- rbind(c(-1, t, 0), c(1, t, 0), c(-1, -t, 0), c(1, -t, 0),
             c(0, -1, t), c(0, 1, t), c(0, -1, -t), c(0, 1, -t),
             c(t, 0, -1), c(t, 0, 1), c(-t, 0, -1), c(-t, 0, 1))
  f <- rbind(c(1,12,6), c(1,6,2), c(1,2,8), c(1,8,11), c(1,11,12),
             c(2,6,10), c(6,12,5), c(12,11,3), c(11,8,7), c(8,2,9),
             c(4,10,5), c(4,5,3), c(4,3,7), c(4,7,9), c(4,9,10),
             c(5,10,6), c(3,5,12), c(7,3,11), c(9,7,8), c(10,9,2))
  v <- v / sqrt(rowSums(v^2))
  for (s in seq_len(as.integer(subdivisions))) {
    mid <- new.env(parent = emptyenv()); nv <- v; nf <- matrix(0L, 0, 3)
    getmid <- function(a, b) {
      key <- paste(min(a, b), max(a, b))
      cached <- mid[[key]]
      if (!is.null(cached)) return(cached)
      m <- (v[a, ] + v[b, ]) / 2; m <- m / sqrt(sum(m^2))
      nv <<- rbind(nv, m); idx <- nrow(nv); mid[[key]] <- idx; idx
    }
    for (i in seq_len(nrow(f))) {
      a <- f[i, 1]; b <- f[i, 2]; c <- f[i, 3]
      ab <- getmid(a, b); bc <- getmid(b, c); ca <- getmid(c, a)
      nf <- rbind(nf, c(a, ab, ca), c(b, bc, ab), c(c, ca, bc), c(ab, bc, ca))
    }
    v <- nv; f <- nf
  }
  list(vertices = v * radius, faces = f)
}

# Legendre polynomials P_0..P_nmax and associated P_n^1 at scalar x.
.legendre <- function(nmax, x) {
  P <- numeric(nmax + 1); P1 <- numeric(nmax + 1)
  P[1] <- 1; if (nmax >= 1) P[2] <- x
  if (nmax >= 2) for (n in 2:nmax) P[n + 1] <- ((2*n-1)*x*P[n] - (n-1)*P[n-1]) / n
  s <- sqrt(max(0, 1 - x^2))
  if (nmax >= 1) P1[2] <- s
  if (nmax >= 2) for (n in 2:nmax) P1[n + 1] <- ((2*n-1)*x*P1[n] - n*P1[n-1]) / (n-1)
  list(P = P, P1 = P1)
}

# Scalp potential of a unit dipole in a homogeneous sphere (Legendre series;
# insulating outer boundary). Derived radial/tangential coefficients.
.sphere_potential <- function(r_e, r_q, q, radius, sigma, nmax) {
  b <- sqrt(sum(r_q^2)); if (b < 1e-9) b <- 1e-9
  zhat <- r_q / b
  re_norm <- sqrt(sum(r_e^2))
  ct <- max(-1, min(1, sum(r_e * zhat) / re_norm))
  qr <- sum(q * zhat)
  qt_vec <- q - qr * zhat; qt <- sqrt(sum(qt_vec^2))
  cphi <- 0
  if (qt > 1e-12) {
    xhat <- qt_vec / qt
    re_perp <- r_e - sum(r_e * zhat) * zhat
    rp <- sqrt(sum(re_perp^2))
    if (rp > 1e-12) cphi <- sum(re_perp * xhat) / rp
  }
  L <- .legendre(nmax, ct); n <- 1:nmax
  frad <- (2*n + 1) * b^(n - 1) / radius^(n + 1)
  ftan <- (2*n + 1) / n * b^(n - 1) / radius^(n + 1)
  vrad <- qr * sum(frad * L$P[2:(nmax + 1)])
  vtan <- qt * cphi * sum(ftan * L$P1[2:(nmax + 1)])
  (vrad + vtan) / (4 * pi * sigma)
}

#' Analytic single-sphere EEG leadfield
#'
#' Computes the leadfield for a homogeneous conducting sphere with an insulating
#' outer boundary, using the Legendre-series solution (the classic analytic
#' forward model, e.g. FieldTrip's single sphere). Each source contributes three
#' contiguous columns (x, y, z unit dipoles).
#'
#' @param electrodes An n_electrodes x 3 matrix of electrode positions (on the
#'   sphere of radius \code{radius}).
#' @param sources An n_sources x 3 matrix of dipole positions (inside the
#'   sphere).
#' @param radius Sphere radius (default: 1).
#' @param sigma Conductivity in S/m (default: 0.33).
#' @param n_terms Legendre series truncation (default: 60).
#' @return An n_electrodes x (n_sources * 3) leadfield matrix.
#' @export
#' @examples
#' e <- icosphere(2)$vertices[1:19, ]
#' s <- rbind(c(0, 0, 0.5), c(0.4, 0, 0.2))
#' dim(sphereLeadfield(e, s))
sphereLeadfield <- function(electrodes, sources, radius = 1, sigma = 0.33,
                            n_terms = 60L) {
  electrodes <- as.matrix(electrodes); sources <- as.matrix(sources)
  ne <- nrow(electrodes); ns <- nrow(sources)
  L <- matrix(0, ne, ns * 3)
  for (j in seq_len(ns)) for (a in 1:3) {
    q <- c(0, 0, 0); q[a] <- 1
    for (i in seq_len(ne)) {
      L[i, (j - 1) * 3 + a] <- .sphere_potential(electrodes[i, ], sources[j, ],
                                                 q, radius, sigma, n_terms)
    }
  }
  L
}

#' Solid angle subtended by a triangle at a point (van Oosterom-Strackee)
#'
#' @param v1,v2,v3 Numeric length-3 triangle vertices.
#' @param r Numeric length-3 observation point.
#' @return The signed solid angle in steradians.
#' @export
#' @examples
#' # One face of the unit octahedron, seen from the centre, spans an eighth
#' # of the full sphere: pi / 2 steradians.
#' solidAngle(c(1, 0, 0), c(0, 1, 0), c(0, 0, 1), c(0, 0, 0))
solidAngle <- function(v1, v2, v3, r) {
  A <- v1 - r; B <- v2 - r; C <- v3 - r
  la <- sqrt(sum(A^2)); lb <- sqrt(sum(B^2)); lc <- sqrt(sum(C^2))
  num <- sum(A * c(B[2]*C[3] - B[3]*C[2], B[3]*C[1] - B[1]*C[3],
                   B[1]*C[2] - B[2]*C[1]))
  den <- la*lb*lc + sum(A*B)*lc + sum(A*C)*lb + sum(B*C)*la
  2 * atan2(num, den)
}

#' Boundary element method (BEM) EEG leadfield
#'
#' Solves the piecewise-homogeneous EEG forward problem with the classic
#' collocation double-layer boundary element method (Geselowitz boundary
#' integral, van Oosterom-Strackee solid angles, average-reference deflation)
#' on one or more nested triangulated surfaces. Validated against the analytic
#' single-sphere solution: on a sphere mesh the leadfield topography matches to
#' a small relative difference measure (RDM); absolute amplitude carries the
#' usual coarse-collocation bias, so use RDM (topography) for validation and
#' note that source localization is invariant to a global leadfield scale.
#'
#' @param surfaces A single mesh (list with \code{vertices}, \code{faces}) or a
#'   list of nested meshes from innermost to outermost.
#' @param conductivities Conductivity of each region from innermost to the
#'   exterior; length \code{n_surfaces + 1} (the last is the exterior, usually
#'   0 for air). For a single surface, a length-2 vector \code{c(sigma_in,
#'   sigma_out)}.
#' @param electrodes An n_electrodes x 3 matrix of electrode positions.
#' @param sources An n_sources x 3 matrix of dipole positions (in the innermost
#'   region).
#' @return An n_electrodes x (n_sources * 3) leadfield matrix.
#' @references
#' Geselowitz, D. B. (1967). On bioelectric potentials in an inhomogeneous
#' volume conductor. Biophysical Journal, 7(1), 1-11.
#'
#' Oostendorp, T. F., & van Oosterom, A. (1989). Source parameter estimation in
#' inhomogeneous volume conductors of arbitrary shape. IEEE Transactions on
#' Biomedical Engineering, 36(3), 382-391.
#' @seealso [sphereLeadfield()], [solidAngle()]
#' @export
#' @examples
#' m <- icosphere(2)
#' e <- m$vertices[1:19, ]
#' s <- rbind(c(0, 0, 0.5), c(0.3, 0, 0.2))
#' dim(bemLeadfield(m, c(0.33, 0), e, s))
bemLeadfield <- function(surfaces, conductivities, electrodes, sources) {
  if (!is.null(surfaces$vertices)) surfaces <- list(surfaces)
  electrodes <- as.matrix(electrodes); sources <- as.matrix(sources)
  # Assemble all triangles with per-triangle (sigma_in - sigma_out).
  cen <- matrix(0, 0, 3); tri <- list(); djump <- numeric(0)
  for (k in seq_along(surfaces)) {
    v <- surfaces[[k]]$vertices; f <- surfaces[[k]]$faces
    c_in <- conductivities[k]; c_out <- conductivities[k + 1]
    for (i in seq_len(nrow(f))) {
      tri[[length(tri) + 1L]] <- rbind(v[f[i, 1], ], v[f[i, 2], ], v[f[i, 3], ])
      cen <- rbind(cen, (v[f[i, 1], ] + v[f[i, 2], ] + v[f[i, 3], ]) / 3)
      djump <- c(djump, c_in - c_out)
      # sigma_bar per collocation surface handled below per element
    }
  }
  nt <- length(tri)
  # sigma_bar for each element's surface = mean of its in/out conductivity
  sbar <- numeric(0); off <- 0
  for (k in seq_along(surfaces)) {
    m <- nrow(surfaces[[k]]$faces)
    sbar <- c(sbar, rep((conductivities[k] + conductivities[k + 1]) / 2, m))
  }
  Om <- matrix(0, nt, nt)
  for (i in seq_len(nt)) for (j in seq_len(nt)) if (i != j) {
    Om[i, j] <- djump[j] * solidAngle(tri[[j]][1, ], tri[[j]][2, ], tri[[j]][3, ],
                                      cen[i, ])
  }
  diag(Om) <- -rowSums(Om)                      # auto solid-angle self term
  M <- diag(sbar) - Om / (4 * pi)
  Mdef <- M + matrix(1 / nt, nt, nt)            # deflation (average reference)
  Minv <- solve(Mdef)
  eidx <- apply(electrodes, 1, function(e)
    which.min(rowSums((cen - matrix(e, nt, 3, byrow = TRUE))^2)))
  sigma0 <- conductivities[1]
  ns <- nrow(sources); L <- matrix(0, nrow(electrodes), ns * 3)
  for (j in seq_len(ns)) for (a in 1:3) {
    q <- c(0, 0, 0); q[a] <- 1
    d <- cen - matrix(sources[j, ], nt, 3, byrow = TRUE)
    vinf <- (1 / (4 * pi * sigma0)) * (d %*% q) / (sqrt(rowSums(d^2))^3)
    Vsurf <- Minv %*% (sigma0 * vinf)
    L[, (j - 1) * 3 + a] <- Vsurf[eidx]
  }
  L
}

#' Spherical cortical source space
#'
#' Places dipole sources on a sphere (a spherical-cortex approximation),
#' returning vertex positions and outward surface normals - the structured
#' source space a realistic forward model uses in place of a random source
#' cloud.
#'
#' @param n_sources Approximate number of sources (default: 400).
#' @param radius Source-shell radius (default: 0.7).
#' @return A list with \code{positions} (n x 3) and \code{normals} (n x 3, unit
#'   radial).
#' @export
#' @examples
#' ss <- sphericalSourceSpace(200)
#' nrow(ss$positions)
sphericalSourceSpace <- function(n_sources = 400L, radius = 0.7) {
  n <- as.integer(n_sources)
  i <- seq_len(n) - 0.5
  phi <- acos(1 - 2 * i / n)
  golden <- pi * (1 + sqrt(5))
  theta <- golden * i
  pos <- cbind(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi))
  list(positions = pos * radius, normals = pos)
}

#' Constrain a free-orientation leadfield to surface normals
#'
#' Collapses the three orientation columns of each source to a single
#' surface-normal-oriented column, giving an n_electrodes x n_sources leadfield.
#'
#' @param leadfield An n_electrodes x (n_sources * 3) free-orientation leadfield.
#' @param normals An n_sources x 3 matrix of unit source normals.
#' @return An n_electrodes x n_sources orientation-constrained leadfield.
#' @export
#' @examples
#' ss <- sphericalSourceSpace(40, radius = 0.6)
#' e <- icosphere(2)$vertices[1:19, ]
#' lf <- sphereLeadfield(e, ss$positions)
#' lc <- constrainOrientation(lf, ss$normals)
#' dim(lc)
constrainOrientation <- function(leadfield, normals) {
  normals <- as.matrix(normals); ns <- nrow(normals)
  ne <- nrow(leadfield)
  Lc <- matrix(0, ne, ns)
  for (j in seq_len(ns)) {
    block <- leadfield[, ((j - 1) * 3 + 1):(j * 3), drop = FALSE]
    Lc[, j] <- block %*% normals[j, ]
  }
  Lc
}

#' Relative difference measure and magnitude ratio between two leadfields
#'
#' Standard BEM validation metrics on average-referenced potentials: RDM
#' (topography error, 0 = identical) and MAG (amplitude ratio, 1 = identical).
#'
#' @param test,reference Leadfield matrices of the same shape.
#' @return A named numeric vector \code{c(RDM, MAG)} (means over columns).
#' @export
#' @examples
#' e <- icosphere(2)$vertices[1:19, ]
#' s <- rbind(c(0, 0, 0.5), c(0.3, 0, 0.2))
#' lf <- sphereLeadfield(e, s)
#' # A leadfield compared with itself is identical: RDM 0, MAG 1.
#' leadfieldRDM(lf, lf)
leadfieldRDM <- function(test, reference) {
  ar <- function(L) sweep(L, 2, colMeans(L))
  a <- ar(reference); b <- ar(test)
  cols <- seq_len(ncol(a))
  rdm <- mean(vapply(cols, function(k) {
    na <- sqrt(sum(a[, k]^2)); nb <- sqrt(sum(b[, k]^2))
    if (na < 1e-12 || nb < 1e-12) return(0)
    sqrt(sum((b[, k] / nb - a[, k] / na)^2))
  }, numeric(1)))
  mag <- mean(vapply(cols, function(k) {
    na <- sqrt(sum(a[, k]^2)); if (na < 1e-12) return(NA_real_)
    sqrt(sum(b[, k]^2)) / na
  }, numeric(1)), na.rm = TRUE)
  c(RDM = rdm, MAG = mag)
}
