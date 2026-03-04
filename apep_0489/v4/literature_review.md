# Early Literature Review (Revision)

## Top Idea: DiD-Transformer — Distributional Treatment Effects on Career Trajectories (Revised apep_0489)

### Related Human Papers

1. **Kline & Moretti (2014)** — "Local Economic Development, Agglomeration Economies, and the Big Push: 100 Years of Evidence from the Tennessee Valley Authority." *QJE* 129(1):275-331.
   - **Overlap:** Uses same TVA setting, county-level DiD
   - **Delta:** K&M estimate scalar ATEs on county-level aggregates. We recover full distributional effects on individual career transitions using transformer representations.

2. **Vafa, Athey & Blei (2022)** — "CAREER: A Foundation Language Model for Labor Sequences."
   - **Overlap:** Same career transformer architecture (two-stage head, occupation sequences)
   - **Delta:** CAREER is a predictive model with no causal identification. We embed DiD into the fine-tuning process via four-adapter LoRA with temporal masking.

3. **Ilharco et al. (2023)** — "Editing Models with Task Arithmetic." *ICLR*.
   - **Overlap:** Uses task vector arithmetic on model weights
   - **Delta:** Ilharco et al. edit model behavior (add/remove capabilities). We use weight-space arithmetic for causal inference — the double-difference of task vectors identifies treatment effects.

4. **Callaway & Sant'Anna (2021)** — "Difference-in-Differences with Multiple Time Periods." *JoE* 225(2):200-230.
   - **Overlap:** Modern DiD methodology
   - **Delta:** CS-DiD operates on scalar outcomes. Our framework extends DiD to distributional objects (transition matrices) by working in representation space.

5. **Athey & Imbens (2019)** — "Machine Learning Methods That Economists Should Know About." *ARE* 11:685-725.
   - **Overlap:** ML + econometrics intersection
   - **Delta:** A&I survey prediction-focused ML methods (LASSO, random forests, neural nets for heterogeneous effects). Our contribution is a deep learning architecture specifically designed for causal identification, not prediction.

6. **Bender & Friedman (2021)** — "On the Dangers of Stochastic Parrots: Can Language Models Be Too Big?" *FAccT*.
   - **Overlap:** Representation learning in large models
   - **Delta:** We address concerns about interpretability by grounding learned representations in economic outcomes and causal effects.

### Revision Improvements

This revision strengthens the literature positioning by:
- **Deepening the parallel trends argument:** Clearer exposition of what parallel trends means in representation space (learned representations of career transitions would evolve identically absent treatment)
- **Connecting to structural labor economics:** Heterogeneity by occupation and initial conditions ties back to career choice models (Keane & Wolpin, Arcidiacono)
- **Emphasizing distributional innovation:** Highlights why recovering full transition matrices (vs. scalar ATEs) matters for understanding policy incidence

### Overlap Risk: **Low**

No existing paper combines transformer representation learning with difference-in-differences identification. The closest work (CAREER) lacks causal identification, and the closest causal work (K&M 2014) uses standard econometric methods on aggregates. The paper sits at a genuine intersection that hasn't been explored.

### Delta Statement (Revised)

This paper contributes the first framework that embeds difference-in-differences identification directly into transformer fine-tuning. By training separate LoRA adapters on each cell of the 2×2 design and taking double-differences in weight space, we recover the full distributional treatment effect on career transition matrices — an object that standard DiD fundamentally cannot identify. The SVD decomposition of the weight-space DiD additionally reveals the dimensionality and structure of treatment effects, providing a new diagnostic tool for applied researchers. This revision clarifies the parallel trends assumption in representation space and deepens the connection to structural labor economics, positioning the method as a contribution to both econometric methodology and substantive policy analysis.

### Status: PASS
