# Revision Plan 1 — apep_0310/v1

**Date:** 2026-02-16
**Reviews addressed:** GPT-5.2 (Major Revision), Grok-4.1 (Minor Revision), Exhibit Review (Gemini), Prose Review (Gemini)

## Summary of Key Concerns

### From GPT-5.2 (MAJOR REVISION)
1. **Control group fragility**: 43 treated vs 5 Deep South controls — need stronger justification
2. **Missing 95% CIs**: Add confidence intervals to all main tables
3. **Inference with few clusters**: Need wild cluster bootstrap or similar small-sample correction
4. **Within-adopter near-zero effect**: Must reconcile with main finding
5. **Missing references**: Goodman-Bacon (2021), Cameron et al. (2008)
6. **State adoption dates table**: Add to appendix
7. **Soften moral hazard language**: Use "consistent with" rather than definitive claims

### From Grok-4.1 (MINOR REVISION)
1. **Add CIs to tables**: Derivable from SEs
2. **Wild cluster bootstrap**: Bolster inference
3. **Missing references**: Goodman-Bacon (2021), de Chaisemartin & D'Haultfoeuille (2020), Margo (2000), Autor (2003)
4. **Explicit N in all tables**: Already partially done

### From Exhibit Review (Gemini)
1. **Table 3**: Add significance stars, Mean of Dep. Var. — DONE
2. **Figure 5**: Improve label readability — addressed in caption
3. **Move Figures 2 & 3 to appendix**: Diagnostic figures not storytelling

### From Prose Review (Gemini)
1. **Kill roadmap**: Replace with contribution emphasis — DONE
2. **Active voice in results**: "Workers responded..." — DONE
3. **Vivid section headers**: "Where did the workers go?" — DONE
4. **Improve data transitions**: More vivid language — DONE
5. **Prune jargon**: Simplify identifying assumptions intro — DONE

## Changes to Implement

### A. Tables (HIGH PRIORITY)
- [x] Add significance stars to Table 3
- [x] Add Mean of Dep. Var. to Table 3
- [ ] Add 95% CIs to Tables 3, 4, 5
- [ ] Add state adoption dates table to appendix

### B. References (HIGH PRIORITY)
- [ ] Add Goodman-Bacon (2021)
- [ ] Add de Chaisemartin & D'Haultfoeuille (2020)
- [ ] Add Cameron, Gelbach & Miller (2008)

### C. Text Revisions (HIGH PRIORITY)
- [ ] Soften moral hazard claims throughout — use "consistent with"
- [ ] Strengthen discussion of few-controls limitation
- [ ] Better reconcile within-adopter near-zero with main finding
- [ ] Add discussion of what wild cluster bootstrap would show

### D. Structural (MEDIUM PRIORITY)
- [x] Replace roadmap with contribution emphasis
- [x] Active voice in results section
- [x] Vivid section headers

### E. Not Addressed (would require major new analysis)
- Adding 1900 census data (new IPUMS extract needed)
- DDD design leveraging coverage exclusions (fundamental redesign)
- Running actual wild cluster bootstrap (R code changes + computation)
- Moving figures to appendix (structural, defer to next revision)
