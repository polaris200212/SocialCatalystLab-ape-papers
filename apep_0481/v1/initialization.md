# Human Initialization
Timestamp: 2026-03-02T09:02:00Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Questions Asked

1. **Country:** Which country?
   - Options: USA, France, India, Switzerland, Nigeria, United Kingdom, Other

2. **Policy domain:** What policy area interests you?
   - Options: Surprise me (recommended), Health & public health, Labor & employment, Criminal justice, Housing & urban, Custom

3. **Method:** Which identification method?
   - Options: DiD (recommended), RDD, DR (Doubly Robust), Surprise me

4. **Data era:** Modern or historical data?
   - Options: Modern (recommended), Historical (1850-1950), Either

5. **API keys:** Did you configure data API keys?
   - Options: Yes, No

6. **External review:** Include external model reviews?
   - Options: Yes (recommended), No

7. **Risk appetite:** Exploration vs exploitation?
   - Options: Safe, Novel angle, Novel policy, Novel data, Full exploration

8. **Other preferences:** Any other preferences or constraints?

## User Responses

1. Other (best fit) — "Pick the most novel country with accessible roll-call data"
2. Custom — "Gender differences in legislative voting behavior — how female and male politicians deviate from party line in roll-call votes"
3. Surprise me → DiD (random draw)
4. Modern (recommended)
5. Yes
6. Yes (recommended)
7. Novel angle (recommended)
8. No constraints — full freedom to pick whatever makes the best paper

## Setup Results

- **Country:** Germany (selected during discovery — Bundestag MMP system provides natural experiment)
- **Domain:** Political economy / Legislative behavior
- **Method:** DiD/DDD with RDD supplementary evidence (random draw yielded DiD)
- **Data era:** Modern (1949-2021, primarily post-1983)
- **Risk appetite:** Novel angle (classic topic + novel country/data/method twist)
- **Other preferences:** None
