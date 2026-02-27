## ============================================================================
## 07_structural.R — Connected Backlash (apep_0464 v2)
## Structural estimation: SAR, SEM, and SDM models of opinion formation
##
## v2 changes (WS2 — referee request):
##   - Add SEM estimation (spatially correlated errors)
##   - Add SDM estimation (spatial Durbin: Wy + WX)
##   - Model comparison table with AIC/BIC and LR tests
##   - Honest assessment: does ρ reflect contagion or correlated shocks?
## ============================================================================

source("00_packages.R")

DATA_DIR <- "../data"

## ============================================================================
## MODEL: DeGroot Opinion Dynamics in Social Networks
## ============================================================================
##
## Micro-foundation: Voters in département d form political preferences
## through a DeGroot learning process on the social network.
##
##   s_dt = ρ × Σ_j w_dj × s_jt + (1-ρ) × [β × cost_dt + μ_d + τ_t] + ε_dt
##
## In matrix form:
##   (I - ρW) × s = Xβ + ε
##   s = (I - ρW)^{-1} × (Xβ + ε)
##
## The observed RN vote share maps to s_dt:
##   rn_dt = s_dt (linear observation equation)
##
## Three competing spatial specifications (v2):
##
##   SAR: y = ρWy + Xβ + ε              (network contagion)
##   SEM: y = Xβ + u, u = λWu + ε       (spatially correlated errors)
##   SDM: y = ρWy + Xβ + WXθ + ε        (contagion + spatial covariates)
##
## If SAR fits better → network amplification (DeGroot contagion)
## If SEM fits better → spatial shocks, not contagion
## If SDM fits better → both channels matter; θ≈0 validates SAR
##
## Identification: Variation in W (SCI structure) × variation in cost
##   across départements and elections.
##
## ============================================================================

## Load data
dept_panel <- readRDS(file.path(DATA_DIR, "dept_panel.rds"))
sci_matrix <- readRDS(file.path(DATA_DIR, "sci_matrix.rds"))
fuel_vuln <- readRDS(file.path(DATA_DIR, "fuel_vulnerability.rds"))
carbon_tax <- read_csv(file.path(DATA_DIR, "carbon_tax_schedule.csv"),
                       show_col_types = FALSE)

## ============================================================================
## 1. CONSTRUCT SPATIAL WEIGHT MATRIX W
## ============================================================================

cat("\n=== Constructing spatial weight matrix ===\n")

## Get the set of départements with complete data
dept_panel_clean <- dept_panel %>%
  filter(!is.na(co2_commute) & !is.na(network_fuel_norm) & !is.na(rn_share))

depts <- sort(unique(dept_panel_clean$dept_code))
N <- length(depts)
cat("Départements:", N, "\n")

## Build NxN row-normalized SCI weight matrix
W <- matrix(0, nrow = N, ncol = N)
rownames(W) <- colnames(W) <- depts

for (i in seq_along(depts)) {
  for (j in seq_along(depts)) {
    if (i != j) {
      sci_val <- sci_matrix %>%
        filter(dept_from == depts[i] & dept_to == depts[j]) %>%
        pull(sci_weight)
      if (length(sci_val) > 0) W[i, j] <- sci_val[1]
    }
  }
}

## Verify row-normalization
row_sums <- rowSums(W)
cat("Row sums range:", round(min(row_sums), 4), "to", round(max(row_sums), 4), "\n")

## Eigenvalues of W (needed for SAR likelihood)
eig_W <- eigen(W, only.values = TRUE)$values
cat("Eigenvalue range:", round(min(Re(eig_W)), 4), "to", round(max(Re(eig_W)), 4), "\n")

## Create listw object for spatialreg (used in SEM/SDM estimation)
## mat2listw requires a square matrix; style="W" ensures row-normalization
listw_W <- mat2listw(W, style = "W")

## ============================================================================
## 2. PREPARE PANEL DATA IN MATRIX FORM
## ============================================================================

cat("\n=== Preparing estimation data ===\n")

elections <- sort(unique(dept_panel_clean$id_election))
T_elec <- length(elections)

## Create balanced panel matrices: Y (NxT) and X (NxT)
Y <- matrix(NA, N, T_elec)
rownames(Y) <- depts
colnames(Y) <- elections

X_cost <- matrix(NA, N, T_elec)

for (t in seq_along(elections)) {
  elec_data <- dept_panel_clean %>%
    filter(id_election == elections[t]) %>%
    arrange(dept_code)

  matched <- match(elec_data$dept_code, depts)
  Y[matched, t] <- elec_data$rn_share
  X_cost[matched, t] <- elec_data$co2_commute * elec_data$rate_eur_tco2
}

## Demean within départements (absorb département FE)
Y_dm <- Y - rowMeans(Y, na.rm = TRUE)
X_dm <- X_cost - rowMeans(X_cost, na.rm = TRUE)

## Stack into vectors for estimation
y_vec <- as.vector(Y_dm)
x_vec <- as.vector(X_dm)

## Compute Wy for each period
Wy_dm <- W %*% Y_dm
wy_vec <- as.vector(Wy_dm)

## Also compute WX (spatial lag of cost) for later use
Wx_dm <- W %*% X_dm
wx_vec <- as.vector(Wx_dm)

