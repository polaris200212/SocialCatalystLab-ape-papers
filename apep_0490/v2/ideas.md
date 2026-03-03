# Research Ideas

## Idea 1: The Price of Position: How arXiv Listing Order Shapes the Diffusion of AI Research

**Policy:** arXiv's daily submission cutoff at 14:00 ET creates a sharp discontinuity in announcement listing position. Papers submitted just after the cutoff become first-listed in the next day's announcement (position 1-5), while papers submitted just before are last-listed in the current announcement (position 40-80+). This institutional rule has been in place since arXiv's inception and has NOT been randomized (unlike NBER, which randomized in 2015 following Feenberg et al. 2017).

**Outcome:** Multiple outcomes from OpenAlex API: (1) 30-day, 1-year, 3-year, 5-year citation counts; (2) citation trajectories year-by-year; (3) publication in top-5 ML venues (NeurIPS, ICML, ICLR, AAAI, ACL); (4) industry citations — citations from papers authored at Google/DeepMind, Meta FAIR, OpenAI, Microsoft Research, Amazon, Anthropic, Apple MLR; (5) patent citations via Lens.org or Google Patents API; (6) author h-index growth and affiliation changes.

**Identification:** Sharp RDD at the 14:00 ET cutoff. Running variable = minutes from cutoff (negative = before, positive = after). Within a narrow bandwidth (±15-60 minutes), which side of the cutoff a submission lands on is plausibly as-good-as-random — it depends on network latency, file upload time, and minor scheduling decisions. The treatment is a massive jump in listing position (from ~last to ~first) combined with a 24-hour delay in announcement. The RDD estimates the net effect of this position-vs-timeliness tradeoff.

**Why it's novel:**
1. **First formal RDD at the arXiv cutoff.** Haque & Ginsparg (2009) and Dietrich (2008) document the first-listed advantage descriptively; Motloch and Peters (2024) debate causality informally. No one has applied modern RDD methods (rdrobust, rddensity, donut specifications).
2. **First analysis of CS/AI categories.** ALL prior work is on physics subfields (astro-ph, hep-th, hep-ph, quant-ph). CS categories have exploded in volume and relevance — cs.AI + cs.CL + cs.LG now dominate arXiv submissions.
3. **First measurement of industry adoption.** Using institutional affiliation data from OpenAlex, we can directly measure whether visibility drives adoption by leading AI companies — a question with massive economic stakes given the AI industry's $100B+ scale.
4. **First career-outcome analysis.** Linking visibility to author trajectories (h-index growth, affiliation upgrades, funding).
5. **Mechanism decomposition:** Position effect vs. timeliness effect vs. day-of-week exposure effect (Thursday → Sunday 3-day front page).

**Feasibility check:**
- **Timestamps:** Confirmed available at HH:MM:SS resolution via arXiv Atom API (tested: `2022-12-21T18:07:06Z`)
- **Citations:** OpenAlex provides total + year-by-year citation counts, author affiliations, institutional data (free, no API key)
- **Sample size:** cs.AI + cs.CL + cs.LG + stat.ML have ~300K+ papers (2012-2022). With ±30min bandwidth, expect ~40,000-60,000 papers in RDD sample — excellent power
- **R packages:** `rdrobust`, `rddensity`, `aRxiv`, `openalexR` all available
- **Not overstudied:** No formal RDD exists. Feenberg et al. (2017, ReStat) on NBER is the closest, but arXiv hasn't randomized ordering, making the positional effect ACTIVE and exploitable
- **Diagnostics:** McCrary density test will likely show bunching (strategic authors). Addressed via: donut RDD (exclude ±5 min), varying bandwidths, balance tests on author seniority/paper characteristics, placebo cutoffs at non-14:00 times, placebo categories (math subfields with fewer readers)

**Key risk:** Bunching/manipulation at the cutoff. Strategic authors know the 14:00 ET rule and time submissions accordingly. This is the primary threat to RDD validity. Mitigation: donut RDD, pre-determined characteristic balance, weekend submissions as placebo.

