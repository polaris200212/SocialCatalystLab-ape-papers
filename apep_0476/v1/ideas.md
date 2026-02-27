# Research Ideas

## Idea 1: Linking Americans Across the Half-Century: A Descriptive Atlas of the MLP Census Panel, 1900-1950

**Policy/Context:** The IPUMS Multigenerational Longitudinal Panel (MLP) v2.0 crosswalk enables linking the same individuals across consecutive U.S. decennial censuses from 1900 to 1950. This paper documents the construction, quality, and descriptive content of five decade-pair panels and a three-census balanced panel built from MLP + full-count IPUMS census data.

**Data:** MLP crosswalk v2.0 (175.6M person-year observations), six IPUMS full-count census extracts (1900-1950, ~680M total records), ABE census linking project crosswalks for validation.

**Approach:** Purely descriptive. Document link rates by decade, demographics, and geography. Construct balance tables comparing linked vs unlinked populations. Build IPW weights for selection correction. Present descriptive patterns: occupational mobility, interstate migration, demographic transitions, urbanization, and literacy trends — all at the individual level using within-person changes.

**Why it's novel:** No existing paper documents the full 1900-1950 MLP panel infrastructure with systematic diagnostics, selection analysis, and demographic atlases across all five decade pairs. Most historical linking papers focus on a single pair (typically 1920-1940) for a specific causal question. This paper provides the reusable infrastructure and descriptive foundation for an entire research program.

**Feasibility:** Data is built and hosted on Azure. All pipeline scripts exist in `scripts/build_mlp_panel/`. The paper documents what we've already constructed.
