# Research Ideas

## Idea 1: Going Up Alone — Automation, Trust, and the Disappearance of the Elevator Operator (PREFERRED)

**Policy:** The 1945 NYC elevator operator strike (September 24-30, 1945) as a coordination shock that broke behavioral resistance to automated elevators. Automatic elevators were technically feasible from ~1900 but public distrust kept human operators in place for 40+ years. The strike — which cost NYC ~$100M and forced 1.5 million office workers to walk stairs — triggered rapid adoption of Otis Autotronic systems. Automated share of new installations went from 12.6% (1950) to 90%+ (1959).

**Outcome:** IPUMS full-count census microdata (1900-1950, 680M+ records on Azure) + MLP v2.0 linked panels (175M crosswalk rows on Azure). Elevator operators identified via OCC1950=761. We have: 7,943 operators in 1900 → 85,294 in 1950. Related occupations (janitors=770, porters=780, guards/doormen=763) available as comparison groups.

**Identification:**
- **Part I (Descriptive atlas):** Document the complete lifecycle of the only occupation in the Census ever fully eliminated by automation. Rise across cities, demographic composition (feminization from 1.5% to 31% female; racial stratification at ~25% Black; aging workforce), geographic concentration (34% in NYC), industry distribution.
- **Part II (The adoption puzzle — CORE CONTRIBUTION):** Why did a technology that was feasible from ~1900 take until the 1950s to be adopted? This is NOT a gradual diffusion story — it's a behavioral equilibrium (public distrust of riding alone in a machine) that persisted for decades despite economic incentives favoring automation. The 1945 strike provides causal identification: compare NYC (treated, 34% of all operators) vs comparable tall-building cities (Chicago, Philadelphia, Detroit, Boston) in the 1940→1950 census transition. The strike forced millions to experience elevator-less buildings, breaking the status quo bias.
- **Part III (Worker outcomes):** Track individual elevator operators via MLP 1940→1950 linked panel. Transition matrices to absorbing occupations, with comparison to matched building service workers (doormen, porters, janitors). This section COMPLEMENTS Part II but is not the paper's identity — the adoption puzzle is.

**Why it's novel:**
1. **Not "Feigenbaum & Gross for elevator operators."** F&G (2024 QJE) study telephone operator displacement — gradual diffusion of mechanical switching, no adoption puzzle. Our paper is fundamentally about WHY technology adoption is slow: behavioral/trust frictions kept a superior technology dormant for 40 years. The elevator case is a natural experiment in behavioral barriers to adoption, directly testing Manuelli & Seshadri (2014) vs behavioral models.
2. First rigorous economic analysis of the canonical case of full occupational automation (Bessen 2016 identified the occupation; no one has studied it)
3. Novel identification: labor strike as coordination shock — no prior paper uses a strike to identify behavioral adoption barriers
4. The paper speaks directly to AI adoption debates: technology exists, people don't trust it — what breaks the logjam?

**Feasibility check:** ✅ OCC1950=761 confirmed in all census years. ✅ 85,294 operators in 1950 census. ✅ MLP linked panels on Azure (71.8M linked pairs for 1940→1950). ✅ NYC concentration provides clean treatment. ✅ No existing economics paper on this topic.

---

## Idea 2: The Last Operators — Race, Gender, and the Queue for Automation's Casualties

**Policy:** Same 1945 NYC elevator operator strike (September 24-30, 1945), but focused on racial and gender dimensions of displacement. The occupation was ~25% Black and feminized rapidly (1.5% female in 1900 → 31% by 1950).

**Outcome:** IPUMS full-count census microdata (1900-1950) + MLP v2.0 linked panels. Race, sex, age available in all census years.

**Identification:** Within-occupation variation in exit timing by race × sex × age, conditioning on city. Test whether automation followed a "last hired, first fired" pattern or whether demographic hierarchy determined who was displaced first.

**Why it's novel:** Adds inequality dimension. Connects to Derenoncourt (2022), Collins & Wanamaker (2022).

**Feasibility check:** ✅ Race/sex available. ✅ Large sample. ⚠️ Weaker identification — more descriptive. Best incorporated into Idea 1 as a section.

---

## Idea 3: Forty Years of Distrust — A Structural Model of Behavioral Barriers to Technology Adoption

**Policy:** Same elevator automation setting — the 40-year gap between technical feasibility (~1900) and widespread adoption (1950s). The 1945 NYC strike serves as moment condition.

**Outcome:** City-level elevator operator employment shares from IPUMS full-count census (1900-1950), combined with building stock data and wage series from BLS Historical Statistics.

**Identification:** Structural estimation using the 1945 strike as a moment condition to identify the behavioral friction parameter.

**Why it's novel:** First structural estimation of behavioral frictions in technology adoption using a natural experiment.

**Feasibility check:** ⚠️ Ambitious. Building cost data needed. Risky as standalone. Elements can be incorporated into Idea 1's adoption puzzle section.

---

## Idea 4: Building Vertical — Skyscrapers, Elevator Operators, and the Geography of Urban Growth

**Policy:** The elevator enabled vertical urbanization across US cities, 1900-1950.

**Outcome:** Census occupation data from IPUMS full-count census (1900-1950) + building height/permit data (limited pre-1950 availability).

**Identification:** Primarily descriptive with cross-city variation.

**Why it's novel:** Links technology to urban form through the labor market channel.

**Feasibility check:** ⚠️ Building height data sparse. Weaker than Idea 1.

---

## Recommendation

**Idea 1 is the clear winner.** The paper's identity is the ADOPTION PUZZLE — why technology sits unused for decades — not the displacement tracking (which is F&G's territory). The strike as coordination shock provides novel identification that no prior paper has used. Elements of Ideas 2-4 enrich the paper as sections within this framework.

Structure: Hook (the only eliminated occupation) → Atlas (rich descriptive lifecycle) → The Puzzle (why 40 years?) → The Shock (1945 strike breaks the equilibrium) → The Workers (who absorbed the displaced, how did they fare?). This is fundamentally a technology adoption paper with a labor dimension, not a labor displacement paper with a technology dimension.
