# Reviewer Response Plan — Round 1

## Summary of Feedback

All 3 referees: MAJOR REVISION. Key shared concerns:

### 1. Identification & Pre-Trends (ALL)
- Single pre-period (2012) limits parallel trends assessment
- Large 2012→2014 shift could reflect other factors
- Treatment timing ambiguity (2014 intro vs 2017+ Post)

### 2. Inference (ALL)
- RI p-value 0.135 contradicts clustered p<0.01
- Need wild cluster bootstrap
- 96 clusters borderline

### 3. SAR Interpretation (ALL)
- ρ=0.97 likely captures correlated shocks, not just contagion
- Need SEM comparison or stronger caveats
- Reframe as descriptive, not causal

### 4. Correlated Shocks (GPT, Gemini)
- SCI proxy for socio-demographic similarity
- Need region×election FE
- Need more time-varying controls

### 5. Selection Bias (GPT)
- Dropping communes without RN candidates could bias results
- Need balanced panel or alternative outcome (votes/registered)

## Revision Workstreams

### WS1: Treatment Timing (TEXT)
- Clarify: 2014 = legal introduction, 2017+ = treatment period for main DiD
- Reframe 2012→2014 shift as descriptive, not causal evidence of activation
- Remove any causal language about the 2012-2014 gap

### WS2: Additional Robustness Checks (CODE + TEXT)
- Add region×election FE specification
- Add wild cluster bootstrap p-values for main spec
- Add balanced panel robustness (RN votes/registered as outcome)
- Add continuous dose specification (CO2 × rate_t)

### WS3: SAR Reframing (TEXT)
- Reframe structural section as descriptive propagation model
- Add explicit caveats about ρ capturing correlation vs causation
- Note absence of SEM comparison as limitation

### WS4: Prose Improvements (TEXT)
- Remove roadmap paragraph (already done)
- Fix contribution language (already done)

### WS5: Exhibits (CODE)
- Fix star discrepancy in robustness table (already done)

## Execution Order
1. WS2 (code changes — most impactful)
2. WS1 + WS3 (text changes)
3. Recompile, verify
