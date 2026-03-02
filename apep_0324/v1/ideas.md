# Research Ideas

## Idea 1: "The Declining Returns to Trust: A Doubly Robust Analysis of Social Trust and Economic Outcomes in America, 1972-2024"

**Policy:** Social capital policy, community development, institutional design. The decline of interpersonal trust is one of the defining social trends of the past half-century (Putnam 2000). If trust causally improves economic outcomes, then policies that rebuild social capital (community programs, civic infrastructure, local governance reforms) have first-order economic returns. If not, the "social capital" policy agenda rests on weaker foundations than assumed.

**Outcome:** Individual-level economic outcomes: real family income (realinc, 67,843 obs), work status (wrkstat, 75,652 obs), weekly hours worked (hrs1, 43,328 obs), and occupational prestige/socioeconomic index (sei10, 70,360 obs). All from the GSS cumulative file.

**Treatment:** High interpersonal trust. The GSS asks: "Generally speaking, would you say that most people can be trusted or that you can't be too careful in dealing with people?" (variable: trust). Binary treatment: trust=1 ("can be trusted") vs. trust=2 ("can't be too careful"). 43,423 valid observations across 33 survey years (1972-2024).

**Identification:** Doubly robust / Augmented Inverse Probability Weighting (AIPW). The propensity score model includes: age, sex, race, education, parents' education (maeduc, paeduc), marital status, number of children, region, urban/rural classification (srcbelt), year fixed effects, and political views (polviews). The outcome model includes the same covariates with flexible functional forms (polynomials in age, education interactions). Under the assumption that conditional on these rich observables, trust is as good as randomly assigned, AIPW identifies the average treatment effect.

**Key innovation:** (a) First application of DR/AIPW to the trust-economics relationship. Prior work (Algan and Cahuc 2010, JEL) uses OLS or country-level IV. (b) 50-year time series allows testing whether the economic "returns" to trust have changed as trust itself has declined. (c) Heterogeneity analysis by race, education, and decade reveals for WHOM trust matters. (d) Sensitivity analysis using E-values (VanderWeele and Ding 2017) formally quantifies how much unobserved confounding would be needed to explain away results.

**Why it's novel:** The trust-economics literature is large but almost entirely based on cross-country regressions (Knack and Keefer 1997, Zak and Knack 2001) or instrumental variable approaches at the national level (Algan and Cahuc 2010). Individual-level studies within the US are rare and use OLS only. No study has applied DR/AIPW to individual-level trust data, despite the obvious selection concern (who trusts?) being the central methodological challenge. The 50-year GSS panel is uniquely suited for this.

**Feasibility check:** Confirmed. GSS data loaded via gssr R package (75,699 obs). Trust variable has 43,423 valid observations. Economic outcome variables have 43-75k observations. Demographics are nearly complete. BLS state unemployment data accessible via API for additional controls.

---

## Idea 2: "Believing in Bootstraps: Meritocratic Beliefs and Economic Outcomes in the General Social Survey"

**Policy:** Equal opportunity policy, education policy, welfare state design. Whether belief in meritocracy is self-fulfilling (motivates effort) or self-deceiving (masks structural barriers) has profound implications for how we design opportunity-enhancing policies.

**Outcome:** Real income (realinc), occupational prestige (prestg80, 31,434 obs), self-employment, education.

**Treatment:** Strong meritocratic beliefs. GSS variable "getahead": "Some people say that people get ahead by their own hard work; others say that lucky breaks or help from other people are more important. Which do you think is most important?" Treatment = "hard work" vs. "luck/help/both."

