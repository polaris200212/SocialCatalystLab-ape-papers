# Reply to Reviewers — apep_0238 v9

## Reply to Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Causal estimand and headline claims
We agree the design identifies episode-specific exposure-response relationships, not a general causal law. The introduction already states: "This is fundamentally a comparative case study of two episodes, not a general statement about all demand and supply recessions." We have further softened the abstract to avoid suggesting general causality. The title's subtitle ("Evidence from State Labor Markets") already qualifies the scope.

### 2. Inference / multiple testing for persistence
We now lead with the pre-specified long-run average π_LR = -0.037 (CI: [-0.069, -0.005]) as the primary persistence test, both in the abstract and introduction. Individual horizon significance is framed as exploratory. The Romano-Wolf null results are reported honestly throughout.

### 3. GR identification and OLS vs IV divergence
We corrected the text to state IV is comparable to OLS through h=24, with explicit acknowledgment of attenuation at h=48. Adding balance tests and richer controls is noted as a valuable direction for future work but is beyond the scope of this text revision.

### 4. Shift-share inference with few shocks
We acknowledge the J=10 limitation is real. The AKM SEs are reported alongside HC1 and permutation inference precisely to provide multiple perspectives. We agree a primary design-based strategy should be designated more clearly.

### 5. Structural welfare precision
The abstract now reports a 7-18:1 range. The welfare section explicitly notes J-test rejection and ρ_a sensitivity. The conclusion uses range framing. Bold formatting removed from point estimate.

### 6-10. High-value and optional improvements
Noted for future revision. Common-scale exposure comparison, state-level duration measures, policy-response heterogeneity, and additional recessions would each strengthen the paper and are prioritized for a subsequent version.

---

## Reply to Reviewer 2 (Grok-4.1-Fast): MAJOR REVISION

### 1. Power / pre-specification
π_LR is now the lead statistic in the abstract and introduction, clearly designated as pre-specified. Bayesian augmentation and synthetic controls are noted as potential power improvements for future work.

### 2. Fiscal confounding
Section 7.5 provides extensive discussion of fiscal endogeneity. We agree that directly separating fiscal effects (using state-level PPP/ARRA data as controls) would strengthen the paper and prioritize this for future work.

### 3. Model J-test rejection
The welfare section now presents the 7-18:1 range explicitly, notes the J-test rejection, and frames all welfare numbers as illustrative rather than precise. Adding a permanent shock component or re-estimating without h=84 are noted as valuable extensions.

### 4. External validity (2 episodes)
The conclusion acknowledges this limitation and suggests extending to 2001 and 1981-82 recessions. This is prioritized for future work.

---

## Reply to Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Bartik pre-period balance
We agree formal balance checks on industry shares would strengthen identification. Noted for future work.

### 2. Long-term IV precision
Fixed: text now correctly states IV is informative for medium term (h ≤ 24) with explicit acknowledgment of attenuation at h=48.

### 3. Mixed-shock discussion
Section 2.3 discusses the Guerrieri et al. (2022) Keynesian supply shock possibility. The rapid COVID recovery suggests this channel was empirically muted for employment.

### 4. State-level fiscal controls
Section 7.5 discusses why conditioning on fiscal support introduces post-treatment bias. The ITT interpretation is maintained. Predicted fiscal transfers as a robustness check is noted for future work.
