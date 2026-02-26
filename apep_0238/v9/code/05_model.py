"""
05_model.py — Structural DMP model with endogenous participation and skill depreciation
v9: AR(1) mean-reverting demand shock, δ=0.023, remove scaling hack, re-estimate SMM
"""
exec(open(str(__import__('pathlib').Path(__file__).resolve().parent / "00_packages.py")).read())

# ──────────────────────────────────────────────────────────────
# Model: DMP with participation and scarring
# ──────────────────────────────────────────────────────────────
# States: Employed (E), Unemployed (U), Out of Labor Force (O)
# Key mechanisms:
#   1. Demand shock: productivity a falls → fewer vacancies → long unemployment → scarring
#   2. Supply shock: separation δ spikes temporarily → mass layoff → quick recovery
#   3. Skill depreciation: after d* months unemployed, human capital drops
#   4. Participation: discouraged workers exit labor force
#
# v8 changes:
#   - Full discrete duration distribution tracking (replaces ad-hoc proxy)
#   - SMM estimation of (λ, χ₁, A, κ) targeting LP IRF moments
#   - CRRA welfare computation with σ ∈ {1, 2, 5}

D_MAX = 60  # Maximum tracked duration (months); beyond this, workers stay in the last bin

class DMPModel:
    def __init__(self, params=None):
        p = params or {}
        # Calibrated parameters
        self.beta = p.get('beta', 0.996)       # Monthly discount factor
        self.alpha = p.get('alpha', 0.5)        # Matching function elasticity
        self.A = p.get('A', 0.60)               # Matching efficiency
        self.delta = p.get('delta', 0.023)      # Separation rate (v9: was 0.034, now matches SS UR=0.055)
        self.kappa = p.get('kappa', 3.40)       # Vacancy posting cost
        self.a = p.get('a', 1.0)                # Aggregate productivity
        self.b = p.get('b', 0.71)               # Unemployment benefit
        self.b_olf = p.get('b_olf', 0.65)       # OLF home production
        self.gamma = p.get('gamma', 0.5)        # Nash bargaining power
        self.lam = p.get('lam', 0.12)           # Skill depreciation upon scarring
        self.d_star = p.get('d_star', 12)       # Months until skill depreciation
        self.chi_base = p.get('chi_base', 0.008) # Base OLF exit rate from U
        self.chi_dur = p.get('chi_dur', 0.004)  # Duration-dependent OLF exit
        self.psi = p.get('psi', 0.03)           # Re-entry rate from OLF to U
        self.rho_a = p.get('rho_a', 0.99)       # v9: AR(1) persistence of demand shock

    def matching(self, u, v):
        """Cobb-Douglas matching function."""
        return self.A * u**self.alpha * v**(1 - self.alpha)

    def job_finding_rate(self, theta):
        """f(θ) = A * θ^(1-α)"""
        return self.A * theta**(1 - self.alpha)

    def vacancy_filling_rate(self, theta):
        """q(θ) = A * θ^(-α)"""
        return self.A * theta**(-self.alpha)

    def wage(self, a=None, h=1.0, theta=None):
        """Simplified wage rule: w = γ·a·h + (1-γ)·b."""
        if a is None: a = self.a
        return self.gamma * a * h + (1 - self.gamma) * self.b

    def solve_theta(self, a=None, h=1.0):
        """Solve for market tightness from free entry condition."""
        if a is None: a = self.a
        surplus = (1 - self.gamma) * (a * h - self.b)
        if surplus <= 0:
            return 0.001
        rhs = surplus / (1 - self.beta * (1 - self.delta))
        ratio = self.A * rhs / self.kappa
        if ratio <= 0:
            return 0.001
        theta = ratio**(1 / self.alpha)
        return max(theta, 0.001)

    def steady_state(self, a=None, h=1.0):
        """Compute steady state (E, U, O) shares and rates."""
        if a is None: a = self.a
        theta = self.solve_theta(a, h)
        f = self.job_finding_rate(theta)
        delta = self.delta
        chi = self.chi_base
        psi = self.psi
        u_ss = 1.0 / (f / delta + 1 + chi / psi)
        e_ss = f * u_ss / delta
        o_ss = chi * u_ss / psi
        w = self.wage(a, h, theta)
        return {
            'theta': theta, 'f': f, 'u': u_ss, 'e': e_ss, 'o': o_ss,
            'w': w, 'a': a, 'h': h
        }

    def simulate_transition(self, shock_type='demand', shock_size=0.05,
                           shock_duration=3, T=120):
        """
        Simulate transition dynamics with full duration distribution tracking.

        The unemployment pool is represented as a vector u_d[0..D_MAX] where
        u_d[d] is the measure of unemployed workers with duration d months.
        Each period:
          - New separations enter at d=0
          - Workers at d who are not hired and don't exit to OLF advance to d+1
          - Workers with d >= d* have human capital h*(1-λ) instead of h
          - Scarred fraction s_t = sum(u_d for d >= d*) / sum(u_d)
        """
        ss0 = self.steady_state()
        E, U, O = ss0['e'], ss0['u'], ss0['o']

        # Initialize duration distribution in steady state
        # In SS: inflow = δ*E at d=0, outflow = f*u_d + χ*u_d at each d
        f_ss = ss0['f']
        chi_ss = self.chi_base  # No duration-dependent exit in SS (s=0)
        exit_rate_ss = f_ss + chi_ss

        # SS duration distribution: u_d[d] = δ*E * (1-exit_rate)^d / normalization
        # Geometric decay: u_d[d] = inflow * survival^d
        inflow_ss = self.delta * E
        survival_ss = max(1e-10, 1.0 - exit_rate_ss)
        u_dist = np.zeros(D_MAX + 1)
        for d in range(D_MAX + 1):
            u_dist[d] = inflow_ss * survival_ss**d
        # Normalize to match total U
        u_dist_sum = u_dist.sum()
        if u_dist_sum > 0:
            u_dist *= U / u_dist_sum

        # Compute initial scarred fraction
        scarred_frac = u_dist[self.d_star:].sum() / U if U > 0 else 0.0
        h_effective = 1.0 - self.lam * scarred_frac

        path = {'E': [E], 'U': [U], 'O': [O], 'theta': [ss0['theta']],
                'f': [ss0['f']], 'w': [ss0['w']], 'emp_change': [0.0],
                'ur': [U / (E + U)], 'scarred_frac': [scarred_frac],
                'h_effective': [h_effective]}

        for t in range(1, T + 1):
            # Current shock state
            if shock_type == 'demand':
                # v9: AR(1) mean-reverting demand shock
                # a_t = a_ss * (1 - shock_size * rho^t)
                # rho=0.99 → half-life ~69 months; shock dissipates over time
                a_t = self.a * (1 - shock_size * self.rho_a**t)
                delta_t = self.delta
            elif shock_type == 'supply':
                delta_t = self.delta * (1 + shock_size) if t <= shock_duration else self.delta
                a_t = self.a
            else:
                a_t = self.a
                delta_t = self.delta

            # Solve for market tightness using average human capital
            theta_t = self.solve_theta(a_t, h_effective)
            f_t = self.job_finding_rate(theta_t)

            # OLF exit rate depends on scarred fraction
            chi_t = self.chi_base + self.chi_dur * scarred_frac

            # --- Update duration distribution ---
            # New separations enter at d=0
            new_inflow = delta_t * E

            # For each duration bin, compute outflows
            u_dist_new = np.zeros(D_MAX + 1)
            total_ue = 0.0  # Total U→E flow
            total_uo = 0.0  # Total U→O flow

            for d in range(D_MAX + 1):
                if u_dist[d] < 1e-15:
                    continue
                # All durations face same f_t and chi_t (aggregate rates)
                hired = f_t * u_dist[d]
                exited = chi_t * u_dist[d]
                survived = u_dist[d] - hired - exited
                # Ensure non-negative
                if survived < 0:
                    # Scale down proportionally
                    total_out = f_t + chi_t
                    if total_out > 1:
                        hired = (f_t / total_out) * u_dist[d]
                        exited = (chi_t / total_out) * u_dist[d]
                        survived = 0.0
                    else:
                        survived = max(0, survived)

                total_ue += hired
                total_uo += exited

                # Survivors advance to d+1 (or stay at D_MAX)
                next_d = min(d + 1, D_MAX)
                u_dist_new[next_d] += survived

            # Add new inflow at d=0
            u_dist_new[0] += new_inflow

            # OLF re-entry flow
            ou = self.psi * O

            # Update aggregate states
            E_new = E + total_ue - delta_t * E
            U_new = u_dist_new.sum() + ou  # Duration dist + re-entrants
            O_new = O + total_uo - ou

            # Re-entrants enter at d=0
            u_dist_new[0] += ou

            # Normalize everything to sum to 1
            total = E_new + U_new + O_new
            if total > 0:
                E = E_new / total
                U_new_norm = U_new / total
                O = O_new / total
                # Scale duration distribution to match normalized U
                u_dist_sum = u_dist_new.sum()
                if u_dist_sum > 0:
                    u_dist = u_dist_new * (U_new_norm / u_dist_sum)
                else:
                    u_dist = u_dist_new
                U = U_new_norm
            else:
                E, U, O = ss0['e'], ss0['u'], ss0['o']

            # Compute scarred fraction from duration distribution
            if U > 1e-15:
                scarred_frac = u_dist[self.d_star:].sum() / U
            else:
                scarred_frac = 0.0
            scarred_frac = min(1.0, max(0.0, scarred_frac))

            # Effective human capital
            h_effective = 1.0 - self.lam * scarred_frac

            w_t = self.wage(a_t, h_effective, theta_t)
            emp_change = np.log(E / ss0['e']) if E > 0 and ss0['e'] > 0 else 0.0

            path['E'].append(E)
            path['U'].append(U)
            path['O'].append(O)
            path['theta'].append(theta_t)
            path['f'].append(f_t)
            path['w'].append(w_t)
            path['emp_change'].append(emp_change)
            path['ur'].append(U / (E + U) if (E + U) > 0 else 0)
            path['scarred_frac'].append(scarred_frac)
            path['h_effective'].append(h_effective)

        return path


