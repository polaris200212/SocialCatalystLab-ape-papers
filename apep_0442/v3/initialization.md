# Human Initialization — Revision of apep_0442
Timestamp: 2026-02-24T00:00:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0442_v2
**Parent Title:** "The First Retirement Age: Civil War Pensions and Elderly Labor Supply at the Age-62 Threshold"
**Parent Decision:** MAJOR REVISION (GPT-5.2: MAJOR, Grok-4.1: MINOR, Gemini-3: MINOR)
**Revision Rationale:** Switch from IPUMS 1.4% oversample (N~3,800, MDE~30pp) to Costa Union Army dataset (NBER "Early Indicators", N~39,340). Adds panel data, observed pension records, health data from surgeons' certificates.

## Key Changes Planned

- Switch data source to Costa Union Army dataset from NBER (~39,340 white Union veterans)
- Panel RDD using 1900-1910 linked census data (within-person LFP change)
- Observed first stage: actual pension receipt/amounts from pension records
- Fuzzy RDD / 2SLS LATE estimates
- Health mechanisms from surgeons' certificates (762,607 exam records)
- Pre-treatment falsification on same population (LFP in 1900)
- Occupation transitions, dose-response, household effects
- Drop Confederate placebo (not in Costa data), IPUMS-specific analyses
- MDE improvement from ~30pp to ~2.6pp

## Original Reviewer Concerns Being Addressed

1. **GPT-5.2 (Major):** Underpowered design (N_L=124), density test rejection, literacy imbalance → FIXED via 10x sample
2. **Grok-4.1 (Minor):** Need full-count census, MLP linkage → ADDRESSED via Costa panel data
3. **Gemini-3 (Minor):** Lack of observed first stage, insufficient robustness → FIXED via pension records

## Inherited from Parent

- Research question: Did Civil War pension eligibility at age 62 reduce elderly labor supply?
- Identification strategy: RDD at age 62 (now with panel + fuzzy RDD extensions)
- Historical period: 1907 Service and Age Pension Act

## User Responses (Inherited from Parent)

1. Open topic (any policy/data)
2. Surprise me → Historical American economic policy
3. RDD
4. Full exploration
5. Historical (1850-1950)
6. Yes (API keys configured)
7. Yes (external review)
8. No constraints — full creative freedom
