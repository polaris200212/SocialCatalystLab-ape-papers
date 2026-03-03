# Initial Research Plan — apep_0494

## Research Question

Does the abolition of France's taxe d'habitation (residence tax) get capitalized into property prices, and does fiscal substitution by local governments — raising taxe foncière (property tax) to offset lost revenue — erode or reverse the benefit to households?

## Policy Background

France abolished the taxe d'habitation (TH) on primary residences between 2018 and 2023 — the largest local tax abolition in modern French history, worth €22 billion per year. The reform was phased by income:

- **2018:** 80% of households (below income thresholds) received 30% TH reduction
- **2019:** Same households received 65% reduction
- **2020:** Full exemption for 80% of households
- **2021–2023:** Remaining 20% progressively phased out (30%, 65%, 100%)

Communes were compensated by receiving a share of national taxe foncière sur les propriétés bâties (TFPB) revenue, but retained the authority to set their own TFPB voted rates. TH on secondary residences (résidences secondaires) was NOT abolished and was even surcharged in certain tourist areas.

## Identification Strategy

### Main Specification: Continuous Treatment DiD

The reform is national — all communes eventually lose TH. Identification exploits cross-commune variation in pre-reform TH rates as a measure of treatment intensity:

$$\log(p_{ict}) = \alpha + \beta \cdot (TH\_rate_c^{2017} \times Post_t) + \gamma X_{ict} + \mu_c + \lambda_t + \varepsilon_{ict}$$

where $p_{ict}$ is the transaction price per m² for property $i$ in commune $c$ at time $t$, $TH\_rate_c^{2017}$ is the commune's TH rate in 2017 (last pre-reform year), $Post_t$ is an indicator for $t \geq 2018$, and $X_{ict}$ are property controls (type, surface, rooms).

### Event Study

Replace $Post_t$ with year dummies interacted with treatment intensity:

$$\log(p_{ict}) = \alpha + \sum_{s \neq 2017} \beta_s \cdot (TH\_rate_c^{2017} \times \mathbf{1}[t=s]) + \gamma X_{ict} + \mu_c + \lambda_t + \varepsilon_{ict}$$

Normalize to $s = 2017$. Pre-trend coefficients ($\beta_{2014}, \beta_{2015}, \beta_{2016}$) should be zero.

### Design Add-ons

1. **DDD (income-based staggering):** Interact treatment intensity with commune income composition (share of households below exemption threshold). Low-income communes were effectively treated earlier and more completely.

2. **Secondary residence placebo:** TH on résidences secondaires persists. In tourist communes with high secondary-residence shares, the TH abolition for primary residences should affect only a fraction of the market. If we see effects concentrated in primary-residence transactions but not in secondary-residence-heavy markets, this rules out commune-level confounds.

3. **HonestDiD sensitivity:** Apply Rambachan and Roth (2023) bounds allowing for anticipation effects starting in 2017 (election announcement year).

### Fiscal Substitution Mechanism

**Stage 1 — First stage:** Did communes raise TF rates in response to TH loss?

$$\Delta TF\_rate_{ct} = \alpha + \delta \cdot TH\_gap_c + \theta Z_c + \varepsilon_{ct}$$

where $TH\_gap_c$ measures the fiscal gap from TH abolition (pre-reform TH revenue as share of total tax revenue).

**Stage 2 — Net capitalization:** Decompose price effect into gross TH savings minus TF offset.

## Exposure Alignment (DiD Requirements)

- **Who is treated:** All communes, with differential intensity based on pre-reform TH rates
- **Primary estimand population:** Property buyers and sellers in all French communes (excluding Alsace-Moselle)
- **Placebo/control population:** (a) Low-TH-rate communes (weak treatment), (b) Secondary residences (untreated)
- **Design:** Continuous-treatment DiD with DDD extension

## Power Assessment

- **Pre-treatment periods:** 4 years (2014–2017)
- **Treated clusters (départements):** 93 (excluding 67, 68, 57 Alsace-Moselle)
- **Post-treatment periods:** 7 years (2018–2024, with staggered onset)
- **Approximate transactions per year:** ~1 million (DVF covers universe of transactions)
- **Total observations:** ~10 million transactions over 11 years
- **MDE:** With ~10M transactions and 93 clusters, the study is massively overpowered. MDE for a 1% price effect is well within reach.

## Expected Effects and Mechanisms

**Hypothesis 1 (Capitalization):** Property prices increase in high-TH communes after abolition, as the present value of future TH savings gets capitalized into purchase prices. Expected magnitude: partial capitalization of 50–80% of PV(TH savings), following the property tax capitalization literature.

**Hypothesis 2 (Fiscal Substitution):** Communes with higher pre-reform TH dependence raise TF rates more aggressively, partially offsetting the TH abolition benefit. Expected magnitude: 20–50% offset, based on the Cour des Comptes reporting that TF increases have been "contained" but real.

**Hypothesis 3 (Net Benefit):** The net capitalization effect (gross TH savings minus TF increase) varies across communes. In communes with aggressive fiscal substitution, the reform may have been neutral or even negative for property values.

**Mechanism chain:**
1. TH abolished → household annual savings → expected future tax burden falls
2. Property prices capitalize the savings → prices rise (Gross Effect)
3. Communes lose TH revenue → fiscal gap → some raise TF rates
4. TF increase → expected annual property tax rises → partially offsets price gain (Substitution Effect)
5. Net Price Effect = Gross - Substitution

## Primary Data Sources

1. **DVF (Demandes de Valeurs Foncières):** Universe of property transactions 2014–2025. Transaction-level: price, date, commune, property type, surface.
2. **REI (Recensement des Éléments d'Imposition):** Commune-level voted tax rates (TH, TFPB) 2014–2024. Includes rates, bases, and revenue.
3. **INSEE BDM:** Commune-level socioeconomic controls (population, income, urbanization).

## Planned Robustness Checks

1. Event-study pre-trends (2014–2017)
2. HonestDiD sensitivity bounds (Rambachan and Roth 2023)
3. Secondary residence placebo
4. Leave-one-out by département
5. Alternative treatment measures (TH revenue/capita instead of TH rate)
6. Donut specifications excluding 2017 (anticipation year)
7. Heterogeneity by commune size, urbanization, housing market tightness
8. Wild cluster bootstrap at département level
