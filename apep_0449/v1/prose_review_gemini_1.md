# Prose Review — Gemini 3 Flash (Round 1)

**Role:** Prose editor
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-24T16:10:03.709472
**Route:** Direct Google API + PDF
**Tokens:** 23239 in / 1197 out
**Response SHA256:** 7d79f17484deaf3b

---

# Section-by-Section Review

## The Opening
**Verdict:** Solid but academic. Needs more "Shleifer-esque" punch.
The first sentence is a strong statement of fact, but it lacks a "hook" that makes the reader *feel* the stakes. Shleifer often opens with a puzzle or a vivid contrast. 
*   **Current:** "Nearly one-third of members elected to Indian state legislative assemblies face pending criminal charges."
*   **Suggested Revision:** "In the world’s largest democracy, the path to the statehouse often runs through the courthouse. Nearly one-third of India’s state legislators face pending criminal charges—for offenses ranging from extortion to murder—yet they continue to dominate local resource allocation."

## Introduction
**Verdict:** Solid but improvable.
The flow is logical, but the preview of results is buried. You follow the "What we do" section with a "What we find" that is too modest. The finding that you *flip the sign* of a benchmark paper (Prakash et al., 2019) is your most explosive asset—it should be the lead.
*   **Correction:** Move the "Main result is surprising" paragraph (p. 3) much earlier. Don't wait until the third page to tell us you found the exact opposite of the literature's benchmark.
*   **Katz touch:** Instead of just saying "13–17 percentage points," tell us what that means for a typical district. "This represents a near-doubling of the average growth rate in luminosity for these constituencies."

## Background / Institutional Context
**Verdict:** Vivid and necessary.
Section 2.1 is excellent. "MLAs serve as the primary conduit between constituents and the state machinery" is a Glaeser-style sentence—it establishes the human power dynamic. 
*   **Improvement:** In 2.2, when discussing "pending" cases, give the reader a concrete sense of the delay. "In a judicial system where cases routinely languish for decades, a 'pending' murder charge can be a career-long companion rather than a temporary hurdle."

## Data
**Verdict:** Reads as inventory.
The data section is a bit "list-y." (e.g., "Section 4.1 describes... Section 4.2 describes..."). 
*   **Shleifer-style rewrite:** Instead of "The analysis combines five data sources," try: "To track the influence of these politicians, I link candidate criminal records to high-resolution satellite imagery and village-level census data. This allows us to see not just *how much* a district grows, but *where* the money goes."

## Empirical Strategy
**Verdict:** Clear to non-specialists.
The explanation of the RDD is intuitive. You successfully explain the logic ("one-vote criminal victory are... identical to... one-vote non-criminal victory") before hitting the reader with Equation (1).
*   **Prose Polish:** In 5.5 (Compound Treatment), you say the indicator captures a "heterogeneous bundle." Just say "criminal status is a package deal."

## Results
**Verdict:** Table narration.
This is where the Shleifer/Katz influence is most needed. You spend too much time telling us which column shows what. 
*   **Current:** "Table 2 reports the main RDD estimates... Column 2 implies that... 17.0 percentage points higher growth..."
*   **Suggested Revision:** "Electing a criminal politician sparks a surge in local luminosity. In races decided by a hair’s breadth, constituencies that seat a criminally-accused candidate see nightlights grow 17 percentage points faster than those that seat a non-criminal. But this brightness is deceptive." 

## Discussion / Conclusion
**Verdict:** Resonates.
The conclusion is strong, especially the "cautionary note" on nightlights. It reframes the tool.
*   **Final Sentence:** Your final sentence is a bit dry. End with the "Shleifer punch." 
*   **Suggested:** "In the absence of strong institutions, the lights may be on, but the state is not home."

---

## Overall Writing Assessment

- **Current level:** Close but needs polish (Strong Journal of Development Economics/AEJ: Applied level).
- **Greatest strength:** The "Conceptual Framework" (Section 3) is exceptionally clear. It sets up a "horse race" between two theories that makes the empirical results feel inevitable.
- **Greatest weakness:** Passive table narration in the Results section. You are "reporting" rather than "telling."
- **Shleifer test:** Yes. The first page is very accessible.
- **Top 5 concrete improvements:**
  1. **Kill the roadmap:** Delete "The remainder of the paper proceeds as follows..." on page 4. It’s filler. Your headers are enough.
  2. **Active Results:** Replace "Table 2 reports..." with "Criminal politicians drive a 17-point surge in nightlights (Table 2)."
  3. **Vivid Mechanisms:** In Section 6.2, use Glaeser-style energy: "Banks disappear where criminals rule." (Instead of "significantly reduce commercial bank presence").
  4. **The "Discrepancy" Lead:** Move the contradiction of Prakash et al. (2019) to the second paragraph of the Intro. That is your "hook."
  5. **Simplify Jargon:** Change "Compositional consequences" to "What growth actually looks like." (or "The makeup of growth").