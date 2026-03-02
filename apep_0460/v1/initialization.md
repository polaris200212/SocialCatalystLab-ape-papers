# Human Initialization
Timestamp: 2026-02-26T12:08:39Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Questions Asked

1. **Country:** Which country?
   - Options: USA, France, India, Switzerland, Other

2. **Method:** Which identification method?
   - Options: DiD (recommended), RDD, DR (Doubly Robust), Surprise me

3. **API keys:** Are French API credentials configured? (INSEE Sirene, PISTE/Légifrance)
   - Options: Yes, No

4. **External review:** Include external model reviews?
   - Options: Yes (recommended), No

5. **Other preferences:** Any other preferences or constraints?

## User Responses

1. France
2. Surprise me — but a convincing RDD would be superior. Or IV that doesn't suck. Maybe a similar paper as the Facebook paper from the US on network externalities using minimum wage, but here instead we focus on Europe, and we avoid minimum wage policy shocks, but some other non-French policy shock within Europe.
3. Yes (provided INSEE Sirene + PISTE credentials)
4. Yes (Recommended)
5. Surprise me — go wild, find the most ambitious, novel thing possible. Explicitly referenced apep_0185 (SCI paper) as the model to build on.

## Setup Results

- **Country:** France
- **Domain:** Cross-border network externalities / European policy spillovers
- **Method:** Shift-share IV (SCI-weighted cross-border shock exposure)
- **Data era:** Modern (2014-2022)
- **Risk appetite:** Full exploration
- **Other preferences:** Beat apep_0185. Use European SCI data. Non-French policy shock propagating through social networks to French local outcomes. Avoid minimum wage.
