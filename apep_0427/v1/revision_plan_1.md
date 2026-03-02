# Reply to Reviewers — Round 1

## Reviewer 1 (GPT-5.2): MAJOR REVISION

### 1. Algebra in Conceptual Framework (double-counting subsidy)
**Concern:** Variable $w_a$ defined as "net cost" but then $w_a - s$ subtracts subsidy again.
**Response:** Fixed. Now $w_a$ is defined as the **gross** wage cost (before subsidy), making $w_a - s$ the net cost. Equation is algebraically consistent.

### 2. Wild Cluster Bootstrap
**Concern:** Clustered SEs unreliable with 19 sectors.
**Response:** Added wild cluster bootstrap (Rademacher, 999 replications). Main coefficient: p = 0.18. Youth level: p = 0.23. Now reported in main text alongside clustered SEs and RI. Paper now interprets sign and magnitude rather than relying on marginal significance.

### 3. Mechanical Prime-Age Placebo
**Concern:** Youth share + prime-age share ≈ 100%, so mirror coefficient is arithmetic.
**Response:** Acknowledged explicitly in revised text. Section now states the symmetry is "largely mechanical" and discusses ideal (but unavailable) alternative placebos.

### 4. "Bartik" Terminology
**Concern:** Single-shock design is not canonical Bartik.
**Response:** Renamed to "exposure DiD" in key places. Added footnote clarifying relationship to shift-share literature with citations to Goldsmith-Pinkham et al. (2020), Borusyak et al. (2022).

### 5. Total Employment as Red Flag
**Concern:** Column 4 shows total employment also rises differentially—sectoral tailwinds.
**Response:** Now explicitly flagged as "a red flag for identification" in the results text. Discussion acknowledges this complicates clean interpretation and directs reader to mechanisms section.

### 6. Overclaiming
**Concern:** "Clear conclusion" and "bought a change of name" not warranted given design limitations.
**Response:** Toned down throughout. Conclusion now says "provisional answer" and "evidence favors relabeling." Cross-country evidence reframed as "suggestive." Added call for confirmation with administrative apprenticeship contracting data.

### 7. Missing References
**Concern:** Shift-share, few-cluster, SCM literature missing.
**Response:** Added Goldsmith-Pinkham et al. (2020), Borusyak et al. (2022), Adao et al. (2019), Cameron et al. (2008), Bartik (1991), Abadie & Gardeazabal (2003).

### 8. RI vs Clustered SE Discrepancy
**Concern:** RI p < 0.001 inconsistent with clustered p = 0.07.
**Response:** Now explicitly discussed. Explained that RI tests sharp null without accounting for serial correlation. Paper presents range of inference results.

### Not Addressed (would require new data/major redesign):
- Within-France sector × age DDD (no sector × age data in Eurostat LFS at required frequency)
- Administrative apprenticeship contracting data (DARES sector-quarter series not publicly available via API)
- Minor vs. adult age discontinuity (LFS does not separately identify minors by sector)
- SCM for cross-country (acknowledged as valuable extension)

---

## Reviewer 2 (Grok-4.1-Fast): MINOR REVISION

### 1. Missing Methodological References
**Response:** Added Bartik (1991), Goldsmith-Pinkham et al. (2020), Callaway & Sant'Anna (2021) to bibliography.

### 2. Exploit 2025 Reform
**Response:** Already noted in footnote. Formalization as second event study is a valuable extension but beyond current scope.

### 3. Minor Typos
**Response:** Addressed in revision.

---

## Reviewer 3 (Gemini-3-Flash): MINOR REVISION

### 1. Positive Coefficient Puzzle
**Response:** Now discussed more carefully, with the total employment red flag explicitly acknowledged.

### 2. Table Formatting
**Response:** Fixed raw variable names in Tables 3 and 4. Now shows "Youth Share (%)", "Emp. Rate (%)" etc. Fixed effects rows now properly capitalized.

### 3. Missing Goldsmith-Pinkham Reference
**Response:** Added.

---

## Exhibit Review Feedback

### Table Formatting
**Response:** Fixed raw variable names in all tables. Headers now professional ("Youth Share (%)" instead of "youth_share"). Fixed effects rows capitalized.

### Promote Figure 7 to Main Text
**Response:** Not implemented — the main text already has 3 figures and the current flow prioritizes the event study evidence.

---

## Prose Review Feedback

### Delete Roadmap Paragraph
**Response:** Done. Removed the "The remainder of the paper proceeds as follows..." paragraph.

### Punchier Abstract
**Response:** Added the "bought a change of name, not a change of opportunity" line to the abstract.

### Minor Prose Improvements
**Response:** Incorporated active voice suggestions in results discussion.
