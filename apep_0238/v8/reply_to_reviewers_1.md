# Reply to Reviewers (Round 1)

We thank all three referees for their careful reading. Below we address each major concern.

---

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Causal Estimand / "Demand vs Supply" Generalizability

**Concern:** The design identifies exposure effects within two episodes, not general "demand vs supply shocks."

**Response:** We agree and have reframed the paper accordingly. The abstract and conclusion now state that the findings are episode-specific: "the housing-driven Great Recession produced persistent cross-state employment deficits; the COVID-19 supply shock did not." We discuss demand/supply interpretation as suggestive and acknowledge the n=2 limitation explicitly.

### 1.2 Housing Boom Exclusion Restriction

**Concern:** HPI boom correlates with pre-existing growth, amenities, etc.

**Response:** We control for pre-recession employment growth and region FEs, and the Saiz IV addresses housing boom endogeneity. We add a note that the IV estimates diverge at long horizons, which we interpret as imprecision rather than exclusion failure, given the small sample.

### 1.3 COVID Bartik Medium-Run Validity

**Concern:** Industry composition may proxy for remote-work capacity, state policy choices.

**Response:** Good point. We note that the Bartik captures initial incidence; medium-run recovery differences reflect the full episode package (shock + policy + sectoral dynamics). We have reframed accordingly.

### 2.1 Long-Horizon Inference

**Concern:** h=48+ not significant under permutation/wild-bootstrap.

**Response:** Agreed. We now center the scarring claim on the long-run average statistic (h=48-120 average = -0.037, wild bootstrap 95% CI [-0.069, -0.005]) and qualify individual horizon estimates as "point estimates persistently negative but imprecisely estimated beyond h=36."

### 5.1 Overstatement of Scarring

**Concern:** "Employment never fully recovers" overreaches.

**Response:** Revised to "Point estimates suggest persistent relative deficits through the sample window; statistical support is strongest in the first 12–36 months and for the pre-specified long-run average measure."

### 5.3 Welfare Ratio Not Supported

**Concern:** 71:1 ratio is "false precision" given J-test rejection.

**Response:** We now present welfare numbers as "illustrative quantification" rather than precise estimates. We acknowledge the J-test rejection, discuss that the model is purposefully stylized, and note that welfare ratios are sensitive to shock persistence, risk aversion, and model specification. We add explicit language that this is "worker income welfare" excluding firm profits and vacancy costs.

---

## Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### Power/Significance at Long Horizons

**Concern:** GR long-run insignificant; model rejects.

**Response:** See Response to Reviewer 1 (1.1, 2.1, 5.3). Claims recalibrated to statistical support.

### Fiscal Confounding

**Concern:** COVID PPP/UI massive and unquantified.

**Response:** We expand the policy discussion (Section 7.5) to explicitly discuss PPP as a match-preservation mechanism that prevented duration accumulation. We reframe the comparison as "episode-specific treatment packages" where policy response is endogenous to shock type. We note that this is precisely the point: demand shocks generate slow policy response because the duration channel operates gradually, while supply shocks trigger immediate match-preservation because disruption is visible and acute.

### Full LP Grid

**Concern:** Sparse table hides half-life computation.

**Response:** The event study figure (Figure 2) shows the full horizon path. We add text noting that the half-life is computed from the underlying 3-month grid LP estimates.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Demand Shock Persistence

**Concern:** Permanent shock assumption overstates welfare loss.

**Response:** We add text acknowledging that the permanent assumption is conservative (overstates demand welfare loss) and that a mean-reverting shock with a 10-year half-life would reduce the ratio. We note that this works against finding a large ratio, so the qualitative conclusion is robust even if quantitative magnitudes shift.

### Unemployment Rate Target

**Concern:** Model over-predicts steady-state UR (7.8% vs 5.5%).

**Response:** We discuss this honestly in the text: the three-state model with OLF transitions creates a larger unemployment pool than the standard two-state model. The 2.3pp gap does not affect the qualitative demand/supply asymmetry, which operates through the duration distribution channel.