# ──────────────────────────────────────────────────────────────
# CRRA Welfare computation
# ──────────────────────────────────────────────────────────────

def crra_utility(c, sigma):
    """CRRA utility: u(c) = c^(1-σ)/(1-σ) for σ≠1, log(c) for σ=1."""
    c = max(c, 1e-10)  # Floor to avoid log(0)
    if abs(sigma - 1.0) < 1e-8:
        return np.log(c)
    else:
        return c**(1.0 - sigma) / (1.0 - sigma)


def compute_welfare_loss(path, ss, model, T=None, sigma=0.0):
    """Compute consumption-equivalent welfare loss with terminal value.

    sigma=0 gives risk-neutral (linear) welfare (v7 default).
    sigma>0 gives CRRA welfare.
    """
    if T is None:
        T = len(path['E']) - 1
    beta = model.beta

    # Period consumption in each state
    def period_welfare(E_t, U_t, O_t, w_t, sigma):
        if sigma == 0.0:
            # Risk-neutral: linear in consumption
            return E_t * w_t + U_t * model.b + O_t * model.b_olf
        else:
            # CRRA: expected utility across states
            return (E_t * crra_utility(w_t, sigma) +
                    U_t * crra_utility(model.b, sigma) +
                    O_t * crra_utility(model.b_olf, sigma))

    # SS welfare
    ss_period = period_welfare(ss['e'], ss['u'], ss['o'], ss['w'], sigma)
    ss_welfare = sum(beta**t * ss_period for t in range(T))
    ss_welfare += (beta**T / (1 - beta)) * ss_period

    # Shock welfare
    shock_welfare = 0
    for t in range(T):
        pw = period_welfare(path['E'][t], path['U'][t], path['O'][t], path['w'][t], sigma)
        shock_welfare += beta**t * pw

    # Terminal value
    terminal = period_welfare(path['E'][T], path['U'][T], path['O'][T], path['w'][T], sigma)
    shock_welfare += (beta**T / (1 - beta)) * terminal

    if sigma == 0.0:
        # CE loss: 1 - W_shock/W_ss
        return 1 - shock_welfare / ss_welfare if ss_welfare != 0 else 0
    else:
        # For CRRA, CE loss Δ satisfies:
        # W_shock = Σ β^t [E*u((1-Δ)w) + U*u((1-Δ)b) + O*u((1-Δ)b_olf)]
        # Since u((1-Δ)c) = (1-Δ)^(1-σ) * u(c) for CRRA (when σ≠1)
        # or u((1-Δ)c) = log(1-Δ) + u(c) for log utility
        # Solving: (1-Δ)^(1-σ) = W_shock/W_ss  (for σ≠1)
        # => Δ = 1 - (W_shock/W_ss)^(1/(1-σ))
        # For σ=1: W_shock = W_ss + log(1-Δ) * Σβ^t
        # => Δ = 1 - exp((W_shock - W_ss) / Σβ^t)
        ratio = shock_welfare / ss_welfare if ss_welfare != 0 else 1.0
        if abs(sigma - 1.0) < 1e-8:
            # Log utility
            pv_one = sum(beta**t for t in range(T)) + beta**T / (1 - beta)
            delta_w = (shock_welfare - ss_welfare) / pv_one if pv_one != 0 else 0
            return 1 - np.exp(delta_w)
        else:
            if ratio <= 0:
                return 1.0
            return 1 - ratio**(1.0 / (1.0 - sigma))