## Remove NAs
valid <- !is.na(y_vec) & !is.na(x_vec) & !is.na(wy_vec)
y <- y_vec[valid]
x <- x_vec[valid]
wy <- wy_vec[valid]
wx <- wx_vec[valid]
n_obs <- length(y)

cat("Estimation sample:", n_obs, "obs (", N, "depts ×", T_elec, "elections)\n")

## ============================================================================
## 3. SAR MAXIMUM LIKELIHOOD ESTIMATION
## ============================================================================

cat("\n=== SAR ML Estimation ===\n")

## SAR log-likelihood function
## y = ρWy + xβ + ε, ε ~ N(0, σ²I)
## log L = -n/2 log(2πσ²) + T × log|I - ρW| - 1/(2σ²) × (y-ρWy-Xβ)'(y-ρWy-Xβ)

sar_loglik <- function(rho, y, wy, x, eig_w, T_periods) {
  n <- length(y)

  ## Concentrated likelihood: for given ρ, β and σ² have closed-form solutions
  ## Residuals from regression of (y - ρWy) on x
  z <- y - rho * wy
  XtX <- sum(x^2)
  Xtz <- sum(x * z)
  beta_hat <- Xtz / XtX
  resid <- z - beta_hat * x
  sigma2_hat <- sum(resid^2) / n

  ## Log determinant: log|I - ρW| = Σ log(1 - ρ × λ_i) for eigenvalues λ_i
  log_det <- sum(log(abs(1 - rho * Re(eig_w))))

  ## Log-likelihood
  ll <- -n/2 * log(2 * pi * sigma2_hat) + T_periods * log_det - n/2

  return(ll)
}

## Grid search over ρ ∈ (0, 0.99) for global optimum
rho_grid <- seq(0.01, 0.95, by = 0.01)
ll_grid <- sapply(rho_grid, function(rho) {
  sar_loglik(rho, y, wy, x, eig_W, T_elec)
})

rho_start <- rho_grid[which.max(ll_grid)]
cat("Grid search: best ρ =", round(rho_start, 3),
    ", log-lik =", round(max(ll_grid), 2), "\n")

## Fine optimization around grid optimum
opt <- optimize(function(rho) -sar_loglik(rho, y, wy, x, eig_W, T_elec),
                interval = c(max(0.001, rho_start - 0.1),
                             min(0.999, rho_start + 0.1)),
                tol = 1e-12)
rho_hat <- opt$minimum
ll_max <- -opt$objective

## Recover β and σ² at optimum
z_hat <- y - rho_hat * wy
beta_hat <- sum(x * z_hat) / sum(x^2)
resid_hat <- z_hat - beta_hat * x
sigma2_hat <- sum(resid_hat^2) / n_obs

## AIC and BIC for SAR (3 parameters: ρ, β, σ²)
k_sar <- 3
aic_sar <- -2 * ll_max + 2 * k_sar
bic_sar <- -2 * ll_max + k_sar * log(n_obs)

cat("\n--- SAR Parameter Estimates ---\n")
cat(sprintf("  ρ (network contagion): %.4f  *** KEY PARAMETER ***\n", rho_hat))
cat(sprintf("  β (cost sensitivity):  %.4f\n", beta_hat))
cat(sprintf("  σ² (residual var):     %.4f\n", sigma2_hat))
cat(sprintf("  σ  (residual SD):      %.2f pp\n", sqrt(sigma2_hat)))
cat(sprintf("  Log-likelihood:        %.2f\n", ll_max))
cat(sprintf("  AIC:                   %.2f\n", aic_sar))
cat(sprintf("  BIC:                   %.2f\n", bic_sar))

## ============================================================================
## 4. STANDARD ERRORS
## ============================================================================

cat("\n=== Standard Errors ===\n")

## Asymptotic variance of ρ from information matrix
## For SAR: Var(ρ) ≈ [tr(W̃'W̃) + tr(W̃²)]^{-1}
## where W̃ = W(I - ρW)^{-1}
## Plus the contribution from σ² estimation

## Numerical approach: compute Hessian of concentrated log-likelihood at optimum
delta_rho <- 1e-5
ll_plus <- sar_loglik(rho_hat + delta_rho, y, wy, x, eig_W, T_elec)
ll_minus <- sar_loglik(rho_hat - delta_rho, y, wy, x, eig_W, T_elec)
ll_center <- sar_loglik(rho_hat, y, wy, x, eig_W, T_elec)

d2ll_drho2 <- (ll_plus - 2 * ll_center + ll_minus) / delta_rho^2
se_rho <- sqrt(-1 / d2ll_drho2)

## Standard error for β (from OLS on z = y - ρWy)
se_beta <- sqrt(sigma2_hat / sum(x^2))

## Likelihood ratio test: H0: ρ = 0
ll_null <- sar_loglik(0, y, wy, x, eig_W, T_elec)
lr_stat <- 2 * (ll_max - ll_null)
lr_pval <- pchisq(lr_stat, df = 1, lower.tail = FALSE)

cat(sprintf("  SE(ρ): %.4f  [95%% CI: %.4f, %.4f]\n",
            se_rho, rho_hat - 1.96*se_rho, rho_hat + 1.96*se_rho))
cat(sprintf("  SE(β): %.4f  [95%% CI: %.4f, %.4f]\n",
            se_beta, beta_hat - 1.96*se_beta, beta_hat + 1.96*se_beta))
