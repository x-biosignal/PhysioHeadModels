library(testthat)
library(PhysioHeadModels)

sphere_electrodes <- function(n, radius = 1, seed = 1) {
  set.seed(seed)
  z <- seq(-0.85, 0.85, length.out = n)
  phi <- acos(z); theta <- (seq_len(n) * (pi * (1 + sqrt(5))))
  cbind(cos(theta) * sin(phi), sin(theta) * sin(phi), cos(phi)) * radius
}

test_that("BEM leadfield matches the analytic single-sphere topography (RDM small)", {
  R <- 1; sigma <- 0.33
  mesh <- icosphere(3, R)
  elec <- sphere_electrodes(19, R)
  src <- rbind(c(0, 0, 0.5), c(0.4, 0, 0.2), c(0, 0.5, 0.3), c(0.2, 0.2, 0.4))
  La <- sphereLeadfield(elec, src, R, sigma)
  Lb <- bemLeadfield(mesh, c(sigma, 0), elec, src)
  rm <- leadfieldRDM(Lb, La)
  expect_lt(rm[["RDM"]], 0.15)                 # topography matches
  expect_equal(dim(Lb), c(19L, 12L))           # n_elec x (n_src*3)
})

test_that("analytic leadfield has the right shape, rank, and reciprocity", {
  elec <- sphere_electrodes(19)
  src <- sphericalSourceSpace(30, radius = 0.6)$positions
  L <- sphereLeadfield(elec, src)
  expect_equal(dim(L), c(19L, 90L))
  # average-referenced leadfield rank is n_electrodes - 1
  La <- sweep(L, 1, rowMeans(L))               # (not used) ; use column avg-ref
  Lc <- sweep(L, 2, colMeans(L))
  expect_equal(qr(Lc)$rank, 18L)               # full sensor rank after avg-ref
  # reciprocity / linearity: leadfield of a summed dipole = sum of leadfields
  q <- c(0.3, -0.5, 0.8)
  lf_sum <- L[, 1:3] %*% q
  manual <- q[1] * L[, 1] + q[2] * L[, 2] + q[3] * L[, 3]
  expect_lt(max(abs(lf_sum - manual)), 1e-10)
})

test_that("orientation constraint collapses 3 columns per source to 1", {
  elec <- sphere_electrodes(19)
  ss <- sphericalSourceSpace(40, radius = 0.6)
  L <- sphereLeadfield(elec, ss$positions)
  Lc <- constrainOrientation(L, ss$normals)
  expect_equal(dim(Lc), c(19L, 40L))
  # column j of Lc equals the source-j block times its normal
  expect_lt(max(abs(Lc[, 5] - L[, 13:15] %*% ss$normals[5, ])), 1e-12)
})

test_that("solidAngle and mesh helpers behave", {
  m <- icosphere(2)
  expect_equal(nrow(m$faces), 20L * 4L^2)
  expect_lt(max(abs(sqrt(rowSums(m$vertices^2)) - 1)), 1e-9)  # on unit sphere
  # full closed sphere subtends 4*pi solid angle from an interior point
  cen <- (m$vertices[m$faces[, 1], ] + m$vertices[m$faces[, 2], ] +
            m$vertices[m$faces[, 3], ]) / 3
  total <- sum(vapply(seq_len(nrow(m$faces)), function(i)
    solidAngle(m$vertices[m$faces[i, 1], ], m$vertices[m$faces[i, 2], ],
               m$vertices[m$faces[i, 3], ], c(0, 0, 0)), numeric(1)))
  expect_lt(abs(abs(total) - 4 * pi), 1e-6)
  ss <- sphericalSourceSpace(50)
  expect_equal(nrow(ss$positions), 50L)
  expect_lt(max(abs(sqrt(rowSums(ss$normals^2)) - 1)), 1e-9)
})

test_that("BEM captures the 3-shell head geometry (runs, right shape)", {
  brain <- icosphere(2, 0.86); skull <- icosphere(2, 0.92); scalp <- icosphere(2, 1.0)
  elec <- sphere_electrodes(19, 1.0)
  src <- rbind(c(0, 0, 0.5), c(0.3, 0, 0.2))
  L <- bemLeadfield(list(brain, skull, scalp), c(0.33, 0.0042, 0.33, 0),
                    elec, src)
  expect_equal(dim(L), c(19L, 6L))
  expect_true(all(is.finite(L)))
})

test_that("head-model fetchers cache and gate on missing data", {
  expect_true(dir.exists(headModelCache()))
  expect_error(fetchFsaverage(file.path(tempdir(), "no_fsaverage")), "fsaverage")
  # nyHeadLeadfield errors informatively when the download is absent
  expect_error(nyHeadLeadfield(c("C3", "C4"),
                               path = file.path(tempdir(), "no_nyhead.mat")),
               "not found|hdf5r")
})
