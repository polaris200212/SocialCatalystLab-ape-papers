# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1.1 Causal claims need discipline
**Response:** We have substantially revised the paper to make the descriptive framing explicit throughout. The abstract, introduction, newspaper section, discussion, and conclusion now use language like "consistent with," "suggests," and "appears to have preceded" rather than causal assertions. We added an explicit acknowledgment in the NYC discussion that we "cannot cleanly identify the causal effect of these institutions." The newspaper section now offers an alternative interpretation (building owners strategically shaping discourse) that we cannot rule out.

### 1.2 NYC comparison not identified
**Response:** Agreed. We revised the discussion to note that "NYC differs from other cities along many dimensions (building stock, density, demographics, immigration)" and that the pattern is "consistent with institutional barriers delaying automation" rather than caused by them. A building-code event study would strengthen this analysis substantially but requires new data collection beyond the scope of this revision.

### 1.3 SCM treatment timing/outcome
**Response:** We agree on the limitations and have kept the SCM in the appendix with appropriate caveats. The SCM is presented as supplementary evidence, not a core result.

### 1.4 Linked panel displacement ≠ automation displacement
**Response:** This is an important point. We now report comparison group exit rates directly in Section 6.1: janitors (81%), porters (83%), and guards (84%) all experienced similar exit rates, reflecting the enormous labor market churn of the 1940s. The text now frames the finding as: "What distinguishes elevator operators is not *whether* they left, but *where they went*." We added explicit WWII confounding to the limitations section.

### 1.5 Newspaper classification validation
**Response:** We added caveats about LLM-based classification reproducibility in the limitations section and noted that "core narrative findings hold when restricting to articles that matched high-signal keywords directly." A formal human-labeled validation set is a priority for future work.

### 2.1 Few-cluster inference
**Response:** With 49 state clusters, conventional CRVE is standard in the applied literature (Cameron & Miller 2015 suggest concern begins below ~30 clusters). We now report the number of clusters (S = 49) explicitly in the estimating equation section. Wild cluster bootstrap would strengthen inference and is noted as a robustness check for future work.

### 2.2 Model definitions underspecified
**Response:** We added an explicit estimating equation (Section 6.2) specifying: LPM, full covariate set (age, age², sex, race, marital status, nativity), state FEs, and state-clustered SEs.

### 2.3 IPW result discrepancy
**Response:** We agree this was inadequately discussed. The robustness section now honestly reports the discrepancy: the OCCSCORE estimate shifts from -0.132 (ns) to -0.342*** under IPW, and we explain that "IPW upweights younger and female workers—groups more likely to experience downward occupational transitions—who are underrepresented in the linked sample." We interpret the unweighted estimates as conservative.

### 2.4 Sample construction
**Response:** We added a summary statistics table (Table 0) showing the linked panel composition for operators (N = 38,562) and comparison workers (N = 374,317).

### 4.1 "First" claim
**Response:** Changed to "one of the clearest cases" throughout.

### 5.1 Over-claiming on involuntary displacement
**Response:** Revised. The text now notes that "similar exit rates across all building service occupations (81-84%) suggest that the 1940s were a period of high occupational mobility generally."

### 5.2 Cultural delegitimation precedes decline
**Response:** Softened throughout. The newspaper section header changed from "Discourse as Leading Indicator" to "Discourse and Occupational Decline." Added explicit caveat about strategic sampled years.

### 5.3 NYC conditional vs unconditional
**Response:** The text already distinguishes these; we ensured the language is clear.

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### Must-fix 1: Comparison group endogeneity
**Response:** The robustness section notes that results hold excluding janitors (potential absorbers). The new comparison exit rate data (Section 6.1) makes the similarity in exit rates across all comparison occupations explicit.

### Must-fix 2: NYC descriptive vs conditional
**Response:** The text already distinguishes unconditional descriptive means from regression coefficients. We ensured this distinction is clear.

### High-value 1: SCM to main text
**Response:** We prefer to keep the SCM in the appendix given its limitations (4 pre-periods, state-level aggregation). It is supplementary evidence, not a core result.

### High-value 2: Quantitative newspaper trends
**Response:** The classification pipeline produced incomplete results for this version. We present the newspaper evidence qualitatively with quantitative metadata (article counts per year). A formal thematic analysis is a priority for future work.

### High-value 3: Wage data
**Response:** IPUMS INCWAGE is poorly measured in 1940/1950 full-count data. We use OCCSCORE as an imperfect proxy for occupational quality and acknowledge its limitations.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### Must-fix 1: Clustering
**Response:** Standard errors are clustered at the state level (S = 49), now explicitly stated in the estimating equation section.

### Must-fix 2: SCM pre-trend
**Response:** Acknowledged as a limitation. The SCM is supplementary evidence in the appendix.

### High-value 1: Labor costs
**Response:** Historical wage data for elevator operators at this granularity is not reliably available. OCCSCORE serves as our occupational quality measure.

### High-value 2: Newspaper sentiment
**Response:** The classification pipeline produced incomplete results. Formal sentiment analysis is a priority for future work.

---

## Internal Review (Claude Code)

### Comparison group exit rate
**Response:** Added in Section 6.1 with specific rates for all three comparison occupations.

### Summary statistics table
**Response:** Added as Table 0 in the Data section.

### Kill roadmap
**Response:** Deleted.

### Tighten data section
**Response:** Revised opening to "To track the disappearance of the elevator operator, we follow 680 million person-records..."

---

## Exhibit Review

### Table 1 redundant with Figure 1
**Response:** Retained for readers who prefer tabular presentation. The table provides exact counts alongside rates.

### Figure 5 cluttered
**Response:** Noted for future visual revision.

### Summary statistics table missing
**Response:** Added as Table 0.

---

## Prose Review

### Kill roadmap
**Response:** Done.

### Active voice in data section
**Response:** Revised opening.

### Punchier section titles
**Response:** The section titles are functional and clear. Some suggestions (e.g., "The Mechanics of Displacement") were considered but we prefer descriptive precision over literary flair for an economics paper.