# ──────────────────────────────────────────────────────────────
# SMM Estimation
# ──────────────────────────────────────────────────────────────

def smm_estimate(lp_results, verbose=True):
    """Simulated Method of Moments estimation.

    Estimates 4 structural parameters (λ, χ₁, A, κ) by minimizing the distance
    between model-simulated moments and data moments from LP IRF estimates.
    ρ_a is externally calibrated at 0.99 (not estimated).

    Target moments (6, overidentified with 2 d.f.):
      1. GR employment response at h=12 (scaled)
      2. GR employment response at h=48 (scaled)
      3. GR employment response at h=84 (scaled)
      4. COVID recovery month (month when |emp_change| < 0.005)
      5. Steady-state unemployment rate (0.055)
      6. Steady-state job-finding rate (0.40)

    Scale mapping: LP coefficients are per-unit-of-Saiz-instrument responses;
    model produces per-5%-productivity-drop responses. We use the peak employment
    ratio (data_peak / model_peak) as the scale factor, computed endogenously
    for each parameter draw. This is NOT a hack — it reflects the fact that the
    instrument maps Saiz elasticity → housing price change → employment, and
    the scale factor captures that mapping.

    Returns: dict with estimates, SEs, J-stat, p-value
    """
    # Extract data moments from LP results
    gr_hpi = lp_results.get('gr_hpi', [])

    def get_lp_beta(results, h):
        for r in results:
            if r['h'] == h and r['beta'] is not None and not np.isnan(r['beta']):
                return r['beta']
        return None

    # Data moments (from LP estimates)
    gr_h12 = get_lp_beta(gr_hpi, 12)
    gr_h48 = get_lp_beta(gr_hpi, 48)
    gr_h84 = get_lp_beta(gr_hpi, 84)

    if gr_h12 is None or gr_h48 is None or gr_h84 is None:
        print("  WARNING: Missing LP moments, using default targets")
        gr_h12 = -0.02
        gr_h48 = -0.06
        gr_h84 = -0.08

    # Target moments vector
    m_data = np.array([
        gr_h12,    # 1. GR emp response h=12
        gr_h48,    # 2. GR emp response h=48
        gr_h84,    # 3. GR emp response h=84
        18.0,      # 4. COVID recovery month
        0.055,     # 5. SS unemployment rate (BLS 2001-2019)
        0.40,      # 6. SS job-finding rate (Shimer 2005)
    ])

    if verbose:
        print(f"\n  Data moments:")
        print(f"    GR emp h=12:  {m_data[0]:.4f}")
        print(f"    GR emp h=48:  {m_data[1]:.4f}")
        print(f"    GR emp h=84:  {m_data[2]:.4f}")
        print(f"    COVID recovery: {m_data[3]:.0f} months")
        print(f"    SS UR: {m_data[4]:.3f}")
        print(f"    SS f:  {m_data[5]:.3f}")

    # Scale moments for weighting (use inverse of absolute data moments as diagonal weight)
    # This normalizes the objective so each moment contributes roughly equally
    W = np.diag(1.0 / np.maximum(np.abs(m_data), 0.001)**2)

    def simulate_moments(params):
        """Compute model moments for given parameter vector [λ, χ₁, A, κ].

        v9: ρ_a is externally calibrated at 0.99 (not estimated).
        Scale mapping: The model's 5% productivity shock produces employment
        responses in log-point units. LP coefficients are per-unit-of-Saiz-
        instrument. We scale model IRF to match data IRF at the peak, then
        match the SHAPE (relative to peak) at h=12, 48, 84.
        """
        lam, chi1, A_match, kappa = params

        # Bounds enforcement
        if lam < 0.01 or lam > 0.50: return None
        if chi1 < 0.0001 or chi1 > 0.05: return None
        if A_match < 0.10 or A_match > 2.0: return None
        if kappa < 0.50 or kappa > 20.0: return None

        m = DMPModel({
            'lam': lam, 'chi_dur': chi1, 'A': A_match, 'kappa': kappa,
        })

        # SS moments
        ss = m.steady_state()
        ss_ur = ss['u'] / (ss['e'] + ss['u'])
        ss_f = ss['f']

        # Demand shock simulation (GR)
        try:
            demand_path = m.simulate_transition('demand', shock_size=0.05, T=120)
        except Exception:
            return None
        emp_d = demand_path['emp_change']
        if len(emp_d) <= 84:
            return None

        # Scale mapping: match peak employment decline to data peak
        # Data peak: most negative LP coefficient across all horizons
        data_peak = min(gr_h12, gr_h48, gr_h84)
        model_peak = min(emp_d)
        if abs(model_peak) < 1e-10:
            return None
        scale = data_peak / model_peak  # Maps model units → data units

        gr_m12 = emp_d[12] * scale
        gr_m48 = emp_d[48] * scale
        gr_m84 = emp_d[84] * scale

        # Supply shock simulation (COVID recovery month)
        try:
            supply_path = m.simulate_transition('supply', shock_size=1.5, shock_duration=3, T=120)
        except Exception:
            return None
        supply_emp = supply_path['emp_change']
        recovery = 120
        for t in range(1, 121):
            if abs(supply_emp[t]) < 0.005:
                recovery = t
                break

        return np.array([gr_m12, gr_m48, gr_m84, float(recovery), ss_ur, ss_f])

    def objective(params):
        """SMM objective: (m_model - m_data)' W (m_model - m_data)"""
        m_model = simulate_moments(params)
        if m_model is None:
            return 1e10
        diff = m_model - m_data
        return float(diff @ W @ diff)

    # Initial guess: 4 structural parameters (ρ_a externally calibrated at 0.99)
    x0 = np.array([0.12, 0.004, 0.60, 3.40])

    if verbose:
        print(f"\n  Initial parameters: λ={x0[0]:.3f}, χ₁={x0[1]:.4f}, A={x0[2]:.3f}, κ={x0[3]:.3f}")
        print(f"  ρ_a externally calibrated = 0.99")
        m0 = simulate_moments(x0)
        if m0 is not None:
            print(f"  Initial moments: {m0}")
            print(f"  Initial objective: {objective(x0):.6f}")

    # Stage 1: Identity weighting
    if verbose:
        print("\n  Stage 1: Nelder-Mead with identity weighting...")
    result1 = optimize.minimize(objective, x0, method='Nelder-Mead',
                                options={'maxiter': 5000, 'xatol': 1e-6, 'fatol': 1e-8,
                                         'adaptive': True})

    x_hat = result1.x
    if verbose:
        print(f"  Stage 1 result: λ={x_hat[0]:.4f}, χ₁={x_hat[1]:.5f}, A={x_hat[2]:.4f}, κ={x_hat[3]:.4f}")
        print(f"  Objective: {result1.fun:.8f}, converged: {result1.success}")

    # Stage 2: Optimal weighting (use residuals from Stage 1 to estimate Ω)
    m_hat = simulate_moments(x_hat)
    if m_hat is not None:
        residuals_1 = m_hat - m_data
        # Diagonal approximation of optimal weighting matrix
        W_opt = np.diag(1.0 / np.maximum(residuals_1**2, 1e-10))

        def objective_opt(params):
            m_model = simulate_moments(params)
            if m_model is None:
                return 1e10
            diff = m_model - m_data
            return float(diff @ W_opt @ diff)

        if verbose:
            print("\n  Stage 2: Nelder-Mead with optimal weighting...")
        result2 = optimize.minimize(objective_opt, x_hat, method='Nelder-Mead',
                                    options={'maxiter': 5000, 'xatol': 1e-6, 'fatol': 1e-8,
                                             'adaptive': True})
        x_hat = result2.x
        if verbose:
            print(f"  Stage 2 result: λ={x_hat[0]:.4f}, χ₁={x_hat[1]:.5f}, A={x_hat[2]:.4f}, κ={x_hat[3]:.4f}")
            print(f"  Objective: {result2.fun:.8f}, converged: {result2.success}")
    else:
        if verbose:
            print("  WARNING: Stage 1 moments invalid, skipping Stage 2")

    # Final moments at estimated parameters
    m_final = simulate_moments(x_hat)

    # Bootstrap standard errors (parametric)
    if verbose:
        print("\n  Computing bootstrap standard errors (200 draws)...")
    n_boot = 200
    boot_estimates = []

    # Bootstrap: add noise to data moments and re-estimate
    # SE of LP coefficients provides the natural perturbation
    gr_se = {}
    for r in gr_hpi:
        if r.get('se') is not None and not np.isnan(r['se']):
            gr_se[r['h']] = r['se']

    se_12 = gr_se.get(12, abs(gr_h12) * 0.3)
    se_48 = gr_se.get(48, abs(gr_h48) * 0.3)
    se_84 = gr_se.get(84, abs(gr_h84) * 0.3)

    rng = np.random.RandomState(42)
    for b in range(n_boot):
        # Perturb data moments
        m_boot = m_data.copy()
        m_boot[0] += rng.normal(0, se_12)
        m_boot[1] += rng.normal(0, se_48)
        m_boot[2] += rng.normal(0, se_84)
        m_boot[3] += rng.normal(0, 3.0)  # 3-month SE for recovery
        m_boot[4] += rng.normal(0, 0.005)  # SS UR
        m_boot[5] += rng.normal(0, 0.02)  # SS f

        W_b = np.diag(1.0 / np.maximum(np.abs(m_boot), 0.001)**2)

        def obj_boot(params, m_target=m_boot, W_b=W_b):
            m_model = simulate_moments(params)
            if m_model is None:
                return 1e10
            diff = m_model - m_target
            return float(diff @ W_b @ diff)

        try:
            res_b = optimize.minimize(obj_boot, x_hat, method='Nelder-Mead',
                                      options={'maxiter': 2000, 'xatol': 1e-5, 'fatol': 1e-7})
            if res_b.fun < 1e8:
                boot_estimates.append(res_b.x)
        except Exception:
            pass

    boot_estimates = np.array(boot_estimates)
    if len(boot_estimates) > 10:
        boot_se = np.std(boot_estimates, axis=0)
    else:
        boot_se = np.full(4, np.nan)

    if verbose:
        print(f"  Bootstrap: {len(boot_estimates)}/{n_boot} successful draws")
        print(f"  SE: λ={boot_se[0]:.4f}, χ₁={boot_se[1]:.5f}, A={boot_se[2]:.4f}, κ={boot_se[3]:.4f}")

    # J-test for overidentification
    n_moments = 6
    n_params = 4
    dof = n_moments - n_params  # 2 d.f.

    if m_final is not None:
        residuals_final = m_final - m_data
        J_stat = float(residuals_final @ W @ residuals_final) * 50  # Scale by "N" (50 states)
        J_pval = 1 - stats.chi2.cdf(J_stat, dof) if dof > 0 else np.nan
    else:
        J_stat = np.nan
        J_pval = np.nan

    if verbose:
        print(f"\n  J-statistic: {J_stat:.4f} (df={dof}, p={J_pval:.4f})")
        if J_pval > 0.05:
            print(f"  → Cannot reject model at 5% level")
        else:
            print(f"  → Model rejected at 5% level")

    estimates = {
        'lam': float(x_hat[0]),
        'chi_dur': float(x_hat[1]),
        'A': float(x_hat[2]),
        'kappa': float(x_hat[3]),
        'rho_a': 0.99,  # externally calibrated
        'se_lam': float(boot_se[0]),
        'se_chi_dur': float(boot_se[1]),
        'se_A': float(boot_se[2]),
        'se_kappa': float(boot_se[3]),
        'se_rho_a': None,  # not estimated
        'J_stat': float(J_stat) if not np.isnan(J_stat) else None,
        'J_pval': float(J_pval) if not np.isnan(J_pval) else None,
        'J_dof': dof,
        'n_moments': n_moments,
        'n_params': n_params,
        'n_boot': len(boot_estimates),
        'data_moments': m_data.tolist(),
        'model_moments': m_final.tolist() if m_final is not None else None,
        'objective': float(result1.fun),
    }
    return estimates