cat(sprintf("  LR test (ρ=0): χ²=%.2f, p=%.6f\n", lr_stat, lr_pval))

## ============================================================================
## 5. SPATIAL MULTIPLIER AND DIRECT/INDIRECT EFFECTS
## ============================================================================

cat("\n=== Spatial Multiplier Analysis ===\n")

## Total effects matrix: S = (I - ρW)^{-1}
I_N <- diag(N)
S <- solve(I_N - rho_hat * W)

## Direct effect: average of diagonal of S × β
direct_effect <- mean(diag(S)) * beta_hat
total_effect <- mean(rowSums(S)) * beta_hat
indirect_effect <- total_effect - direct_effect
multiplier <- total_effect / (beta_hat)  # = mean(rowSums(S))

cat(sprintf("  Direct effect:    %.4f (a 1€ cost increase → %.3f pp RN)\n",
            direct_effect, direct_effect))
cat(sprintf("  Indirect effect:  %.4f (via network contagion)\n", indirect_effect))
cat(sprintf("  Total effect:     %.4f\n", total_effect))
cat(sprintf("  Network multiplier: %.3f (total/β)\n", multiplier))
cat(sprintf("  Amplification:    %.1f%% of direct effect\n",
            indirect_effect / direct_effect * 100))

## ============================================================================
## 6. SEM ESTIMATION (v2: Referee Request)
## ============================================================================
##
## Spatial Error Model: y = Xβ + u, u = λWu + ε
##
## Unlike SAR, the spatial dependence is in the ERROR term, not the outcome.
## If λ is large and ρ from SAR is also large, it suggests that the high SAR ρ
## may partly reflect spatially correlated unobservables rather than true
## network contagion.
##
## Strategy: Estimate on long-difference cross-section (post minus pre average)
## to work cleanly with spatialreg's cross-sectional functions.
## Also estimate on pooled demeaned panel for comparison.
##
## ============================================================================

cat("\n=== SEM Estimation (v2) ===\n")

## --- 6a. Long-difference cross-section ---
## Δy = avg(y_post) - avg(y_pre), where post = 2017+ (carbon tax active)
## This differences out département FE and is a clean cross-section.

year_vec <- as.integer(substr(elections, 1, 4))
pre_cols <- which(year_vec < 2017)
post_cols <- which(year_vec >= 2017)

Y_pre_avg <- rowMeans(Y[, pre_cols, drop = FALSE], na.rm = TRUE)
Y_post_avg <- rowMeans(Y[, post_cols, drop = FALSE], na.rm = TRUE)
X_pre_avg <- rowMeans(X_cost[, pre_cols, drop = FALSE], na.rm = TRUE)
X_post_avg <- rowMeans(X_cost[, post_cols, drop = FALSE], na.rm = TRUE)

delta_y <- Y_post_avg - Y_pre_avg
delta_x <- X_post_avg - X_pre_avg

## Drop any NAs
valid_ld <- !is.na(delta_y) & !is.na(delta_x)
n_ld <- sum(valid_ld)
cat("Long-difference cross-section:", n_ld, "départements\n")

## Assemble data frame for spatialreg
ld_df <- data.frame(
  delta_y = delta_y[valid_ld],
  delta_x = delta_x[valid_ld]
)

## Subset listw to valid observations (in case some depts dropped)
## If all depts are valid, use full listw; otherwise subset
if (n_ld == N) {
  listw_ld <- listw_W
} else {
  W_sub <- W[valid_ld, valid_ld]
  ## Re-normalize rows after subsetting
  rs <- rowSums(W_sub)
  rs[rs == 0] <- 1  # avoid division by zero for isolates
  W_sub <- W_sub / rs
  listw_ld <- mat2listw(W_sub, style = "W")
}

