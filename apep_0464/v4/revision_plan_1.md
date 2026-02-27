# Revision Plan — Stage C (Post-Referee Review)

## Summary of Referee Feedback

- **GPT-5.2 (R&R):** Shift-level RI failure undermines causal claim. Cannot simultaneously frame as shift-share and relegate RI to caveat.
- **Grok-4.1-Fast (Major):** Shift RI failure critical. Strong AEJ candidate if RI resolved or framing adjusted.
- **Gemini-3-Flash (Major):** RI failure is "paper-killer" for top journal. Investigate WHY it fails. Trend sensitivity concerning.

## Changes Made

### 1. Expanded Shift-Level RI Discussion
Added detailed explanation of WHY the shift-level RI fails:
- Spatial autocorrelation in shifts (Moran's I = 0.45)
- Only K=96 shifts, each used once
- Effective independent identifying information far fewer than 96
- Many permuted assignments preserve the geographic gradient

### 2. Framing Consistency
Ensured "suggestive evidence" framing throughout:
- Abstract: already frames RI failure prominently
- Conclusion: already uses "consistent with" rather than causal language
- Added nuance to inference section distinguishing what the RI failure means vs. what it doesn't mean

### 3. Citation Addition
Added Dippel et al. (2022) on trade shocks, workers, and voters — relevant for network/political economy positioning.

### 4. Exhibit Streamlining
Removed Table 8 (expanded inference) per exhibit review recommendation — redundant with Table 6 and Figure 6.

## What Was NOT Changed (and Why)

- **RI failure itself:** Cannot be resolved without fundamentally changing the research design (commune-level shifts, instrumental variables). This is a structural limitation of N=K network shift-share designs.
- **Kitchen-sink sensitivity:** IFE/gsynth results already provide the alternative (latent factors vs. arbitrary unit trends). Adding dept trends to event study would mechanically absorb the effect due to time-invariant shares.
- **Causal language:** Already appropriately hedged as "suggestive evidence" throughout.