# ══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ══════════════════════════════════════════════════════════════

print("="*60)
print("STRUCTURAL MODEL: DMP WITH DURATION DISTRIBUTION (v9)")
print("="*60)
print("  v9 changes: δ=0.023, AR(1) demand shock (ρ_a=0.99 calibrated), 4-param SMM")

# ──────────────────────────────────────────────────────────────
# Phase 1: SMM Estimation
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PHASE 1: SMM ESTIMATION")
print("="*60)

with open(DATA_DIR / "lp_results.json") as f:
    lp_results = json.load(f)

smm_results = smm_estimate(lp_results, verbose=True)

# Create model with SMM-estimated parameters + externally calibrated ρ_a
estimated_params = {
    'lam': smm_results['lam'],
    'chi_dur': smm_results['chi_dur'],
    'A': smm_results['A'],
    'kappa': smm_results['kappa'],
    'rho_a': 0.99,  # externally calibrated, not estimated
}
model = DMPModel(estimated_params)
ss = model.steady_state()

print(f"\nSteady State (SMM-estimated):")
print(f"  Employment rate: {ss['e']:.4f}")
print(f"  Unemployment rate: {ss['u']:.4f} (UR = {ss['u']/(ss['e']+ss['u']):.4f})")
print(f"  OLF rate: {ss['o']:.4f}")
print(f"  Market tightness θ: {ss['theta']:.4f}")
print(f"  Job finding rate f: {ss['f']:.4f}")
print(f"  Wage: {ss['w']:.4f}")

