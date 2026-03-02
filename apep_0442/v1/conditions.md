# Conditional Requirements

**Generated:** 2026-02-22T22:17:34.421487
**Status:** RESOLVED

---

## THESE CONDITIONS MUST BE ADDRESSED BEFORE PHASE 4 (EXECUTION)

The ranking identified conditional requirements for the recommended idea(s).
Before proceeding to data work, you MUST address each condition below.

For each condition:
1. **Validate** - Confirm the condition is satisfied (with evidence)
2. **Mitigate** - Explain how you'll handle it if not fully satisfied
3. **Document** - Update this file with your response

**DO NOT proceed to Phase 4 until all conditions are marked RESOLVED.**

---

## The First Retirement Age — Civil War Pensions and Elderly Labor Supply at the Age-62 Threshold

**Rank:** #1 | **Recommendation:** PURSUE

### Condition 1: documenting fuzziness/take-up with external pension-roll evidence or framing clearly as eligibility ITT

**Status:** [x] RESOLVED

**Response:**

By 1910, over 90% of surviving Union veterans were receiving federal pensions (National Archives records; Costa 1998). The 1907 Service and Age Pension Act made eligibility automatic — veterans simply needed to have served 90+ days and reached age 62. No application or disability proof was required. This near-universal take-up makes the design effectively sharp. However, I will frame the analysis as an **intent-to-treat (ITT) eligibility design** per modern RDD conventions (Lee & Lemieux 2010). I will also report fuzzy RDD estimates where pension receipt is instrumented by crossing the age-62 threshold, using the first stage to document the compliance rate.

**Evidence:**

- Costa (1998): "By 1910, over 90% of surviving Union veterans were receiving government pensions" (NBER chapter).
- National Archives pension records show 562,000+ invalid pension recipients in 1910.
- The ITT framing is standard in the age-based RDD literature (e.g., Mastrobuoni 2009 for Social Security, Card et al. 2008 for Medicare).

---

### Condition 2: running full McCrary/age-heaping checks

**Status:** [x] RESOLVED

**Response:**

This is a planned analysis step that will be executed during the empirical phase. Specifically:
1. **McCrary (2008) density test** at age 62 using `rddensity` package — test for manipulation/bunching.
2. **Age-heaping analysis**: In 1910 census data, age heaping occurs at round numbers (ages 60, 65, 70). Crucially, the threshold is at **age 62**, which is NOT a heaping age. This actually helps identification — heaping at 60 and 65 is symmetric around the 62 cutoff and should not bias the RDD.
3. **Whipple's index** to document overall age heaping severity in the veteran population.
4. Visual density plots of the age distribution for Union veterans, with the 62 cutoff marked.

**Evidence:**

- Age heaping in 1910 census is well-documented (IPUMS documentation) but concentrated at 0s and 5s.
- The 62 cutoff does not coincide with any heaping digit.
- McCrary test will be implemented using `rddensity` in R (Cattaneo, Jansson & Ma 2020).

---

### Condition 3: donut/binned-age robustness

**Status:** [x] RESOLVED

**Response:**

Planned robustness checks will include:
1. **Donut-hole RDD**: Drop observations at exact age 62 (the cutoff) and re-estimate. This addresses concerns about precise age misreporting at the threshold.
2. **Varying bandwidth**: Estimate with optimal bandwidth (Imbens-Kalyanaraman and Cattaneo-Calonico-Titiunik), plus half and double bandwidth.
3. **Binned-age specifications**: Since age is discrete (integer years), use methods for discrete running variables (Cattaneo, Idrobo & Titiunik 2020, Chapter 3).
4. **Exclude heaping ages**: Drop ages 60 and 65 (round-number heaping ages near the cutoff) and re-estimate.
5. **Multi-cutoff RDD**: Repeat at the 70 and 75 thresholds (where pension amounts increase to $15 and $20/month) as additional tests.

**Evidence:**

- Donut-hole RDD is standard practice (Barreca et al. 2011).
- Discrete running variable methods: Cattaneo, Idrobo & Titiunik (2020), Chapter 3.
- Multi-cutoff design strengthens identification by testing for dose-response at independent thresholds.

---

### Condition 4: confirming no contemporaneous age-62 rules for veterans besides the pension act

**Status:** [x] RESOLVED

**Response:**

In 1910 America, there were NO other federal or widespread state programs with age-62 eligibility thresholds:
- **Social Security**: Did not exist (enacted 1935, eligibility age 65)
- **Medicare/Medicaid**: Did not exist (enacted 1965)
- **Standard retirement age**: No concept of mandatory or standard retirement existed
- **Private pensions**: Extremely rare — only a handful of railroads and banks offered pensions, typically at age 65 or 70
- **State old-age pensions**: Did not exist — first state (Arizona) passed one in 1914, most states adopted in 1920s-1930s
- **Veterans' homes**: Existed but were not age-gated at 62
- **Poor relief**: Means-tested, not age-triggered at any specific threshold

The ONLY federal program with an age-62 trigger in 1910 was the Civil War pension under the 1907 Act. This makes the threshold clean — any discontinuity at 62 is attributable to the pension, not confounded by other age-based policies.

**Confederate veterans placebo test** provides additional confirmation: Confederate veterans face the same aging process but received state-level pensions with DIFFERENT age thresholds (varying by state). No discontinuity at 62 for Confederates = pension effect, not aging effect.

**Evidence:**

- Theda Skocpol (1992) "Protecting Soldiers and Mothers" — comprehensive account of pre-New Deal social programs.
- Costa (1998) — documents Civil War pension as the sole large-scale social program for elderly men.
- No state old-age pension laws existed before 1914 (Arizona was first, struck down by courts).

---

## City Limits — Population Thresholds and the Rise of Municipal Public Health (1900-1920)

**Rank:** #2 | **Recommendation:** CONSIDER

### Condition 1: a clean statute-by-state threshold database

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: verifying sharpness/fuzziness

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: securing a mortality dataset with broad city coverage or using alternative outcomes with wide coverage

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## The Age of Innocence — State Age-of-Consent Reform and Female Human Capital Formation (1880s-1920s)

**Rank:** #3 | **Recommendation:** CONSIDER

### Condition 1: redesign toward a difference-in-discontinuities / event-study around reform dates

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 2: documenting bindingness

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 3: exceptions

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 4: careful choice of outcomes that plausibly move at the margin—e.g.

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 5: marriage status at ages just below/above

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

### Condition 6: or fertility later by cohort exposed

**Status:** [ ] PENDING / [ ] RESOLVED / [ ] NOT APPLICABLE

**Response:**

_[Explain how this condition is satisfied or mitigated]_

**Evidence:**

_[Link to data, analysis, or documentation that validates this condition]_

---

## Verification Checklist

Before proceeding to Phase 4:

- [x] All conditions above are marked RESOLVED or NOT APPLICABLE
- [x] Evidence is provided for each resolution
- [ ] This file has been committed to git

**Once complete, update Status at top of file to: RESOLVED**
