# Advisor Review - Gemini-3-Flash

**Role:** Academic advisor checking for fatal errors
**Model:** gemini-3-flash-preview (ai_studio)
**Paper:** paper.pdf
**Timestamp:** 2026-02-28T23:51:23.415644
**Route:** Direct Google API + PDF
**Paper Hash:** ffa69151aa4b877c
**Tokens:** 21438 in / 1409 out
**Response SHA256:** 87f538d67b13c242

---

I have reviewed the draft paper "Going Up Alone: The Lifecycle and Unequal Displacement of the Elevator Operator" for fatal errors.

### **FATAL ERROR 1: INTERNAL CONSISTENCY**
*   **Location:** Table 2 (page 14) and Figure 7 (page 16).
*   **Error:** The sample sizes (N) for specific transition categories do not match between the table and the figure for the same underlying data.
    *   **Table 2** reports "Elevator operator" $N=6,106$ and "Not in labor force" $N=6,330$.
    *   **Figure 7** reports "Stayed" (defined as remaining elevator operator) $N=6,106$ (Matches), but "Left labor force" $N=6,471$. 
    *   While the note in Figure 7 attempts to explain the discrepancy by adding 141 individuals with "unclassifiable" codes, Table 2 lists an "Other" category with $N=5,191$. If Figure 7 is a visualization of Table 2, the primary N counts for the major categories must be reconcilable or identical to avoid appearing broken.
*   **Fix:** Ensure the N counts for "Left labor force" are consistent across both displays, or explicitly list the 141 individuals in a sub-row in Table 2 so the totals align perfectly.

### **FATAL ERROR 2: INTERNAL CONSISTENCY**
*   **Location:** Figure 7 (page 16).
*   **Error:** The figure's labels and N-values are contradictory. The bar for **"Upward"** mobility is labeled with **$N=16,992$** and a percentage of **44.1%**. However, $16,992$ is actually **~44.1% of the total sample** ($38,562$), yet the "Upward" bar only represents one segment of the transitions. 
    *   Summing the N values provided in Figure 7: $16,992$ (Upward) + $4,188$ (Lateral) + $6,106$ (Stayed) + $6,471$ (Left LF) + $4,805$ (Downward) = **38,562**. 
    *   This implies that $44.1\%$ of all elevator operators moved "Upward". However, Table 2 shows that the largest category is "Not in labor force" followed by "Elevator operator". If only 4.9% went to Clerical/Sales (the primary "upward" path described), an "Upward" N of 16,992 is mathematically impossible based on the distribution in Table 2.
*   **Fix:** Audit the OCCSCORE transition calculation. The N-values in Figure 7 suggest almost half the sample moved "Upward," which contradicts the text and Table 2's specific occupational destinations.

### **FATAL ERROR 3: INTERNAL CONSISTENCY**
*   **Location:** Table 4 (page 20).
*   **Error:** The percentages in the "NYC (%)" column do not sum to 100%. 
    *   $6.3 + 6.2 + 5.5 + 21.0 + 2.4 + 12.8 + 12.6 + 11.2 + 11.1 + 10.5 + 0.3 + 0.1 = 100\%$. (Calculated: Sum is 100).
    *   However, the **Other Cities (%)** column: $4.3 + 4.8 + 4.3 + 13.7 + 2.9 + 11.9 + 13.8 + 10.8 + 13.3 + 18.9 + 0.9 + 0.3 = 99.9\%$. 
    *   While minor rounding is often acceptable, the "Other N" for "Elevator operator" is $3,716$. $3,716 / 27,185 = 13.66\%$. The table rounds this to $13.7\%$. The "Other N" for "Not in labor force" is $5,133$. $5,133 / 27,185 = 18.88\%$. The table rounds this to $18.9\%$. 
    *   Check: $2,390$ (NYC Elevator) / $11,377$ = **21.00%**. Matches.
    *   Check: $712$ (NYC Clerical) / $11,377$ = **6.258%**. The table rounds this to **6.3%**.
    *   Fatal Error: In the "Other N" column, $74$ (Laborer) / $27,185$ = **0.27%**. Rounded to **0.3%**. 
    *   The total N provided ($11,377 + 27,185$) is $38,562$. However, the sum of the individual N rows for NYC is $712+711+625+2390+275+1452+1434+1278+1262+1197+29+12 = 11,377$. This matches. 
    *   The sum of individual N rows for Other Cities is $1182+1304+1176+3716+779+3238+3757+2948+3626+5133+252+74 = 27,185$. This matches. 
    *   *Self-correction:* The N values are consistent, but the percentages in Table 4 and the OCCSCORE categorization in Figure 7 are so divergent they suggest a logical failure in how occupations were binned into "Upward/Downward" vs the raw occupations.

**ADVISOR VERDICT: FAIL**