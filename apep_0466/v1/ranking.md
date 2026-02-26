# Research Idea Ranking

**Generated:** 2026-02-26T17:29:33.107381
**Model:** openai/gpt-5.2 (reasoning: high)
**Tokens:** 7213

---

### Rankings

**#1: Does Local Governance Scale Matter? Municipal Population Thresholds and Firm Creation in France**
- **Score: 76/100**
- **Strengths:** Very strong design space: multiple population cutoffs with large mass of communes near thresholds plus universe establishment outcomes (Sirene) gives excellent statistical power and scope for credibility checks (density tests, covariate balance, placebo cutoffs). The **difference-in-discontinuities at 3,500 around the 2013 reform** is a genuinely valuable add-on to separate bundled institutional changes.
- **Concerns:** “Sharp” may be overstated because key treatments (especially **council size**) are effectively set at **municipal-election dates** (term-based), while **legal population updates annually**—this can make the design **fuzzy/partially treated** unless you align treatment to election cycles or focus on components that update mechanically (e.g., compensation rules if they update annually). Also, treatment bundles at cutoffs (council size + mayor pay + sometimes electoral rules) complicate interpretation unless you explicitly frame it as a “governance scale package” or use DiDisc to isolate components.
- **Novelty Assessment:** **High.** These French municipal thresholds are well-known in political economy, but using them to study **local firm dynamics in Sirene** is meaningfully less crowded than the political-outcomes literature.
- **DiD Assessment (for the DiDisc component at 3,500 pre/post-2013):**
  - **Pre-treatment periods:** **Strong** (Sirene and population series can plausibly provide >5 years pre-2013)
  - **Selection into treatment:** **Strong** (national law change, not adopted in response to local firm trends)
  - **Comparison group:** **Strong** (communes just below/above 3,500 are highly comparable; local design)
  - **Treatment clusters:** **Strong** (hundreds/thousands of communes near cutoff)
  - **Concurrent policies:** **Marginal** (macro shocks are differenced out, but any 2013–2014 reforms differentially affecting ~3,500 communes could contaminate; must audit contemporaneous municipal finance/election changes)
  - **Outcome-Policy Alignment:** **Marginal** (firm creation is a plausible downstream outcome of governance capacity/representation, but mechanism is indirect; you’ll want mechanism tests: procurement speed, permitting, local taxes, business-service provision)
  - **Data-Outcome Timing:** **Marginal** (2013 reform affects the **2014 election**; annual outcomes for 2014 are partially exposed; cleanest is to treat **2015+** as post and/or use monthly creation dates from Sirene)
  - **Outcome Dilution:** **Strong** (governance rules affect the whole commune/business environment; not a tiny-target population)
- **Recommendation:** **PURSUE (conditional on: explicitly aligning “treatment start” to municipal election timing and dropping partial-exposure years like 2014; clarifying whether each institutional component is sharp vs fuzzy; pre-registering how you handle multiple cutoffs/multiple testing)**

---

**#2: Rural Revitalization Zones and Firm Creation: Evidence from the ZRR-to-FRR Reclassification**
- **Score: 64/100**
- **Strengths:** Extremely policy-relevant and **time-sensitive**: the 2024 FRR reclassification is exactly the kind of reform policymakers will ask about, and Sirene can deliver high-frequency outcomes (creation dates) suited to short-run responses. Clear treated group exists (~2,200 communes losing status; thousands gaining).
- **Concerns:** Identification is the main risk: eligibility is determined at the **EPCI level** using **two thresholds (density and income)**, so (i) the effective running-variable unit is the EPCI (far fewer observations “near cutoff” than commune counts suggest), (ii) multidimensional assignment can make RDD fragile (you may need a well-justified scalar index or a design focusing on one binding margin), and (iii) **post-period is short** and begins **mid-year (July 1, 2024)** so annual outcomes will be mechanically attenuated unless you use monthly/quarterly outcomes.
- **Novelty Assessment:** **Very high.** Prior ZRR work exists, but the **FRR redesign/reclassification (2024)** is new and likely unstudied.
- **Recommendation:** **CONSIDER (conditional on: using monthly Sirene events to solve timing; demonstrating sufficient EPCI mass near the relevant cutoff(s); pre-specifying a defensible one-dimensional forcing variable or a design that isolates a single threshold margin)**

