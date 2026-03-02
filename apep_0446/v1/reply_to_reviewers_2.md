# Reply to External Reviewers (Stage C)

## Response to GPT-5.2 (Major Revision)

### Core Design Concerns

**"Treatment is state×phase with few cohorts; control group collapses"**
We agree this is the paper's central limitation. We have:
- Added explicit discussion in the treatment assignment section acknowledging that staggered variation is entirely between-state with only 4 cohorts and 2 control states (Section 4.3)
- Added a detailed caveat in the event study section noting that long-horizon coefficients (>8 quarters) are identified primarily from early-vs-late cohort contrasts (Section 6.2)
- Changed headline language from "definitive" to "suggestive" throughout (abstract, introduction, robustness discussion)
- Acknowledged that mandi-level integration dates would be the single most impactful improvement (limitations section)

**"Inference with few clusters"**
We now cite Conley and Taber (2011) and acknowledge that state-clustered SEs with <30 clusters may be anti-conservative. Wild cluster bootstrap was attempted but the `fwildclusterboot` R package was unavailable in our environment. We note this as a desirable extension (Section 7.4).

**"CS vs Sun-Abraham disagreement"**
We have substantially rewritten the robustness discussion to present this disagreement transparently rather than privileging CS-DiD. We now explain: (1) why the estimators differ mechanically, (2) why comparison group composition matters in our tight-cohort setting, and (3) characterize CS-DiD results as "suggestive" (Section 7, Table 4 discussion).

### Literature
We have added: de Chaisemartin and D'Haultfoeuille (2020), Roth et al. (2023), Conley and Taber (2011), and Donaldson (2018) to the bibliography and cited them in relevant sections.

### Other Suggestions
- **Stacked DiD**: Noted as a desirable extension but beyond scope of current revision
- **Price discovery outcomes**: We agree the null dispersion result deserves more engagement; we now discuss three alternative explanations (Section 6.4)
- **Confidence intervals**: Added 95% CIs for headline CS-DiD estimates in text
- **MSP/procurement controls**: Acknowledged as important; we discuss FCI's role for wheat vs soybean in Section 6.2

---

## Response to Grok-4.1-Fast (Minor Revision)

**"CS weights diagnostic"**
We acknowledge this would be valuable but is not straightforward with the `did` package's current API. We note it as a desirable extension.

**"Missing references"**
We have added the suggested methodological references. The domain-specific Indian references (Narayanan 2017, Gupta 2023) could not be verified in our bibliography database but are noted as relevant.

**"Mandi-level dates"**
Agreed this is the single most impactful improvement. Not feasible with current data sources.

---

## Response to Gemini-3-Flash (Minor Revision)

**"Wild cluster bootstrap"**
Acknowledged (see GPT response). Package unavailability prevented implementation; noted as desirable extension.

**"Arrivals analysis"**
We now note in the limitations section that arrival data from the CEDA API was too sparse for reliable estimation, and flag this as a natural extension for future work (Section 8.4).

**"Mandi-level subsample"**
Excellent suggestion. Not feasible with current data sources but noted for future work.

---

## Exhibit Review Changes
- Consolidated wheat/soybean event studies into a single two-panel figure (Figure 2)
- Promoted rollout timeline figure to main text Section 2.3 (now Figure 1)
- Moved commodity comparison and sensitivity figures to appendix
- Fixed Table 2 FE labels ("Mandi" and "Month-Year" instead of code names)
- Rounded R² to 3 decimal places in Table 2

## Prose Review Changes
- Tightened results preview in introduction
- Added "punchier" table transition ("As we show next, this is a statistical artifact...")
- Humanized data cleaning description
- Added closing sentence to conclusion ("Digital markets can bridge geographic distances...")
- Improved active voice in methodology sections
