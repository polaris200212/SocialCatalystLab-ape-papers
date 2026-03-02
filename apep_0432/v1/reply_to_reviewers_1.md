# Reply to Reviewers — apep_0432 v1 (Stage C Revision)

## Response to Theory Review (GPT-5.2-pro)

### CRITICAL #1: Comparative static ∂h_f/∂(w_m−w_f) < 0 is wrong
**Response:** Agreed. The original single-child model could not generate this comparative static — under standard concavity, ∂h_f/∂w_m > 0 (education is a normal good). We have completely rewritten the conceptual framework (Section 3) to include:
- Two children (h_m and h_f) with joint budget constraint p_h(h_m + h_f) ≤ B
- A return technology R(h, r_v) mapping education and road connectivity to earnings
- An **opportunity cost** term ω_v · t(h_m + h_f) representing the shadow price of children's school time

The new model generates the correct prediction: when roads raise the opportunity cost of children's time (through increased market wages for child-age labor), BOTH h_m and h_f decline, with effects concentrated where baseline educational access is weakest.

### CRITICAL #2: Model lacks boys' choice and return technology
**Response:** Addressed in the same rewrite. The two-child model with return technology now explicitly allows differential investment across children and generates predictions about both male and female human capital.

### WARNING #3: L_f binary without decision rule
**Response:** Added indirect utility comparison V(1) ≥ V(0) with explicit conditions on s(1) > s(0) for the seclusion channel.

### WARNING #4: Missing curvature assumptions
**Response:** Added standard assumptions: u' > 0, u'' < 0 for all utility and production functions.

### WARNING #5: Continuity assumption incomplete
**Response:** Equation (2) now states continuity for BOTH potential outcomes Y(0) and Y(1) as equations (2a) and (2b), with citation to Hahn, Todd, and Van der Klaauw (2001).

### WARNING #6: RDD specification uses common f(·) not piecewise
**Response:** Equation (3) now uses piecewise polynomials: f_-(X_i − 500)·(1−D_i) + f_+(X_i − 500)·D_i, consistent with the rdrobust estimator.

### WARNING #7: McCrary misuse
**Response:** Removed the claim that McCrary "implies" no population growth. Now correctly states it tests baseline density manipulation only.

### NOTE #8: Redundant Non-Worker outcome
**Response:** Dropped "Chg F Non-Worker" from all tables as mechanically redundant (= −1 × Female WPR).

### NOTE #9: Gender gap identity across bandwidths
**Response:** Added note in table explaining that different MSE-optimal bandwidths across outcomes prevent exact add-up.

---

## Response to GPT-5.2 Referee (MAJOR REVISION)

### First-stage on road connectivity
**Response:** We acknowledge this as a limitation and discuss it transparently. The ITT framework is maintained as primary, following Asher and Novosad (2020). PMGSY administrative data matching at the village level is beyond our current data scope but is noted as an avenue for future work.

### Multiple testing
**Response:** Added Benjamini-Hochberg q-values within outcome families. Employment outcomes: all q > 0.90 (null confirmed). Human capital: male literacy q = 0.084 (marginally survives), female literacy q = 0.327. Added dedicated subsection discussing multiple testing.

### Mechanism claims exceed evidence
**Response:** Substantially tempered. The discussion now frames results as "eligibility-induced changes at the margin" and leads with the opportunity cost mechanism (Shah & Steinberg 2017) rather than a strong "roads raised returns" claim. The null nightlights and EC outcomes are acknowledged as evidence of modest aggregate effects.

### 250-threshold non-replication
**Response:** Already discussed in robustness section. Added further context on differences in treatment intensity and population composition.

### Missing RDD references
**Response:** Added Imbens & Lemieux (2008), Hahn et al. (2001), Calonico et al. (2015).

### 95% CIs
**Response:** Added CI column to Table 2.

### Male literacy
**Response:** Added as a major new analysis. Pooled male literacy declines -0.0032 (p = 0.021). Parametric: eligible×ST on male literacy = -0.0105 (p < 0.001). This fundamentally changed the mechanism from "reallocation toward sons" to "general educational disruption."

---

## Response to Grok-4.1-Fast Referee (MINOR REVISION)

### Missing references
**Response:** Added Imbens & Lemieux (2008), Lee & Lemieux (2010) (already present), Gelman & Imbens (2019) (already present).

### CIs in tables
**Response:** Added to Table 2.

### Male outcomes RDD / boys' literacy
**Response:** Added male literacy as a full outcome. The finding that male literacy ALSO declines (and more so in parametric interactions) is now a central result.

---

## Response to Gemini-3-Flash Referee (MINOR REVISION)

### State heterogeneity for 250 non-replication
**Response:** Noted as suggestion for future work. Current data structure limits state-level subgroup analysis at the 250 threshold due to small samples.

### Teacher/school supply check
**Response:** Noted as important avenue for future work. DISE data matching at the village level is not currently available in our SHRUG extract but would strengthen the supply-side story.

### Male literacy
**Response:** Added as described above. The result confirms a broader pattern of educational disruption.

---

## Response to Exhibit Review (Gemini)

### Promote McCrary + balance to main text
**Response:** Done. New Figure 1 is a two-panel figure (McCrary + balance).

### Create ST literacy RDD figure
**Response:** Done. New Figure 3 shows the RDD plot for female literacy in ST-dominated villages.

### Move sensitivity plots to appendix
**Response:** Done. Bandwidth sensitivity and placebo threshold figures moved to appendix.

### Move Table 5 (250 threshold) to appendix
**Response:** Moved to robustness section rather than full appendix, as it provides important context.

### Clean up Table 4
**Response:** Expanded to include male literacy columns, reorganized coefficients.

---

## Response to Prose Review (Gemini)

### Kill roadmap paragraph
**Response:** Deleted.

### Tighten Section 2.1
**Response:** Removed road construction standards (carriage width, drainage).

### Rewrite Data section
**Response:** Replaced variable inventory with narrative grouping by story (employment, human capital, demographics).

### Active voice
**Response:** Changed throughout revised sections.

### Magnitude translation
**Response:** Added "roughly one-third of the expected educational catch-up for that decade" for the 0.72pp effect.
