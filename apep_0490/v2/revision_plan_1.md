# Revision Plan — Round 1

## Overview

All three external reviewers recommend MAJOR REVISION, with the fundamental concern being statistical power (eff. N = 84-90, MDE = 1.5-2.4 log points). The paper has been revised to:

1. **Reframe the estimand** as "net effect of batch assignment" throughout (new title, abstract, introduction)
2. **Declare a primary outcome** (3-year log citations)
3. **Fix figure-estimator consistency** (loess → local linear)
4. **Add clustering/dependence discussion** (new Section 6.4.5)
5. **Honestly discuss specification sensitivity** (kernel p≈0.09-0.10; conference exclusion p<0.001)
6. **Soften all causal claims** (mechanism discussion, conclusion, welfare section)
7. **Expand limitations** (OpenAlex match rate, position measurement, sample period)
8. **Add literature** (Gerard et al. 2020 on RDD with manipulation)

## What Cannot Be Fixed Without New Data

- **Sample size / power**: Requires OpenAlex API access (rate-limited) or alternative citation sources
- **OpenAlex match rate**: Same — requires expanded matching or Semantic Scholar integration
- **Position measurement validation**: Requires full arXiv batch data via date-range API queries
- **Bundling separation**: Requires within-batch variation or IV design not available in current data

## Decision

Publish as-is with honest power limitations. The paper's contribution is the first formal causal design on arXiv listing position, with transparent methodology. The power limitation is clearly stated. Future work with larger samples can build on this design.
