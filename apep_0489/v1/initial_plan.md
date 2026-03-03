# Initial Research Plan — apep_0489

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

**Identifying Assumption:** Parallel trends in transition space — absent treatment, the evolution of career transition probabilities would have been the same in treatment and control counties.

**Testable Pre-Trends:** Compare pre-treatment adapter predictions across treatment and control groups.

## Expected Effects and Mechanisms

Based on Kline & Moretti (2014), the TVA caused:
- Agriculture → Manufacturing transition (dominant effect)
- General industrial development in the region
- Possible effects on labor force participation

We expect:
- SVD of the weight-space DiD to be approximately rank-1 (single dominant treatment dimension: agricultural transformation)
- The dominant singular vector to align with Agriculture → Manufacturing
- Heterogeneous effects by age (young workers more mobile) and race (racial barriers in TVA era)

## Primary Specification

- **Unit:** Individual linked across 1920-1930-1940 censuses
- **Treatment:** Residence in a TVA service area county
- **Pre-period:** 1920→1930 transition
- **Post-period:** 1930→1940 transition
- **Model:** CensusCareerModel (1.3M params, 576 life-state tokens, pre-trained on 10.85M individuals)
- **LoRA:** r=8, alpha=16, targeting decoder attention + FFN layers

## Exposure Alignment

- **Who is actually treated?** Individuals residing in TVA service area counties
- **Primary estimand population:** Males aged 18-65 in TVA counties
- **Placebo/control population:** Males aged 18-65 in non-TVA counties in same/adjacent states
- **Design:** Standard DiD (binary treatment, two periods)

## Power Assessment

- **Pre-treatment periods:** 1 (1920→1930)
- **Post-treatment periods:** 1 (1930→1940)
- **Treated counties:** ~125 TVA service area counties
- **Control counties:** Comparable non-TVA counties
- **Sample size:** ~10.85M linked individuals total; TVA region subset ~1-2M
- **MDE:** With 10.85M individuals, even small distributional shifts (1-2pp in individual transition cells) should be detectable

## Planned Robustness Checks

1. **Synthetic validation:** 8 DGPs with known treatment effects, 5 ablation studies
2. **Pre-trends test:** Pre-treatment adapter predictions parallel across groups
3. **Traditional DiD comparison:** County-level TWFE with fixest (replicating Kline & Moretti)
4. **Alternative control groups:** (a) non-TVA counties in same states, (b) proposed-but-never-approved authority counties
5. **Architecture ablations:** Model size, LoRA rank, head type, masking strategy, pre-training strategy
6. **Heterogeneity:** By age, initial occupation, race
7. **SVD rank analysis:** Distinguish real effects (low-rank) from noise (full-rank)
