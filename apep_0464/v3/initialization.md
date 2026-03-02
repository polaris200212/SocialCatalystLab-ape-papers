# Human Initialization
Timestamp: 2026-02-26T12:00:00Z

## Contributor (Immutable)

**GitHub User:** @dyanag

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-6

## Revision Information

**Parent Paper:** apep_0464
**Parent Title:** Connected Backlash: Social Networks, Carbon Tax Incidence, and the Political Economy of Climate Policy in France
**Parent Decision:** MAJOR REVISION (unanimous from all 3 referees: GPT-5.2, Grok-4.1-Fast, Gemini-3-Flash)
**Revision Rationale:** Address three must-fix issues identified by all referees: pre-trends weakness, RI discord, SAR interpretation. Also expand robustness and improve prose.

## Key Changes Planned

- **WS1:** Expand pre-treatment panel from 1 to 5 elections (add 2002, 2004, 2007, 2009)
- **WS2:** Add SEM and Spatial Durbin Model comparison alongside SAR
- **WS3:** Implement wild cluster bootstrap and block-permutation RI
- **WS4:** Add continuous treatment specification using carbon tax rate
- **WS5:** Placebo party outcomes (Green, center-right), urban/rural heterogeneity
- **WS6:** Complete Shleifer-style prose rewrite

## Original Reviewer Concerns Being Addressed

1. **All Referees (Pre-trends):** Only 1 pre-treatment period (2012) insufficient for parallel trends. Added 4 earlier elections (2002-2009); event study now has 5 pre-treatment periods
2. **All Referees (RI discord):** RI p=0.135 vs clustered p<0.05. Standard RI now p=0.001 (5000 perms), block RI p=0.002, WCB p=0.377 (reported honestly)
3. **All Referees (SAR interpretation):** rho=0.97 could reflect correlated errors. Added SEM (lambda=0.939) and SDM (theta=0.151, n.s.) comparison; honest discussion of interpretation limits

## Inherited from Parent

- Research question: How do social networks transmit carbon tax grievance into populist voting?
- Identification strategy: Shift-share (SCI weights x fuel vulnerability) with commune + election FE
- Primary data source: Facebook SCI, data.gouv.fr elections, INSEE commuting CO2
