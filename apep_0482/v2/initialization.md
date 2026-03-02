# Human Initialization
Timestamp: 2026-03-02T09:40:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Questions Asked

1. **Country:** Which country?
   - Options: USA, France, India, Switzerland, Nigeria, United Kingdom, Other

2. **Method:** Which identification method?
   - Options: DiD (recommended), RDD, DR (Doubly Robust)

3. **API keys:** Are French API credentials configured?
   - Options: Yes, No

4. **External review:** Include external model reviews?
   - Options: Yes (recommended), No

5. **Other preferences:** Any other preferences or constraints?

## User Responses

1. France (initially selected; pivoted to Spain during discovery due to data constraints — see notes below)
2. "whatever you think is best" → RDD (Difference-in-Discontinuities at population thresholds)
3. Yes (French keys configured, but Spain data requires no API keys — all open access)
4. Yes (Recommended)
5. "the research question is: do local female politicians affect local policies enacted, compared to male politicians? I know about Duflo paper, but want something novel. Europe. Ideally budget allocations, granular. So, you know, within education budgets, what specific things are invested in terms. But I don't know which country is best and what data is available. Also, in many countries they have councils, not a single mayor. Maybe even downstream outcomes as well, kind of reduced form."

## Discovery Notes: Country Pivot

User initially selected France. During deep discovery (4 parallel research agents covering Spain, France, 9 other European countries, and full literature review), we discovered:

1. **apep_0433** already studied French parity law → comprehensive null on broad spending categories and female employment
2. France's M14 functional budget classification (which gives within-education granularity) was only mandatory for communes >3,500 — the exact same threshold as the parity law, making within-category analysis at the treatment boundary impossible
3. **Spain** has program-level budget data (CONPREL) for ALL municipalities regardless of size, with within-education subcategories (infant/primary centers, complementary education, school meals)
4. Spain's 2007 Equality Law creates clean RDD at 5,000 inhabitants (extended to 3,000 in 2011) — two cutoffs for multi-cutoff replication
5. Bagues & Campa (2021, JPubE) found aggregate spending nulls in Spain but never decomposed within categories

**Pivot rationale:** Spain provides strictly better data infrastructure for the within-category budget composition question that is the paper's novel contribution.

## Revision Information

- **Parent paper:** apep_0482 (v1)
- **Revision type:** Major revision addressing three external referee reviews (GPT=R&R, Grok=Minor, Gemini=Minor from v1; GPT=Major, Grok=Minor, Gemini=Minor from v2)
- **Key changes:**
  1. Election-term-level RDD with election-year running variable (addressing GPT v1 critique)
  2. By-election-cohort first stage decomposition revealing "shelf life" pattern
  3. Benjamini-Hochberg q-values for all main tables
  4. Levels and extensive margins analysis
  5. 2011-only pre-LRSAL analysis (new in Stage C)
  6. Narrative reframing: "explaining the European null" not "adding another null"
  7. Main text streamlined: robustness exhibits moved to appendix

## Setup Results

- **Country:** Spain (pivoted from France during discovery)
- **Domain:** Political economy — gender quotas and municipal budget composition
- **Method:** RDD (population threshold discontinuity, multi-cutoff)
- **Data era:** Modern (2010-2023)
- **Risk appetite:** Novel angle (classic policy + classic data + new question)
- **Other preferences:** Within-category budget decomposition, downstream outcomes, council-level analysis