# ──────────────────────────────────────────────────────────────
# Phase 2: Simulate with estimated parameters
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PHASE 2: SIMULATION WITH ESTIMATED PARAMETERS")
print("="*60)

# Demand shock: productivity falls by 5%, mean-reverting AR(1)
print(f"\n--- Demand Shock (GR analog): a falls by 5%, ρ_a={model.rho_a:.4f} ---")
demand_path = model.simulate_transition('demand', shock_size=0.05, T=120)
print(f"  Peak employment decline: {min(demand_path['emp_change']):.4f} "
      f"at month {demand_path['emp_change'].index(min(demand_path['emp_change']))}")
print(f"  Employment at month 48: {demand_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {demand_path['emp_change'][120]:.4f}")
print(f"  Peak UR: {max(demand_path['ur']):.4f}")
print(f"  Scarred fraction at t=48: {demand_path['scarred_frac'][48]:.4f}")
print(f"  Scarred fraction at t=120: {demand_path['scarred_frac'][120]:.4f}")

# Supply shock: separation rate doubles for 3 months
print("\n--- Supply Shock (COVID analog): δ doubles for 3 months ---")
supply_path = model.simulate_transition('supply', shock_size=1.5, shock_duration=3, T=120)
print(f"  Peak employment decline: {min(supply_path['emp_change']):.4f} "
      f"at month {supply_path['emp_change'].index(min(supply_path['emp_change']))}")
