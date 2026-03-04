# Research Plan (Working) — paper_199

## Research Question

Can transformer neural networks, combined with difference-in-differences logic applied in representation space, characterize how place-based policies reshape full career trajectory distributions?

## Identification Strategy

**Four-Adapter DiD with Temporal Loss Masking:**

1. Pre-train a causal transformer on ALL career sequences nationally (region-blind base model)
2. Fine-tune 4 LoRA adapters on the 2×2 DiD cells:
   - Δθ_{T,pre}: treatment group, loss only at pre-treatment positions
   - Δθ_{T,post}: treatment group, loss only at post-treatment positions
   - Δθ_{C,pre}: control group, loss only at pre-treatment positions
   - Δθ_{C,post}: control group, loss only at post-treatment positions
3. Compute Δ_DiD = (Δθ_{T,post} - Δθ_{T,pre}) - (Δθ_{C,post} - Δθ_{C,pre})

**Identifying Assumption:** Parallel trends in transition space — absent treatment, the evolution of career transition probabilities would have been the same in treatment and control counties. In representation space, this means the learned embeddings of career trajectories would have evolved identically.

**Testable Pre-Trends:** Compare pre-treatment adapter predictions across treatment and control groups. Violations appear as non-zero pre-treatment double-difference.

## Expected Effects and Mechanisms

Based on Kline & Moretti (2014), the TVA caused:
- Agriculture → Manufacturing transition (dominant effect)
- General industrial development in the region
- Possible effects on labor force participation and migration

We expect:
- SVD of the weight-space DiD to be approximately rank-1 (single dominant treatment dimension: agricultural transformation)
- The dominant singular vector to align with Agriculture → Manufacturing in the embedding space
- Heterogeneous effects by age (young workers more mobile), initial occupation (farmers most affected), and race (racial barriers in TVA era)
- Non-Markov effects: second- and third-order transitions (grandfather's occupation) more pronounced in treatment group

## Primary Specification

- **Unit:** Individual linked across 1920-1930-1940 censuses
- **Treatment:** Residence in a TVA service area county
- **Pre-period:** 1920→1930 transition
- **Post-period:** 1930→1940 transition
- **Model:** CensusCareerModel (1.3M params, 576 life-state tokens, pre-trained on 10.85M individuals)
- **LoRA:** r=8, alpha=16, targeting decoder attention + FFN layers

## Exposure Alignment

- **Who is actually treated?** Individuals residing in TVA service area counties (county of residence in 1930)
- **Primary estimand population:** Males aged 18-65 in TVA counties in 1930 census
- **Placebo/control population:** Males aged 18-65 in non-TVA counties in same/adjacent states
- **Design:** Standard DiD (binary treatment, two periods)
- **Sample:** ~1-2M TVA individuals, ~7-8M control individuals

## Power Assessment

- **Pre-treatment periods:** 1 (1920→1930)
- **Post-treatment periods:** 1 (1930→1940)
- **Treated units (counties):** ~125 TVA service area counties
- **Control counties:** ~200+ comparable non-TVA counties
- **Sample size:** ~10.85M linked individuals total; TVA region subset ~1-2M
- **MDE:** With 10.85M individuals and 576-dimensional outcome, even small distributional shifts (1-2pp in individual transition cells) should be detectable

## Planned Robustness Checks

1. **Synthetic validation:** 8 DGPs with known treatment effects, 5 ablation studies
2. **Pre-trends test:** Pre-treatment adapter predictions parallel across groups
3. **Traditional DiD comparison:** County-level TWFE with fixest (replicating Kline & Moretti)
4. **Alternative control groups:** (a) non-TVA counties in same states, (b) proposed-but-never-approved authority counties
5. **Architecture ablations:** Model size, LoRA rank, head type, masking strategy, pre-training strategy
6. **Heterogeneity analysis:** By age cohort, initial occupation (farmer vs. non-farmer), race (White vs. Black)
7. **SVD rank analysis:** Distinguish real effects (low-rank) from noise (full-rank)
8. **Sensitivity to pre-training:** Compare results with alternative national models or subsamples

## Key Revision Themes

**Deepening Theoretical Exposition:**
- Make parallel trends assumption explicit in representation space
- Provide intuition for why double-difference in weights identifies distributional treatment effects
- Discuss when the method works and when it fails

**Strengthening Connection to Structural Economics:**
- Frame heterogeneous effects in terms of career choice theory
- Interpret distributional effects as changes in the choice set facing workers
- Connect to migration and human capital literature

**Enhanced Methodological Clarity:**
- Clarify distinction between task vector arithmetic and causal application
- Explain why transformer embeddings are natural for distributional causal inference
- Discuss limitations and scope conditions

**Expanded Heterogeneity Analysis:**
- By age cohort, initial occupation, and race
- Quantify which workers/occupations benefited most from TVA
- Assess distributional incidence of place-based policy

## Status: Active