## --- SEM on long-difference ---
cat("\n--- SEM: Long-Difference Estimation ---\n")
sem_ld <- tryCatch({
  errorsarlm(delta_y ~ delta_x, data = ld_df, listw = listw_ld)
}, error = function(e) {
  cat("  SEM estimation failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(sem_ld)) {
  sem_ld_summ <- summary(sem_ld, Nagelkerke = TRUE)
  lambda_ld <- sem_ld$lambda
  beta_sem_ld <- coef(sem_ld)
  sigma2_sem_ld <- sem_ld$s2
  ll_sem_ld <- logLik(sem_ld)
  k_sem_ld <- length(coef(sem_ld)) + 2  # β's + λ + σ²
  aic_sem_ld <- AIC(sem_ld)
  bic_sem_ld <- BIC(sem_ld)

  cat(sprintf("  λ (spatial error): %.4f\n", lambda_ld))
  cat(sprintf("  β (intercept):     %.4f\n", beta_sem_ld["(Intercept)"]))
  cat(sprintf("  β (delta_x):       %.4f\n", beta_sem_ld["delta_x"]))
  cat(sprintf("  σ²:                %.4f\n", sigma2_sem_ld))
  cat(sprintf("  Log-likelihood:    %.2f\n", as.numeric(ll_sem_ld)))
  cat(sprintf("  AIC:               %.2f\n", aic_sem_ld))
  cat(sprintf("  BIC:               %.2f\n", bic_sem_ld))
} else {
  lambda_ld <- NA_real_
  ll_sem_ld <- NA_real_
  aic_sem_ld <- NA_real_
  bic_sem_ld <- NA_real_
}

## --- 6b. SAR on long-difference (for comparison on same data) ---
cat("\n--- SAR: Long-Difference Estimation ---\n")
sar_ld <- tryCatch({
  lagsarlm(delta_y ~ delta_x, data = ld_df, listw = listw_ld)
}, error = function(e) {
  cat("  SAR-LD estimation failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(sar_ld)) {
  sar_ld_summ <- summary(sar_ld, Nagelkerke = TRUE)
  rho_ld <- sar_ld$rho
  beta_sar_ld <- coef(sar_ld)
  sigma2_sar_ld <- sar_ld$s2
  ll_sar_ld <- logLik(sar_ld)
  aic_sar_ld <- AIC(sar_ld)
  bic_sar_ld <- BIC(sar_ld)

  cat(sprintf("  ρ (spatial lag):   %.4f\n", rho_ld))
  cat(sprintf("  β (intercept):     %.4f\n", beta_sar_ld["(Intercept)"]))
  cat(sprintf("  β (delta_x):       %.4f\n", beta_sar_ld["delta_x"]))
  cat(sprintf("  σ²:                %.4f\n", sigma2_sar_ld))
  cat(sprintf("  Log-likelihood:    %.2f\n", as.numeric(ll_sar_ld)))
  cat(sprintf("  AIC:               %.2f\n", aic_sar_ld))
  cat(sprintf("  BIC:               %.2f\n", bic_sar_ld))
} else {
  rho_ld <- NA_real_
  ll_sar_ld <- NA_real_
  aic_sar_ld <- NA_real_
  bic_sar_ld <- NA_real_
}

## ============================================================================
## 7. SDM ESTIMATION (v2: Referee Request)
## ============================================================================
##
## Spatial Durbin Model: y = ρWy + Xβ + WXθ + ε
##
## The SDM nests both SAR (θ=0) and SEM (θ = -ρβ, the common factor test).
## If θ ≈ 0, SAR is adequate and the network contagion interpretation holds.
## If θ ≠ 0, neighbours' cost exposure has a separate effect beyond contagion.
##
## ============================================================================

cat("\n=== SDM Estimation (v2) ===\n")

## --- 7a. SDM on long-difference ---
cat("\n--- SDM: Long-Difference Estimation ---\n")
sdm_ld <- tryCatch({
  lagsarlm(delta_y ~ delta_x, data = ld_df, listw = listw_ld, type = "mixed")
}, error = function(e) {
  cat("  SDM estimation failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(sdm_ld)) {
  sdm_ld_summ <- summary(sdm_ld, Nagelkerke = TRUE)
  rho_sdm_ld <- sdm_ld$rho
  beta_sdm_ld <- coef(sdm_ld)
  sigma2_sdm_ld <- sdm_ld$s2
  ll_sdm_ld <- logLik(sdm_ld)
  aic_sdm_ld <- AIC(sdm_ld)
  bic_sdm_ld <- BIC(sdm_ld)

  cat(sprintf("  ρ (spatial lag):     %.4f\n", rho_sdm_ld))
  cat(sprintf("  β (intercept):       %.4f\n", beta_sdm_ld["(Intercept)"]))
  cat(sprintf("  β (delta_x):         %.4f\n", beta_sdm_ld["delta_x"]))
  ## The spatial lag of delta_x is named lag.delta_x by spatialreg
  theta_name <- grep("lag\\.", names(beta_sdm_ld), value = TRUE)
  if (length(theta_name) > 0) {
    cat(sprintf("  θ (W × delta_x):     %.4f  *** SDM KEY ***\n",
                beta_sdm_ld[theta_name[1]]))
  }
  cat(sprintf("  σ²:                  %.4f\n", sigma2_sdm_ld))
  cat(sprintf("  Log-likelihood:      %.2f\n", as.numeric(ll_sdm_ld)))
  cat(sprintf("  AIC:                 %.2f\n", aic_sdm_ld))
  cat(sprintf("  BIC:                 %.2f\n", bic_sdm_ld))
} else {
  rho_sdm_ld <- NA_real_
  ll_sdm_ld <- NA_real_
  aic_sdm_ld <- NA_real_
  bic_sdm_ld <- NA_real_
}

## ============================================================================
## 8. MODEL COMPARISON TABLE (v2: Referee Request)
## ============================================================================
##
## Compare SAR, SEM, SDM on the long-difference cross-section.
## Also report the custom SAR panel ML for reference.
## LR test: SAR vs SDM tests H0: θ = 0 (SAR is adequate).
##
## ============================================================================

cat("\n=== Model Comparison (v2) ===\n")

## --- 8a. Long-difference comparison table ---
cat("\n--- Long-Difference Cross-Section (Δy = y_post - y_pre) ---\n")

model_comparison_ld <- tibble(
  model = c("SAR (spatialreg)", "SEM", "SDM"),
  spatial_param = c(
    ifelse(!is.null(sar_ld), sprintf("ρ=%.4f", rho_ld), "—"),
    ifelse(!is.null(sem_ld), sprintf("λ=%.4f", lambda_ld), "—"),
    ifelse(!is.null(sdm_ld), sprintf("ρ=%.4f", rho_sdm_ld), "—")
  ),
  beta_cost = c(
    ifelse(!is.null(sar_ld), round(beta_sar_ld["delta_x"], 4), NA_real_),
    ifelse(!is.null(sem_ld), round(beta_sem_ld["delta_x"], 4), NA_real_),
    ifelse(!is.null(sdm_ld), round(beta_sdm_ld["delta_x"], 4), NA_real_)
  ),
  theta_WX = c(
    NA_real_,
    NA_real_,
    ifelse(!is.null(sdm_ld) && length(theta_name) > 0,
           round(beta_sdm_ld[theta_name[1]], 4), NA_real_)
  ),
  sigma2 = c(
    ifelse(!is.null(sar_ld), round(sigma2_sar_ld, 4), NA_real_),
    ifelse(!is.null(sem_ld), round(sigma2_sem_ld, 4), NA_real_),
    ifelse(!is.null(sdm_ld), round(sigma2_sdm_ld, 4), NA_real_)
  ),
  log_lik = c(
    ifelse(!is.null(sar_ld), round(as.numeric(ll_sar_ld), 2), NA_real_),
    ifelse(!is.null(sem_ld), round(as.numeric(ll_sem_ld), 2), NA_real_),
    ifelse(!is.null(sdm_ld), round(as.numeric(ll_sdm_ld), 2), NA_real_)
  ),
  AIC = c(
    ifelse(!is.null(sar_ld), round(aic_sar_ld, 2), NA_real_),
    ifelse(!is.null(sem_ld), round(aic_sem_ld, 2), NA_real_),
    ifelse(!is.null(sdm_ld), round(aic_sdm_ld, 2), NA_real_)
  ),
  BIC = c(
    ifelse(!is.null(sar_ld), round(bic_sar_ld, 2), NA_real_),
    ifelse(!is.null(sem_ld), round(bic_sem_ld, 2), NA_real_),
    ifelse(!is.null(sdm_ld), round(bic_sdm_ld, 2), NA_real_)
  )
)

cat("\nModel comparison (long-difference):\n")
print(model_comparison_ld)

## --- 8b. LR test: SAR nested in SDM (H0: θ = 0) ---
lr_sar_sdm <- NA_real_
lr_sar_sdm_pval <- NA_real_
lr_sar_sdm_df <- NA_integer_

if (!is.null(sar_ld) && !is.null(sdm_ld)) {
  lr_sar_sdm_df <- as.integer(attr(ll_sdm_ld, "df") - attr(ll_sar_ld, "df"))
  if (!is.na(lr_sar_sdm_df) && lr_sar_sdm_df > 0) {
    lr_sar_sdm <- 2 * (as.numeric(ll_sdm_ld) - as.numeric(ll_sar_ld))
    lr_sar_sdm_pval <- pchisq(lr_sar_sdm, df = lr_sar_sdm_df, lower.tail = FALSE)
  } else {
    ## Fallback: count theta parameters manually
    ## SDM has one extra parameter per covariate (the WX lag)
    n_theta <- length(theta_name)
    if (n_theta > 0) {
      lr_sar_sdm_df <- as.integer(n_theta)
      lr_sar_sdm <- 2 * (as.numeric(ll_sdm_ld) - as.numeric(ll_sar_ld))
      lr_sar_sdm_pval <- pchisq(lr_sar_sdm, df = lr_sar_sdm_df, lower.tail = FALSE)
    }
  }
  cat(sprintf("\nLR test SAR vs SDM (H0: θ=0): χ²=%.3f, df=%d, p=%.4f\n",
              lr_sar_sdm, lr_sar_sdm_df, lr_sar_sdm_pval))
  if (!is.na(lr_sar_sdm_pval) && lr_sar_sdm_pval > 0.05) {
    cat("  → Cannot reject θ=0: SAR is adequate, network contagion interpretation holds.\n")
  } else if (!is.na(lr_sar_sdm_pval)) {
    cat("  → Reject θ=0: SDM preferred, neighbours' costs matter beyond contagion.\n")
  }
}

## --- 8c. Honest assessment: SAR vs SEM ---
if (!is.null(sar_ld) && !is.null(sem_ld)) {
  ll_diff_sar_sem <- as.numeric(ll_sar_ld) - as.numeric(ll_sem_ld)
  cat(sprintf("\nSAR vs SEM log-likelihood difference: %.3f\n", ll_diff_sar_sem))
  cat(sprintf("  SAR AIC: %.2f  |  SEM AIC: %.2f  |  Δ = %.2f\n",
              aic_sar_ld, aic_sem_ld, aic_sar_ld - aic_sem_ld))
  cat(sprintf("  SAR BIC: %.2f  |  SEM BIC: %.2f  |  Δ = %.2f\n",
              bic_sar_ld, bic_sem_ld, bic_sar_ld - bic_sem_ld))

  if (aic_sar_ld < aic_sem_ld) {
    cat("  → SAR fits better by AIC: network contagion dominates correlated shocks.\n")
  } else if (abs(aic_sar_ld - aic_sem_ld) < 2) {
    cat("  → SAR and SEM fit similarly (ΔAIC < 2): cannot cleanly distinguish\n")
    cat("    contagion from spatially correlated errors. Both channels likely present.\n")
    cat("    *** HONEST CAVEAT: High ρ in SAR may partly capture correlated shocks. ***\n")
  } else {
    cat("  → SEM fits better by AIC: spatial shocks dominate contagion.\n")
    cat("    *** HONEST CAVEAT: SAR ρ likely reflects correlated unobservables, ***\n")
    cat("    *** not exclusively network contagion. Report with appropriate caveats. ***\n")
  }
}

## --- 8d. Panel SAR comparison row (custom ML from section 3) ---
cat("\n--- Panel SAR (custom ML with département FE) ---\n")
cat(sprintf("  ρ = %.4f, β = %.4f, σ² = %.4f\n", rho_hat, beta_hat, sigma2_hat))
cat(sprintf("  Log-lik = %.2f, AIC = %.2f, BIC = %.2f\n", ll_max, aic_sar, bic_sar))
cat(sprintf("  N_obs = %d (%d depts × %d elections)\n", n_obs, N, T_elec))

## ============================================================================
## 9. CROSS-SECTIONAL SAR BY ELECTION (Time-varying ρ)
## ============================================================================

cat("\n=== Cross-sectional SAR by election ===\n")

rho_by_election <- tibble(
  election = character(),
  year = integer(),
  rho = double(),
  se_rho = double(),
  beta = double(),
  n_obs = integer(),
  log_lik = double()
)

for (t in seq_along(elections)) {
  y_t <- Y_dm[, t]
  x_t <- X_dm[, t]
  wy_t <- (W %*% Y_dm[, t])[, 1]

  valid_t <- !is.na(y_t) & !is.na(x_t)
  if (sum(valid_t) < 10) next

  y_t <- y_t[valid_t]
  x_t <- x_t[valid_t]
  wy_t <- wy_t[valid_t]

  ## Grid search for this election
  ll_t <- sapply(rho_grid, function(rho) {
    sar_loglik(rho, y_t, wy_t, x_t, eig_W, 1)
  })

  rho_t_start <- rho_grid[which.max(ll_t)]

  opt_t <- optimize(function(rho) -sar_loglik(rho, y_t, wy_t, x_t, eig_W, 1),
                    interval = c(max(0.001, rho_t_start - 0.15),
                                 min(0.999, rho_t_start + 0.15)),
                    tol = 1e-10)

  rho_t <- opt_t$minimum
  ll_t_max <- -opt_t$objective

  ## Recover β
  z_t <- y_t - rho_t * wy_t
  beta_t <- sum(x_t * z_t) / sum(x_t^2)

  ## SE via numerical Hessian
  d <- 1e-5
  ll_p <- sar_loglik(rho_t + d, y_t, wy_t, x_t, eig_W, 1)
  ll_m <- sar_loglik(rho_t - d, y_t, wy_t, x_t, eig_W, 1)
  ll_c <- sar_loglik(rho_t, y_t, wy_t, x_t, eig_W, 1)
  d2 <- (ll_p - 2*ll_c + ll_m) / d^2
  se_t <- if (d2 < 0) sqrt(-1/d2) else NA_real_

  year_t <- as.integer(substr(elections[t], 1, 4))

  rho_by_election <- bind_rows(rho_by_election,
    tibble(election = elections[t], year = year_t,
           rho = rho_t, se_rho = se_t, beta = beta_t,
           n_obs = sum(valid_t), log_lik = ll_t_max))
}

cat("\nNetwork contagion (ρ) by election:\n")
rho_by_election <- rho_by_election %>%
  mutate(
    carbon_rate = carbon_tax$rate_eur_tco2[match(year, carbon_tax$year)],
    stars = case_when(
      rho / se_rho > 2.576 ~ "***",
      rho / se_rho > 1.96 ~ "**",
      rho / se_rho > 1.645 ~ "*",
      TRUE ~ ""
    )
  )
print(rho_by_election)

## ============================================================================
## 10. COUNTERFACTUAL: NO NETWORK AMPLIFICATION
## ============================================================================

cat("\n=== Counterfactual 1: No Network (ρ=0) ===\n")

## Predicted RN share under actual model vs no-network
Y_pred_actual <- matrix(NA, N, T_elec)
Y_pred_no_net <- matrix(NA, N, T_elec)

for (t in seq_along(elections)) {
  ## Under actual ρ: y = (I-ρW)^{-1} Xβ + dept_FE + election_FE
  ## The demeaned prediction is: y_dm = ρ × Wy_dm + x_dm × β
  ## So y_dm(actual) = S × x_dm × β where S = (I-ρW)^{-1}
  ## And y_dm(no_net) = x_dm × β (when ρ=0)
  x_t <- X_dm[, t]
  valid_t <- !is.na(x_t) & !is.na(Y[, t])

  if (sum(valid_t) > 0) {
    x_full <- rep(0, N)
    x_full[valid_t] <- x_t[valid_t]

    Y_pred_actual[, t] <- (S %*% (x_full * beta_hat))[, 1]
    Y_pred_no_net[, t] <- x_full * beta_hat
  }
}

## Network amplification: predicted_actual - predicted_no_net
network_amp <- Y_pred_actual - Y_pred_no_net

cf1_summary <- tibble(
  election = elections,
  year = as.integer(substr(elections, 1, 4)),
  mean_rn_actual = colMeans(Y, na.rm = TRUE),
  mean_pred_with_network = colMeans(Y_pred_actual, na.rm = TRUE),
  mean_pred_no_network = colMeans(Y_pred_no_net, na.rm = TRUE),
  mean_network_amplification = colMeans(network_amp, na.rm = TRUE)
)

cat("\nNetwork amplification of RN vote share (within-département):\n")
print(cf1_summary)

## Average amplification in post-carbon-tax period
post_amp <- cf1_summary %>%
  filter(year >= 2017) %>%
  pull(mean_network_amplification)
cat(sprintf("\nAverage network amplification (post-2017): %.2f pp\n", mean(post_amp)))

## ============================================================================
## 11. COUNTERFACTUAL: COMPENSATING TRANSFERS
## ============================================================================

cat("\n=== Counterfactual 2: Revenue-Neutral Carbon Dividends ===\n")

## Replace heterogeneous cost with mean cost (= revenue-neutral lump-sum transfer)
X_transfer <- X_cost
for (t in seq_along(elections)) {
  avg_cost <- mean(X_cost[, t], na.rm = TRUE)
  X_transfer[, t] <- avg_cost  # Everyone faces average cost
}
X_transfer_dm <- X_transfer - rowMeans(X_transfer, na.rm = TRUE)

## Under transfers, the within-département variation in cost disappears
## So the predicted demeaned RN = S × x_transfer_dm × β ≈ 0 (since x is constant)
Y_pred_transfer <- matrix(NA, N, T_elec)
for (t in seq_along(elections)) {
  x_t <- X_transfer_dm[, t]
  x_full <- rep(0, N)
  valid_t <- !is.na(x_t)
  x_full[valid_t] <- x_t[valid_t]
  Y_pred_transfer[, t] <- (S %*% (x_full * beta_hat))[, 1]
}

transfer_effect <- Y_pred_actual - Y_pred_transfer

cf2_summary <- tibble(
  election = elections,
  year = as.integer(substr(elections, 1, 4)),
  mean_rn_no_transfer = colMeans(Y_pred_actual, na.rm = TRUE),
  mean_rn_with_transfer = colMeans(Y_pred_transfer, na.rm = TRUE),
  mean_transfer_effect = colMeans(transfer_effect, na.rm = TRUE)
)

cat("\nEffect of equalizing transfers:\n")
print(cf2_summary)

## ============================================================================
## 12. COUNTERFACTUAL: NETWORK DENSITY SCALING
## ============================================================================

cat("\n=== Counterfactual 3: Network Density ===\n")

density_results <- tibble(
  multiplier = double(),
  rho_effective = double(),
  avg_multiplier = double(),
  avg_amplification = double()
)

for (mult in c(0.0, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0)) {
  ## Scale ρ by multiplier (keeping W fixed)
  rho_scaled <- min(rho_hat * mult, 0.999)
  S_scaled <- solve(I_N - rho_scaled * W)

  ## Average spatial multiplier
  avg_mult <- mean(rowSums(S_scaled))

  ## Average amplification (total - direct for post-2017)
  amp_vals <- numeric()
  for (t in seq_along(elections)) {
    yr <- as.integer(substr(elections[t], 1, 4))
    if (yr >= 2017) {
      x_t <- X_dm[, t]
      x_full <- rep(0, N)
      valid_t <- !is.na(x_t)
      x_full[valid_t] <- x_t[valid_t]

      pred_net <- (S_scaled %*% (x_full * beta_hat))[, 1]
      pred_no <- x_full * beta_hat
      amp_vals <- c(amp_vals, mean(pred_net - pred_no, na.rm = TRUE))
    }
  }

  density_results <- bind_rows(density_results,
    tibble(multiplier = mult, rho_effective = rho_scaled,
           avg_multiplier = avg_mult,
           avg_amplification = mean(amp_vals)))
}

cat("\nNetwork density scaling results:\n")
print(density_results)

## ============================================================================
## 13. IMPULSE RESPONSE: WHICH DÉPARTEMENTS SPREAD MOST?
## ============================================================================

cat("\n=== Impulse Response Analysis ===\n")

## For each département, compute how much a cost shock there propagates
## Total outgoing influence: column sum of S (how much d affects all others)
## Total incoming influence: row sum of S (how much d is affected by all)

dept_influence <- tibble(
  dept_code = depts,
  outgoing_influence = colSums(S) - diag(S),  # Exclude self
  incoming_influence = rowSums(S) - diag(S),   # Exclude self
  self_multiplier = diag(S)
) %>%
  left_join(fuel_vuln, by = "dept_code") %>%
  mutate(
    total_network_impact = outgoing_influence * co2_commute * beta_hat,
    rank_impact = rank(-total_network_impact)
  ) %>%
  arrange(rank_impact)

cat("\nTop 10 départements by network influence (spreading):\n")
print(dept_influence %>% head(10) %>%
        select(dept_code, co2_commute, outgoing_influence,
               total_network_impact, rank_impact))

cat("\nTop 10 départements by network vulnerability (receiving):\n")
print(dept_influence %>%
        arrange(-incoming_influence) %>%
        head(10) %>%
        select(dept_code, co2_commute, incoming_influence, self_multiplier))

## ============================================================================
## SAVE ALL RESULTS
## ============================================================================

structural_results <- list(
  ## --- SAR panel (custom ML, v1 core) ---
  parameters = list(
    rho = rho_hat,
    beta = beta_hat,
    sigma2 = sigma2_hat,
    sigma = sqrt(sigma2_hat)
  ),
  standard_errors = list(
    se_rho = se_rho,
    se_beta = se_beta
  ),
  tests = list(
    lr_stat = lr_stat,
    lr_pval = lr_pval,
    ll_max = ll_max,
    ll_null = ll_null,
    aic_sar = aic_sar,
    bic_sar = bic_sar
  ),
  spatial_effects = list(
    direct_effect = direct_effect,
    indirect_effect = indirect_effect,
    total_effect = total_effect,
    multiplier = multiplier
  ),
  rho_by_election = rho_by_election,

  ## --- v2: SEM estimation ---
  sem = list(
    model = sem_ld,
    lambda = ifelse(!is.null(sem_ld), lambda_ld, NA_real_),
    beta = if (!is.null(sem_ld)) beta_sem_ld else NULL,
    sigma2 = ifelse(!is.null(sem_ld), sigma2_sem_ld, NA_real_),
    log_lik = ifelse(!is.null(sem_ld), as.numeric(ll_sem_ld), NA_real_),
    aic = ifelse(!is.null(sem_ld), aic_sem_ld, NA_real_),
    bic = ifelse(!is.null(sem_ld), bic_sem_ld, NA_real_)
  ),

  ## --- v2: SAR on long-difference (for apples-to-apples comparison) ---
  sar_ld = list(
    model = sar_ld,
    rho = ifelse(!is.null(sar_ld), rho_ld, NA_real_),
    beta = if (!is.null(sar_ld)) beta_sar_ld else NULL,
    sigma2 = ifelse(!is.null(sar_ld), sigma2_sar_ld, NA_real_),
    log_lik = ifelse(!is.null(sar_ld), as.numeric(ll_sar_ld), NA_real_),
    aic = ifelse(!is.null(sar_ld), aic_sar_ld, NA_real_),
    bic = ifelse(!is.null(sar_ld), bic_sar_ld, NA_real_)
  ),

  ## --- v2: SDM estimation ---
  sdm = list(
    model = sdm_ld,
    rho = ifelse(!is.null(sdm_ld), rho_sdm_ld, NA_real_),
    beta = if (!is.null(sdm_ld)) beta_sdm_ld else NULL,
    theta_names = if (!is.null(sdm_ld)) theta_name else NULL,
    sigma2 = ifelse(!is.null(sdm_ld), sigma2_sdm_ld, NA_real_),
    log_lik = ifelse(!is.null(sdm_ld), as.numeric(ll_sdm_ld), NA_real_),
    aic = ifelse(!is.null(sdm_ld), aic_sdm_ld, NA_real_),
    bic = ifelse(!is.null(sdm_ld), bic_sdm_ld, NA_real_)
  ),

  ## --- v2: Model comparison ---
  model_comparison = list(
    comparison_table = model_comparison_ld,
    lr_sar_vs_sdm = lr_sar_sdm,
    lr_sar_vs_sdm_pval = lr_sar_sdm_pval,
    lr_sar_vs_sdm_df = lr_sar_sdm_df,
    n_long_diff = n_ld
  ),

  ## --- Counterfactuals (v1 core) ---
  counterfactual_no_network = cf1_summary,
  counterfactual_transfers = cf2_summary,
  counterfactual_density = density_results,
  dept_influence = dept_influence,
  W = W,
  S = S,
  model_fit = list(
    n_obs = n_obs,
    n_dept = N,
    n_elec = T_elec
  )
)

saveRDS(structural_results, file.path(DATA_DIR, "structural_results.rds"))
cat("\nStructural results saved.\n")

cat("\n", strrep("=", 60), "\n")
cat("STRUCTURAL ESTIMATION COMPLETE (v2: SAR + SEM + SDM)\n")
cat(strrep("=", 60), "\n")
cat(sprintf("\nKEY RESULTS:\n"))
cat(sprintf("  Panel SAR:  ρ = %.3f (SE = %.3f)\n", rho_hat, se_rho))
cat(sprintf("  Network multiplier: %.2f (a 1€ shock → %.2f€ total effect)\n",
            multiplier, total_effect))
cat(sprintf("  LR test H0:ρ=0: χ²=%.2f (p=%.6f)\n", lr_stat, lr_pval))

if (!is.null(sar_ld)) {
  cat(sprintf("\n  Long-diff SAR: ρ = %.3f\n", rho_ld))
}
if (!is.null(sem_ld)) {
  cat(sprintf("  Long-diff SEM: λ = %.3f\n", lambda_ld))
}
if (!is.null(sdm_ld)) {
  cat(sprintf("  Long-diff SDM: ρ = %.3f", rho_sdm_ld))
  if (length(theta_name) > 0) {
    cat(sprintf(", θ = %.3f", beta_sdm_ld[theta_name[1]]))
  }
  cat("\n")
}
if (!is.na(lr_sar_sdm_pval)) {
  cat(sprintf("  LR SAR vs SDM: χ²=%.3f, p=%.4f %s\n",
              lr_sar_sdm, lr_sar_sdm_pval,
              ifelse(lr_sar_sdm_pval > 0.05, "(SAR adequate)", "(SDM preferred)")))
}
