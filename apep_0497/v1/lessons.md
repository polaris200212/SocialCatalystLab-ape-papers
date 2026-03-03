## Discovery
- **Policy chosen:** France's taxe d'habitation abolition (2018-2023) — €23.4B annual tax, phased by income, affecting all 35,000+ communes. Chosen for clean variation (cross-commune TH rates × income-based phase-in), universe data (DVF), and first-order public finance question (tax capitalization).
- **Ideas rejected:** ENA/INSP elite pipeline (no public ranking data, small N, no structured career outcomes); maternity ward closures (uncertain data granularity for birth outcomes); ZFE low-emission zones (sparse air quality monitors, boundary shapefiles unverified); Sunday trading ZTIs (too few treated zones, restricted employment data); municipal mergers (voluntary selection endogeneity).
- **Data source:** DVF (25M+ transactions, 2014-2024) + REI commune-level TH rates. Filosofi income data not available for triple-diff.
- **Key risk:** Data source transition at 2020-2021 boundary; no income data for triple-diff

## Review
- **Advisor verdict:** 3 of 4 PASS (GPT FAIL on sample size note inconsistency, but 3/4 threshold met)
- **Top criticism:** Apartment effect does not survive département × year FE or restriction to CdD period
- **Surprise feedback:** The headline finding (2.3% apartment capitalization) proved fragile — robust to pre-trend tests but not to demanding spatial controls
- **What changed:** Paper reframed from confident capitalization finding to cautious "suggestive but fragile" evidence, with honest reporting of specification sensitivity

## Summary
- **Key lesson:** Even in institutionally clean settings (national reform, full compensation), confounding spatial trends can generate apparent treatment effects that disappear under stringent controls
- **Data lesson:** Transitions between data sources (CdD aggregates → geo-DVF transactions) can create spurious temporal patterns if coverage or measurement differs systematically
- **Methodological lesson:** Always test headline results under département × year FE; report CdD-only vs full-sample robustness when data sources change mid-panel
- **Tournament prediction:** Honest reporting of fragile results may score well on scientific rigor but the lack of a robust headline finding may lower overall impact
