# Revision Plan (Stage C)

## Summary of Reviews
- **GPT-5-mini:** MINOR REVISION — Strengthen inference (wild bootstrap, more RI perms), add individual-level robustness, formalize MDE, investigate everyday smoking anomaly
- **Grok-4.1-Fast:** MINOR REVISION — Add MDE figure, age heterogeneity, some-days rate decomposition, 3 literature citations
- **Gemini-3-Flash:** CONDITIONALLY ACCEPT — Add Funk (2007) citation, compositional test, tobacco control spending if available

## Planned Changes (Prioritized)

### High Priority (Address in this revision)
1. **Add missing references to references.bib:** Funk (2007), Bertrand et al (2004), Cameron & Miller (2015), Roth (2022)
2. **Increase RI permutations:** 200 → 1000 in 04_robustness.R
3. **Test compositional explanation:** Compute some-days smoking rate and estimate CS-DiD on it; if some-days rate declines, supports compositional story
4. **Formalize MDE:** Add explicit power calculation to Section 5.4
5. **Cite new references in paper.tex** where appropriate

### Medium Priority (Acknowledge but defer)
6. Individual-level CS-DiD (computationally intensive with 7.5M obs; acknowledge in text)
7. Wild cluster bootstrap (note 51 clusters is adequate; cite Cameron & Miller)
8. Synthetic control for early adopters (different method, acknowledge as future work)
9. Additional heterogeneity (age, urban/rural)

### Not Addressed (Explain why)
- Tobacco control spending data: not readily available in API-accessible form
- Industry-specific analysis: BRFSS occupation codes not consistently available
- Google Trends data: auxiliary data source outside paper's scope
