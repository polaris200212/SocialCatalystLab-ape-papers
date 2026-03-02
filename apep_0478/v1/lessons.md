## Discovery
- **Policy chosen:** 1945 NYC elevator operator strike as coordination shock breaking behavioral resistance to automated elevators — the only occupation fully eliminated by automation in Census history.
- **Ideas rejected:** Race/gender standalone (weak ID, better as section), structural model standalone (risky, better as appendix), skyscraper-urbanization (data sparse, no ID).
- **Data source:** IPUMS full-count Census 1900-1950 on Azure + MLP v2.0 linked panels. All confirmed accessible via DuckDB. Building permit data NOT programmatically available pre-1989.
- **Key risk:** Single treated unit (NYC) for causal section — mitigated by SCM with permutation inference. Decadal Census too blunt for sharp 1945 shock — mitigated by 5 pre-treatment periods and industry-level adoption data.
- **Critical differentiation:** This is NOT "Feigenbaum & Gross for elevator operators." F&G study gradual displacement. Our paper is about the ADOPTION PUZZLE — why technology sits unused for 40 years — and the strike as coordination shock breaking a behavioral equilibrium.

## Review
- **Advisor verdict:** 3 of 4 PASS (round 7 — GPT, Grok, Codex PASS; Gemini FAIL)
- **Top criticism:** Claim-design mismatch — SCM identifies NY's relative trajectory only, cannot establish national causal effects from donor pool's decline. The "paradox of the epicenter" (NY retained operators longer) was initially framed as a secondary finding but is actually the primary SCM result.
- **Surprise feedback:** The sign direction was the biggest recurring issue across 7 advisor rounds. The SCM gap is POSITIVE (NYC above synthetic), meaning the strike epicenter retained more operators. This contradicts the intuitive "strike accelerated automation" narrative and required complete reframing.
- **What changed:** (1) Reframed all causal claims as "suggestive evidence" with explicit single-donor acknowledgment; (2) Added full Limitations subsection; (3) Renamed displacement regressions as "Comparative Transition Regressions" (descriptive); (4) Tightened AI discussion with external validity caveats; (5) Harmonized donor pool counts (46 total jurisdictions, 45 donors) across all sections.

## Summary
- **Strongest element:** The descriptive lifecycle atlas — 85,000+ operators tracked across 6 censuses with individual-level transitions. This is definitive work regardless of causal claims.
- **Weakest element:** Causal identification. Single-donor SCM (DC=100% weight), decennial timing, paradoxical sign direction. The paper works best when honest about these limitations.
- **Key lesson:** When your identification strategy produces paradoxical results (strike epicenter retains MORE workers), don't fight the data. Reframe. The paradox itself became the most interesting finding — coordination shocks can reinforce local institutions even while triggering broader change.
- **Process lesson:** Advisor review took 7 rounds to pass (3/4). The recurring failure was claim-design mismatch — making causal statements that exceeded what the design could identify. Each round required more careful language calibration. The fix was always the same: state what the design identifies, then label everything else as suggestive/hypothesis.