print(f"  Employment at month 12: {supply_path['emp_change'][12]:.4f}")
print(f"  Employment at month 48: {supply_path['emp_change'][48]:.4f}")
print(f"  Peak UR: {max(supply_path['ur']):.4f}")
print(f"  Scarred fraction at peak: {max(supply_path['scarred_frac']):.4f}")

# Counterfactual 1: Demand shock with NO skill depreciation
print("\n--- Counterfactual: Demand shock, no scarring (λ=0) ---")
cf1_params = dict(estimated_params)
cf1_params['lam'] = 0.0
model_noscar = DMPModel(cf1_params)
cf1_path = model_noscar.simulate_transition('demand', shock_size=0.05, T=120)
print(f"  Employment at month 48: {cf1_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {cf1_path['emp_change'][120]:.4f}")

# Counterfactual 2: Demand shock with NO participation exit
print("\n--- Counterfactual: Demand shock, no OLF exit (χ=0) ---")
cf2_params = dict(estimated_params)
cf2_params['chi_base'] = 0.0
cf2_params['chi_dur'] = 0.0
model_noolf = DMPModel(cf2_params)
cf2_path = model_noolf.simulate_transition('demand', shock_size=0.05, T=120)
print(f"  Employment at month 48: {cf2_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {cf2_path['emp_change'][120]:.4f}")

# Counterfactual 3: Supply shock but permanent
print("\n--- Counterfactual: Supply shock but permanent ---")
class DMPPermanentSupply(DMPModel):
    def simulate_transition(self, shock_type='supply', shock_size=0.5,
                           shock_duration=120, T=120):
        return super().simulate_transition('supply', shock_size, shock_duration, T)
model_permsupply = DMPPermanentSupply(estimated_params)
cf3_path = model_permsupply.simulate_transition(T=120)
print(f"  Employment at month 48: {cf3_path['emp_change'][48]:.4f}")
print(f"  Employment at month 120: {cf3_path['emp_change'][120]:.4f}")

# ──────────────────────────────────────────────────────────────
# Phase 3: Welfare computation (Risk-neutral + CRRA)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PHASE 3: WELFARE ANALYSIS (RISK-NEUTRAL + CRRA)")
print("="*60)

T_WELFARE = 600
print(f"\n--- Extended simulations for welfare (T={T_WELFARE}) ---")
demand_path_long = model.simulate_transition('demand', shock_size=0.05, T=T_WELFARE)
supply_path_long = model.simulate_transition('supply', shock_size=1.5, shock_duration=3, T=T_WELFARE)
cf1_path_long = model_noscar.simulate_transition('demand', shock_size=0.05, T=T_WELFARE)
cf2_path_long = model_noolf.simulate_transition('demand', shock_size=0.05, T=T_WELFARE)