**Identification:** DR/AIPW with rich controls (parents' education, race, sex, age, region, year). The key threat is reverse causality (successful people attribute success to hard work). Addressed by: (a) controlling for parents' SES as a proxy for initial conditions, (b) testing whether the effect holds separately for young (18-30) vs. older respondents, (c) E-value sensitivity analysis.

**Why it's novel:** Extensive sociological literature on meritocratic beliefs (McNamee and Miller 2009) but almost no causal or quasi-causal estimation. The DR approach takes selection seriously for the first time.

**Feasibility check:** Need to verify getahead sample size in GSS. Other variables confirmed available.

---

## Idea 3: "Institutional Confidence and Financial Well-Being: Does Faith in Banks Pay Off?"

**Policy:** Financial regulation, institutional design, consumer protection. After the 2008 financial crisis, confidence in financial institutions collapsed. If confidence causally affects financial behavior (saving, investing, risk-taking), then institutional trust is a real economic input.

**Outcome:** Real family income (realinc), financial satisfaction (satfin, 71,013 obs), expected financial trajectory (finalter, 70,881 obs).

**Treatment:** High confidence in financial institutions (confinan = "a great deal of confidence"). 47,403 valid observations, 31 survey years.

**Identification:** DR/AIPW. Unique feature: the 2008 financial crisis provides a natural experiment in confidence destruction. We can test whether the trust-outcome relationship changes around 2008, and whether those who maintained confidence fared better economically. This provides a quasi-experimental dimension within the DR framework.

**Why it's novel:** Guiso, Sapienza, and Zingales (2008, ECMA) study trust and financial participation at the country level. Individual-level DR analysis of institutional confidence and financial outcomes is new.

**Feasibility check:** All variables confirmed in GSS. Large sample sizes.

---

## Idea 4: "Gender Attitudes and the Female Earnings Gap: 50 Years of Doubly Robust Evidence"

**Policy:** Gender equality policy, family leave, childcare subsidies. Whether gender attitudes causally constrain women's economic outcomes is central to the policy debate. If progressive attitudes predict higher female earnings even conditional on education and occupation, then cultural change is a complement to institutional reform.

**Outcome:** Female real income, employment status, hours worked. Restrict sample to women only.

**Treatment:** Progressive gender attitudes. GSS variable fefam: "It is much better for everyone involved if the man is the achiever outside the home and the woman takes care of the home and family." Treatment = "disagree" or "strongly disagree" (progressive). 42,920 observations, 29 survey years.

**Identification:** DR/AIPW with controls for education, age, race, marital status, number of children, region, year. Unique dimension: test whether the attitude-earnings relationship has changed as attitudes have shifted (from 34% progressive in 1977 to 67% in 2018).

**Why it's novel:** Fortin (2005, ECMA) studies anti-egalitarian attitudes and gender outcomes cross-nationally. Fernandez (2013, QJE) uses WWII participation as IV for gender norms. No individual-level DR analysis of gender attitudes and earnings within the US.

**Feasibility check:** All variables confirmed in GSS. fefam has 42,920 obs. Female subsample approximately 40,000.

---

## Idea 5: "Punitive Preferences Under Falling Crime: How Misperceptions of Crime Shape Support for the Carceral State"

**Policy:** Criminal justice reform, policing, sentencing policy. Despite dramatic crime declines since the 1990s, public demand for punitive policy has been sticky. If misperceptions of crime drive punitive attitudes, then information interventions could reduce support for mass incarceration.

**Outcome:** Support for death penalty (cappun, 47,795 obs), belief courts are "not harsh enough" (courts, 47,834 obs), fear of walking at night (fear, 33,467 obs), support for more crime spending (natcrime, 40,792 obs).

**Treatment:** Perception of worsening crime. Construct a crime misperception index using the gap between perceived crime (from GSS natcrime responses aggregated by region-year) and actual crime rates (FBI UCR data at region level). Treatment = individual is in a region-year where misperception is high.

**Identification:** DR/AIPW where treatment is region-year level misperception and outcome is individual-level punitive attitude. Controls include individual demographics, actual region-level crime rate, year fixed effects. The identification exploits within-region variation over time in the perception-reality gap.

**Why it's novel:** The criminology literature documents crime misperceptions extensively but without modern causal inference methods. Applying DR to decompose how much of punitive demand is driven by actual crime vs. misperceived crime is new.

**Feasibility check:** GSS attitudes confirmed available with large samples. FBI UCR data available at state level but GSS only has 4 regions, limiting geographic precision.