---

**#3: Proportional Representation and Local Business Environments: The 2013 Electoral Reform as a Natural Experiment**
- **Score: 60/100**
- **Strengths:** The reform is cleanly assigned by population and applied broadly, with a large number of communes near 1,000—so there is real potential for a credible local design. If you extend the proposal to an **RD-in-DiD (difference-in-discontinuities)**—comparing the 1,000 discontinuity **before vs after 2014**—you can net out permanent threshold-related discontinuities (e.g., baseline governance/pay rules).
- **Concerns:** As written (post-2014 RDD only), it risks **baseline discontinuities** at 1,000 that pre-date the reform (exactly the Eggers-style pitfall). Also the “treatment” is bundled: electoral rule + gender parity constraints + (possibly) salary/council changes at the same cutoff—so interpretation needs either (i) explicit “institutional package” framing, or (ii) a DiDisc strategy and mechanism outcomes (council fragmentation, procurement, tax policy) to show the channel.
- **Novelty Assessment:** **Medium.** The 1,000 threshold reform is known and studied for political outcomes (fragmentation, gender parity), but **firm dynamics** as the outcome is less studied; still, the design itself is not new.
- **DiD Assessment (only if you implement the recommended RD-in-DiD / DiDisc around 2014):**
  - **Pre-treatment periods:** **Strong** (can get many years pre-2014)
  - **Selection into treatment:** **Strong** (national mandate)
  - **Comparison group:** **Strong** (communes near 1,000)
  - **Treatment clusters:** **Strong** (thousands of communes)
  - **Concurrent policies:** **Marginal** (municipal cycle and any contemporaneous local-finance reforms could matter; must audit)
  - **Outcome-Policy Alignment:** **Marginal** (electoral rules plausibly affect business climate via governance quality; indirect)
  - **Data-Outcome Timing:** **Marginal** (treatment effectively starts with councils elected **March 2014**; 2014 is partial exposure—better to use 2015+ or monthly outcomes)
  - **Outcome Dilution:** **Strong** (broad governance change, not narrowly targeted)
- **Recommendation:** **CONSIDER (conditional on: redesigning as DiDisc/RD-in-DiD using pre-2014 outcomes; dropping/handling partial exposure in 2014; clearly separating or explicitly bundling the multiple institutional changes at 1,000)**

---

**#4: DGF Fiscal Equalization Transfers and Local Entrepreneurship**
- **Score: 38/100**
- **Strengths:** Big-money policy with clear relevance: intergovernmental transfers could plausibly affect local investment climate, amenities, and thus entrepreneurship. If a truly mechanical kink/jump could be isolated, it would be powerful.
- **Concerns:** High probability the “clean cutoff” doesn’t exist in practice: DGF/DSR/DSU rules are **multi-criteria, frequently reformed, and strategically interacted with**, making RDD validity and stable treatment definition hard. RKD requires strong smoothness and precise knowledge of the formula and implementation; plus population (and possibly fiscal variables) may be manipulable, and the needed commune-level transfer data/eligibility components may be incomplete or hard to reconstruct historically.
- **Novelty Assessment:** **Medium.** Transfers and local outcomes are widely studied generally; France-specific DGF-to-entrepreneurship is less saturated, but the identification obstacles dominate.
- **Recommendation:** **SKIP (unless you can first document a single, stable, one-dimensional rule that generates a true discontinuity/kink and assemble consistent historical transfer/eligibility microdata)**

---

### Summary

This is a strong batch conceptually, with two genuinely promising directions built around **French administrative discontinuities + Sirene universe outcomes**. **Idea 1** is the best immediate bet because it pairs high novelty with strong power and a credible enhancement (DiDisc) to address bundled treatments—provided you fix the **election-cycle/timing sharpness** issue. **Ideas 2 and 4** are attractive policy questions, but Idea 2’s multidimensional EPCI assignment and short post-window, and Idea 4’s bundled discontinuity problem (unless upgraded to DiDisc), are the main identification risks.