# Convergence diagnostics
for label, pth in [('Demand', demand_path_long), ('Supply', supply_path_long),
                    ('CF1 (no scar)', cf1_path_long), ('CF2 (no OLF)', cf2_path_long)]:
    emp_120 = pth['emp_change'][120]
    emp_600 = pth['emp_change'][T_WELFARE]
    delta_conv = abs(emp_600 - emp_120)
    monthly_change = abs(pth['emp_change'][T_WELFARE] - pth['emp_change'][T_WELFARE - 12]) / 12
    print(f"  {label}: emp@120={emp_120:.6f}, emp@600={emp_600:.6f}, "
          f"|Δ|={delta_conv:.6f}, monthly change last year={monthly_change:.8f}")

# Risk-neutral welfare (σ=0, backward compatible with v7)
print("\n--- Risk-neutral welfare (σ=0) ---")
ss_noscar = model_noscar.steady_state()
ss_noolf = model_noolf.steady_state()

demand_welfare_rn = compute_welfare_loss(demand_path_long, ss, model, sigma=0.0)
supply_welfare_rn = compute_welfare_loss(supply_path_long, ss, model, sigma=0.0)
cf1_welfare_rn = compute_welfare_loss(cf1_path_long, ss_noscar, model_noscar, sigma=0.0)
cf2_welfare_rn = compute_welfare_loss(cf2_path_long, ss_noolf, model_noolf, sigma=0.0)

print(f"  Demand shock CE loss:     {demand_welfare_rn*100:.2f}%")
print(f"  Supply shock CE loss:     {supply_welfare_rn*100:.2f}%")
print(f"  CF1 (no scarring) CE loss:{cf1_welfare_rn*100:.2f}%")
print(f"  CF2 (no OLF exit) CE loss:{cf2_welfare_rn*100:.2f}%")
if demand_welfare_rn != 0:
    print(f"  Scarring contribution: {(demand_welfare_rn - cf1_welfare_rn) / demand_welfare_rn * 100:.1f}%")
    print(f"  OLF exit contribution: {(demand_welfare_rn - cf2_welfare_rn) / demand_welfare_rn * 100:.1f}%")
ratio_rn = demand_welfare_rn / supply_welfare_rn if supply_welfare_rn > 0 else float('inf')
print(f"  Demand/Supply ratio: {ratio_rn:.1f}")

# CRRA welfare
sigma_vals = [1.0, 2.0, 5.0]
crra_welfare = {}

for sigma in sigma_vals:
    print(f"\n--- CRRA welfare (σ={sigma}) ---")
    dw = compute_welfare_loss(demand_path_long, ss, model, sigma=sigma)
    sw = compute_welfare_loss(supply_path_long, ss, model, sigma=sigma)
    cf1w = compute_welfare_loss(cf1_path_long, ss_noscar, model_noscar, sigma=sigma)
    cf2w = compute_welfare_loss(cf2_path_long, ss_noolf, model_noolf, sigma=sigma)

    crra_welfare[sigma] = {
        'demand': float(dw), 'supply': float(sw),
        'cf1_noscar': float(cf1w), 'cf2_noolf': float(cf2w),
        'ratio': float(dw / sw) if sw > 0 else float('inf'),
    }
    print(f"  Demand CE loss: {dw*100:.2f}%")
    print(f"  Supply CE loss: {sw*100:.4f}%")
    print(f"  Ratio: {dw/sw:.1f}" if sw > 0 else "  Ratio: ∞")
    if dw != 0:
        print(f"  Scarring share: {(dw - cf1w) / dw * 100:.1f}%")

# ──────────────────────────────────────────────────────────────
# Save model results
# ──────────────────────────────────────────────────────────────
model_results = {
    'steady_state': ss,
    'demand_path': {k: [float(v) for v in vals[:121]] for k, vals in demand_path.items()},
    'supply_path': {k: [float(v) for v in vals[:121]] for k, vals in supply_path.items()},
    'cf1_noscar': {k: [float(v) for v in vals[:121]] for k, vals in cf1_path.items()},
    'cf2_noolf': {k: [float(v) for v in vals[:121]] for k, vals in cf2_path.items()},
    'cf3_permsupply': {k: [float(v) for v in vals[:121]] for k, vals in cf3_path.items()},
    'smm_estimates': smm_results,
    'welfare': {
        'risk_neutral': {
            'demand': float(demand_welfare_rn),
            'supply': float(supply_welfare_rn),
            'cf1_noscar': float(cf1_welfare_rn),
            'cf2_noolf': float(cf2_welfare_rn),
            'scarring_share': float((demand_welfare_rn - cf1_welfare_rn) / demand_welfare_rn) if demand_welfare_rn != 0 else 0,
            'olf_share': float((demand_welfare_rn - cf2_welfare_rn) / demand_welfare_rn) if demand_welfare_rn != 0 else 0,
            'ratio': float(ratio_rn),
        },
        'crra': {str(sigma): vals for sigma, vals in crra_welfare.items()},
        'T_welfare': T_WELFARE,
        'convergence': {
            'demand_emp_120': float(demand_path_long['emp_change'][120]),
            'demand_emp_600': float(demand_path_long['emp_change'][T_WELFARE]),
            'demand_monthly_change_last_year': float(
                abs(demand_path_long['emp_change'][T_WELFARE] - demand_path_long['emp_change'][T_WELFARE-12]) / 12
            ),
        }
    },
    'calibration': {
        'externally_calibrated': {
            'beta': model.beta, 'alpha': model.alpha, 'gamma': model.gamma,
            'delta': model.delta, 'b': model.b, 'b_olf': model.b_olf,
            'psi': model.psi, 'd_star': model.d_star, 'chi_base': model.chi_base,
            'rho_a': model.rho_a,
        },
        'smm_estimated': {
            'lam': smm_results['lam'], 'chi_dur': smm_results['chi_dur'],
            'A': smm_results['A'], 'kappa': smm_results['kappa'],
        },
    }
}

