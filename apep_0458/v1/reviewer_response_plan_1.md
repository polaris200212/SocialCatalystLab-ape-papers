# Reviewer Response Plan — Round 1

## Cross-Cutting Issues

All three reviewers raise the same three core concerns:

### 1. Post-Treatment Running Variable (GPT §1.1, Grok §1, Gemini §1)
**Status: Fundamental design limitation — acknowledged but not fully resolvable.**
Pre-2012 municipality-level ZWA data are not publicly available in digital form. We strengthen the discussion of this limitation and its implications for bias direction. We note that 99.2% of municipalities have definitive ARE status (not verfahren), and the ban affects *new construction* (not existing classifications), limiting the scope for running variable drift. We soften causal claims accordingly.

### 2. No First-Stage Evidence (GPT §3.2, Grok §1, Gemini §3)
**Status: Data limitation — partially addressable.**
Municipal-level building permits by dwelling type are not available from BFS at the required granularity. We cannot construct a clean first-stage. We strengthen the cantonal mechanism discussion and explicitly frame the null as "reduced form without first stage," noting this limits interpretation. We add text acknowledging that the null could reflect weak treatment bite rather than genuine labor market resilience.

### 3. Small Treated N Near Cutoff (GPT §2.2, Grok §2, Gemini §2)
**Status: Inherent to design — partially addressable.**
The thin right tail is a structural feature of Switzerland's ZWA distribution. We add leave-one-out jackknife analysis to demonstrate that no single municipality drives the null. We strengthen MDE discussion.

## Workstream 1: Identification & Claims (Priority: HIGH)
- Soften "precise null" language for log employment (GPT §5.1, Gemini §5)
- Reframe abstract/conclusion: growth is "precisely estimated null," levels are "imprecise null consistent with growth result"
- Strengthen running variable paragraph with explicit bias direction discussion
- Add explicit "reduced form without first stage" framing
- Acknowledge "weak treatment bite" as alternative explanation

## Workstream 2: Additional Analysis (Priority: MEDIUM)
- Add leave-one-out jackknife for main employment growth result
- Add note about spatial spillover concerns and why neighboring controls could bias toward zero

## Workstream 3: Prose (Priority: LOW)
- Tighten abstract claims
- Fix any remaining over-claiming in conclusion

## Workstream 4: Exhibits (Priority: LOW)
- No exhibit changes needed (already addressed in prior rounds)

## Decision
Given 14 prior revision rounds with anti-loop triggered, and fundamental data limitations (no pre-2012 ZWA, no municipal permits), we make targeted text improvements and proceed to publish. The core design limitations are genuinely unresolvable with available data.