---

## Idea 2: Platform Batching and Knowledge Diffusion: Evidence from Multiple Preprint Servers

**Policy:** Compare batching effects across arXiv (14:00 ET daily cutoff), SSRN (continuous posting, weekly email digests), and bioRxiv/medRxiv (daily listings). Each platform has different institutional rules for ordering and timing, creating natural variation in how visibility is allocated.

**Outcome:** Citations (from OpenAlex), Altmetric scores (social media mentions), journal publication, policy citations.

**Identification:** Multi-platform comparison. arXiv provides the RDD (cutoff-based). SSRN provides a difference-in-discontinuities design (before vs. after email digest timing). bioRxiv/medRxiv provide additional platforms with different ordering rules. The cross-platform comparison tests external validity and mechanism generality.

**Why it's novel:** No paper compares batching effects across multiple platforms. This tests whether the first-listed premium is a platform-specific artifact or a universal feature of information markets.

**Feasibility check:**
- Confirmed: arXiv timestamps available. SSRN posting dates available via their API. bioRxiv/medRxiv metadata via their API.
- Risk: SSRN and bioRxiv may not have exact submission timestamps, weakening identification for those platforms. arXiv is the only clean RDD.
- Scope concern: multi-platform design may stretch too thin. Better as a follow-up to Idea 1.

---

## Idea 3: Randomness at the Frontier: How Accidental Visibility Shapes the Direction of AI

**Policy:** Same arXiv cutoff instrument as Idea 1, but with a different research question: does the visibility lottery STEER the direction of research? If a paper on "attention mechanisms" happens to be first-listed and gets 50% more citations, does subsequent research tilt toward attention mechanisms rather than alternative approaches?

**Outcome:** (1) Topic diffusion measured by text similarity — do papers cited more due to visibility generate more "follow-on" work in the same topic space? (2) Method adoption — when a paper introduces a novel technique and gets visibility, is that technique adopted faster? (3) Keyword propagation — do visible papers' keywords become more common in subsequent submissions?

**Identification:** RDD at the cutoff, but second stage is topic/method diffusion rather than individual paper citations. Use text embeddings (from OpenAlex or Semantic Scholar) to measure topic similarity between first-listed papers and subsequent submissions.

**Why it's novel:** Tests whether platform design features influence the DIRECTION of scientific research, not just the success of individual papers. This is a question about the allocation of societal attention to ideas.

**Feasibility check:**
- Topic measurement via embeddings is feasible using Semantic Scholar's pre-computed SPECTER embeddings
- Requires careful econometrics to separate "my paper got cited more" from "my paper's TOPIC got studied more"
- More speculative identification — topic diffusion is slow and noisy. Risk of underpowered second stage.
- Better as Section 6 of Idea 1 rather than standalone.

---

## Idea 4: The GitHub Trending Algorithm and Open-Source Software Adoption

**Policy:** GitHub's "Trending" page highlights repositories that gain stars rapidly. Appearing on Trending creates a massive visibility shock — projects can gain thousands of stars in a day. The algorithm uses rolling windows with implicit daily cutoffs.

**Outcome:** Star counts, fork counts, contributor counts, downstream dependency adoption (npm/pip installs), funding (GitHub Sponsors, venture capital).

**Identification:** Exploit the threshold nature of the Trending algorithm — projects that barely make the Trending page vs. those that barely miss it. RDD on the ranking metric (star velocity relative to the Trending threshold).

**Why it's novel:** No causal study of the GitHub Trending effect exists. Direct measurement of how visibility translates to software adoption and economic value.

**Feasibility check:**
- **CRITICAL PROBLEM:** GitHub does not publish historical Trending data or the algorithm's exact rules. The ranking algorithm is proprietary and changes frequently. No public archive of daily Trending lists.
- Without historical Trending data, the RDD is not feasible.
- **REJECT** due to data infeasibility.