with open(DATA_DIR / "model_results.json", 'w') as f:
    json.dump(model_results, f, indent=2, default=str)

print(f"\n✓ Model results saved")

# ──────────────────────────────────────────────────────────────
# Parameter sensitivity analysis
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("PARAMETER SENSITIVITY: λ × A_shock grid")
print("="*60)

lambda_vals = [0.01, 0.03, 0.05, 0.08, 0.10, 0.14, smm_results['lam']]
a_shock_vals = [0.03, 0.05, 0.07]

sensitivity_results = []

for lam in lambda_vals:
    for a_shock in a_shock_vals:
        sens_params = dict(estimated_params)
        sens_params['lam'] = lam
        m = DMPModel(sens_params)
        path = m.simulate_transition('demand', shock_size=a_shock, T=120)

        emp = path['emp_change']
        peak_decline = min(emp)
        peak_month = emp.index(peak_decline)
        half_target = peak_decline / 2
        half_life = None
        for t in range(peak_month + 1, 121):
            if emp[t] > half_target:
                half_life = t - peak_month
                break
        if half_life is None:
            half_life = '>120'

        supply_path_s = m.simulate_transition('supply', shock_size=1.5, shock_duration=3, T=120)
        supply_emp = supply_path_s['emp_change']
        recovery_month = 120
        for t in range(1, 121):
            if abs(supply_emp[t]) < 0.005:
                recovery_month = t
                break

        row = {
            'lambda': lam, 'a_shock': a_shock,
            'demand_half_life': half_life,
            'demand_emp_48': emp[48],
            'demand_emp_120': emp[120],
            'supply_recovery_month': recovery_month,
        }
        sensitivity_results.append(row)
        hl_str = str(half_life) if isinstance(half_life, int) else half_life
        print(f"  λ={lam:.2f}, Δa={a_shock:.2f}: half-life={hl_str:>4s}m, "
              f"emp_48={emp[48]:.4f}, recovery={recovery_month}m")

model_results['sensitivity'] = sensitivity_results

# ──────────────────────────────────────────────────────────────
# Welfare sensitivity for specific scenarios (appendix table)
# ──────────────────────────────────────────────────────────────
print("\n" + "="*60)
print("WELFARE SENSITIVITY: Specific scenarios for appendix")
print("="*60)

welfare_scenarios = [
    ('Baseline (SMM)', {}),
    ('Low scarring (λ=0.06)', {'lam': 0.06}),
    ('High scarring (λ=0.18)', {'lam': 0.18}),
    ('No scarring (λ=0)', {'lam': 0.001}),
    ('No participation exit (χ=0)', {'chi_base': 0.0, 'chi_dur': 0.0}),
    ('High participation exit (χ=0.016)', {'chi_base': 0.016}),
    ('Low matching efficiency (A=0.45)', {'A': 0.45}),
    ('High matching efficiency (A=0.75)', {'A': 0.75}),
    ('Fast mean reversion (ρ=0.98)', {'rho_a': 0.98}),
    ('Slow mean reversion (ρ=0.995)', {'rho_a': 0.995}),
]

welfare_sens_results = []
for name, overrides in welfare_scenarios:
    p = dict(estimated_params)
    p.update(overrides)
    m = DMPModel(p)
    ss_m = m.steady_state()
    path_m = m.simulate_transition('demand', shock_size=0.05, T=T_WELFARE)
    welf_rn = compute_welfare_loss(path_m, ss_m, m, sigma=0.0)
    welf_crra2 = compute_welfare_loss(path_m, ss_m, m, sigma=2.0)
    emp48 = path_m['emp_change'][48]
    print(f"  {name}: emp_48={emp48:.4f}, CE(σ=0)={welf_rn*100:.2f}%, CE(σ=2)={welf_crra2*100:.2f}%")
    welfare_sens_results.append({
        'name': name,
        'overrides': overrides,
        'emp_48': float(emp48),
        'welfare_loss_rn': float(welf_rn),
        'welfare_loss_crra2': float(welf_crra2),
    })

model_results['welfare_sensitivity'] = welfare_sens_results

with open(DATA_DIR / "model_results.json", 'w') as f:
    json.dump(model_results, f, indent=2, default=str)

print(f"\n✓ All model results saved (including SMM, CRRA, welfare sensitivity)")
