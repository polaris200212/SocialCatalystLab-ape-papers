#!/usr/bin/env python3
"""
00e_newspaper_geography.py — Going Up Alone v5 (apep_0478)
Parse newspaper names to extract city/state, apply keyword classification
per article, and aggregate by year x city x category.

Input:  data/newspaper_matches_raw.parquet  (71,894 articles)
Output: data/newspaper_by_city.csv          (year x city x category aggregation)
        data/newspaper_classified_articles.csv (per-article classification with geography)
"""

import re
import sys
import logging
from pathlib import Path

import pandas as pd
import pyarrow.parquet as pq

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────────────────────
# Paths
# ─────────────────────────────────────────────────────────────────────────────

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
INPUT_FILE = DATA_DIR / "newspaper_matches_raw.parquet"
OUTPUT_CITY = DATA_DIR / "newspaper_by_city.csv"
OUTPUT_ARTICLES = DATA_DIR / "newspaper_classified_articles.csv"

# ─────────────────────────────────────────────────────────────────────────────
# Geography extraction
# ─────────────────────────────────────────────────────────────────────────────

# Pattern 1: "(City, State) YYYY-YYYY" or "(City, State) YYYY-current"
# Also handles bracketed state: "(Washington [D.C.]) 1902-1939"
# Also handles multi-part locations: "(Mankato, Blue Earth County, Minn.)"
LOCATION_RE = re.compile(
    r'\(([^)]+)\)\s*\d{4}-(?:\d{4}|current)'
)

# US state abbreviations and full names → canonical state name
STATE_ABBREV = {
    "Ala.": "Alabama", "Alaska": "Alaska", "Ariz.": "Arizona",
    "Ark.": "Arkansas", "Cal.": "California", "Calif.": "California",
    "Colo.": "Colorado", "Conn.": "Connecticut", "D.C.": "District of Columbia",
    "Del.": "Delaware", "Fla.": "Florida", "Ga.": "Georgia",
    "Hawaiian Islands": "Hawaii", "Idaho": "Idaho", "Ill.": "Illinois",
    "Ind.": "Indiana", "Iowa": "Iowa", "Kan.": "Kansas", "Kansas": "Kansas",
    "Ky.": "Kentucky", "La.": "Louisiana", "Me.": "Maine",
    "Md.": "Maryland", "Mass.": "Massachusetts", "Mich.": "Michigan",
    "Minn.": "Minnesota", "Minn. ;": "Minnesota",
    "Miss.": "Mississippi", "Mo.": "Missouri",
    "Mont.": "Montana", "Neb.": "Nebraska", "Nev.": "Nevada",
    "N.H.": "New Hampshire", "N.J.": "New Jersey", "N.M.": "New Mexico",
    "N.Y.": "New York", "N.C.": "North Carolina", "N.D.": "North Dakota",
    "Dakota [N.D.]": "North Dakota",
    "Ohio": "Ohio", "Okla.": "Oklahoma", "Or.": "Oregon", "Oregon": "Oregon",
    "Pa.": "Pennsylvania", "R.I.": "Rhode Island", "S.C.": "South Carolina",
    "S.D.": "South Dakota", "Tenn.": "Tennessee", "Tex.": "Texas",
    "Texas": "Texas",
    "Utah": "Utah", "Vt.": "Vermont", "Va.": "Virginia",
    "Va. [W. Va.]": "West Virginia", "W. Va.": "West Virginia",
    "Wash.": "Washington", "W.Va.": "West Virginia",
    "Wis.": "Wisconsin", "Wyo.": "Wyoming",
    # Bracketed forms
    "[D.C.]": "District of Columbia",
    "[N.Y.]": "New York",
    "[Pa.]": "Pennsylvania",
    "[Ind.]": "Indiana",
    "[Neb.]": "Nebraska",
}

# Known newspaper name → (city, state) for papers without location in parens
KNOWN_NEWSPAPERS = {
    "Evening star.": ("Washington", "District of Columbia"),
    "New-York tribune.": ("New York", "New York"),
    "The Washington times.": ("Washington", "District of Columbia"),
    "The San Francisco call.": ("San Francisco", "California"),
    "The Washington herald.": ("Washington", "District of Columbia"),
    "Omaha daily bee.": ("Omaha", "Nebraska"),
    "Evening journal.": ("New York", "New York"),  # NY Evening Journal
    "Los Angeles herald.": ("Los Angeles", "California"),
    "The Birmingham age-herald.": ("Birmingham", "Alabama"),
    "The age-herald.": ("Birmingham", "Alabama"),
    "New Britain herald.": ("New Britain", "Connecticut"),
    "The Bridgeport evening farmer.": ("Bridgeport", "Connecticut"),
    "The Bridgeport times and evening farmer.": ("Bridgeport", "Connecticut"),
    "The Minneapolis journal.": ("Minneapolis", "Minnesota"),
    "The evening world.": ("New York", "New York"),
    "The sun.": ("New York", "New York"),
    "The Saint Paul globe.": ("Saint Paul", "Minnesota"),
    "Arizona republican.": ("Phoenix", "Arizona"),
    "Detroit evening times.": ("Detroit", "Michigan"),
    "The Detroit times.": ("Detroit", "Michigan"),
    "The Portland daily press.": ("Portland", "Maine"),
    "Pine Bluff daily graphic.": ("Pine Bluff", "Arkansas"),
    "The Waterbury Democrat.": ("Waterbury", "Connecticut"),
    "Waterbury Democrat.": ("Waterbury", "Connecticut"),
    "Waterbury evening Democrat.": ("Waterbury", "Connecticut"),
    "The Wilmington morning star.": ("Wilmington", "North Carolina"),
    "Every evening, Wilmington daily commercial.": ("Wilmington", "Delaware"),
    "Norwich bulletin.": ("Norwich", "Connecticut"),
    "The Montgomery advertiser.": ("Montgomery", "Alabama"),
    "Denver labor bulletin.": ("Denver", "Colorado"),
    "Imperial Valley press.": ("El Centro", "California"),
    "Henderson daily dispatch.": ("Henderson", "North Carolina"),
    "The New York herald.": ("New York", "New York"),
    "The Savannah morning news.": ("Savannah", "Georgia"),
    "The St. Louis Republic.": ("St. Louis", "Missouri"),
    "The Indianapolis times.": ("Indianapolis", "Indiana"),
    "Newark evening star and Newark advertiser.": ("Newark", "New Jersey"),
    "Perth Amboy evening news.": ("Perth Amboy", "New Jersey"),
    "The Cairo bulletin.": ("Cairo", "Illinois"),
    "The Colorado statesman.": ("Denver", "Colorado"),
    "Bisbee daily review.": ("Bisbee", "Arizona"),
    "Daily Kennebec journal.": ("Augusta", "Maine"),
    "Grand Forks daily herald.": ("Grand Forks", "North Dakota"),
    "Great Falls daily tribune.": ("Great Falls", "Montana"),
    "Bismarck daily tribune.": ("Bismarck", "North Dakota"),
    "The Bismarck tribune.": ("Bismarck", "North Dakota"),
    "The Jasper news.": ("Jasper", "Alabama"),
    "The Sentinel=record.": ("Hot Springs", "Arkansas"),
    "Washington sentinel.": ("Washington", "District of Columbia"),
    "The Washington bee.": ("Washington", "District of Columbia"),
    "The National tribune.": ("Washington", "District of Columbia"),
    "The Washington weekly post.": ("Washington", "District of Columbia"),
    "The daily morning journal and courier.": ("New Haven", "Connecticut"),
    "The Atlanta constitution.": ("Atlanta", "Georgia"),
    "Chicago eagle.": ("Chicago", "Illinois"),
    "Milford chronicle.": ("Milford", "Connecticut"),
    "Smyrna times.": ("Smyrna", "Delaware"),
    "The Paducah evening sun.": ("Paducah", "Kentucky"),
    "The Paducah sun.": ("Paducah", "Kentucky"),
    "Middletown transcript.": ("Middletown", "Connecticut"),
    "The Topeka state journal.": ("Topeka", "Kansas"),
    "Morris tribune.": ("Morris", "Minnesota"),
    "Cheyenne record.": ("Cheyenne", "Wyoming"),
    "Albuquerque morning journal.": ("Albuquerque", "New Mexico"),
    "The evening times.": ("Washington", "District of Columbia"),
    "The colored American.": ("Washington", "District of Columbia"),
    "South Bend news-times.": ("South Bend", "Indiana"),
    "The Omaha guide.": ("Omaha", "Nebraska"),
    "The Omaha morning bee.": ("Omaha", "Nebraska"),
    "The Sun and the New York herald.": ("New York", "New York"),
    "The Key West citizen.": ("Key West", "Florida"),
    "The Jersey City news.": ("Jersey City", "New Jersey"),
    "The Pensacola journal.": ("Pensacola", "Florida"),
    "Rock Island Argus.": ("Rock Island", "Illinois"),
    "La gaceta.": ("Tampa", "Florida"),
    "La opinión.": ("Los Angeles", "California"),
    "Tombstone epitaph.": ("Tombstone", "Arizona"),
    "The Ocala evening star.": ("Ocala", "Florida"),
    "Honolulu star-bulletin.": ("Honolulu", "Hawaii"),
    "Free press.": ("Detroit", "Michigan"),
    "Indiana daily times.": ("Indianapolis", "Indiana"),
    "Daily camera.": ("Boulder", "Colorado"),
    "The Fargo forum and daily republican.": ("Fargo", "North Dakota"),
    "Connecticut western news.": ("Salisbury", "Connecticut"),
    "United labor bulletin.": ("Denver", "Colorado"),
    "The Bemidji daily pioneer.": ("Bemidji", "Minnesota"),
    "The Bemidji pioneer.": ("Bemidji", "Minnesota"),
    "Minneapolis spokesman.": ("Minneapolis", "Minnesota"),
    "St. Paul recorder.": ("Saint Paul", "Minnesota"),
    "Montana labor news.": ("Butte", "Montana"),
    "The Richmond palladium and sun-telegram.": ("Richmond", "Indiana"),
    "Seward daily gateway.": ("Seward", "Nebraska"),
    "Hopkinsville Kentuckian.": ("Hopkinsville", "Kentucky"),
    "The Delaware State news.": ("Dover", "Delaware"),
}

# Key cities to track (all others → "Other")
KEY_CITIES = {
    "New York", "Washington", "Chicago", "San Francisco", "Los Angeles",
    "Philadelphia", "Boston", "Detroit", "Omaha", "Minneapolis",
    "Birmingham", "Seattle",
}


def parse_location(newspaper_name: str) -> tuple[str, str]:
    """
    Extract (city, state) from newspaper_name.

    Returns ("", "") if no location can be determined.
    """
    # First try the known newspaper lookup (exact match)
    if newspaper_name in KNOWN_NEWSPAPERS:
        return KNOWN_NEWSPAPERS[newspaper_name]

    # Try regex on the parenthetical pattern
    m = LOCATION_RE.search(newspaper_name)
    if m:
        loc_str = m.group(1).strip()
        return _parse_location_string(loc_str)

    return ("", "")


def _parse_location_string(loc_str: str) -> tuple[str, str]:
    """
    Parse a location string like "Washington, D.C." or "Butte, Mont."
    or "Mankato, Blue Earth County, Minn." or "Washington [D.C.]"
    """
    # Handle bracketed state: "Washington [D.C.]" or "New York [N.Y.]"
    bracket_m = re.match(r'^(.+?)\s*\[([^\]]+)\]$', loc_str)
    if bracket_m:
        city = bracket_m.group(1).strip().rstrip(",")
        state_raw = bracket_m.group(2).strip()
        state_key = f"[{state_raw}]"
        state = STATE_ABBREV.get(state_key, STATE_ABBREV.get(state_raw, state_raw))
        return (city, state)

    # Split by comma
    parts = [p.strip() for p in loc_str.split(",")]

    if len(parts) == 1:
        # Just a city name, no state
        return (parts[0], "")

    # City is always the first part
    city = parts[0]

    # State is the last part (skip county names in between)
    state_raw = parts[-1].strip()

    # Handle trailing semicolons: "Minn. ;"
    state_raw = state_raw.rstrip("; ")

    state = STATE_ABBREV.get(state_raw, state_raw)

    # Also try the full last-part string with original spacing
    if state == state_raw and state_raw not in STATE_ABBREV:
        # Try with the original (before rstrip)
        orig_last = parts[-1].strip()
        state = STATE_ABBREV.get(orig_last, state_raw)

    return (city, state)


# ─────────────────────────────────────────────────────────────────────────────
# Keyword classification (deterministic, matches existing year-level totals)
# ─────────────────────────────────────────────────────────────────────────────

# Compile patterns once for performance

# AUTOMATION keywords
AUTOMATION_RE = re.compile(
    r'(?:'
    r'auto(?:matic|mated)\s+elevator'
    r'|push[\s\-]?button\s+elevator'
    r'|self[\s\-]?service\s+elevator'
    r'|operatorless\s+elevator'
    r'|elevator\s+(?:auto(?:matic|mated)|push[\s\-]?button|self[\s\-]?service|operatorless)'
    r'|automatic\s+(?:operation|control|signal)'
    r'|push[\s\-]?button\s+(?:operation|control)'
    r'|operatorless'
    r'|self[\s\-]?service\s+(?:lift|car)'
    r'|without\s+(?:an?\s+)?operator'
    r'|eliminat\w*\s+(?:the\s+)?operator'
    r'|replac\w*\s+(?:the\s+)?operator'
    r'|no\s+(?:elevator\s+)?operator\s+(?:needed|required|necessary)'
    r')',
    re.IGNORECASE
)

# LABOR keywords
LABOR_RE = re.compile(
    r'(?:'
    r'(?:elevator\s+)?(?:operator|starter|attendant)\s*(?:\'?s?\s+)?(?:union|local|wage|salar|pay\b|hour|working\s+condition|organiz)'
    r'|union\s+(?:of\s+)?(?:elevator|building)\s+(?:operator|employee|worker)'
    r'|A\.?\s*F\.?\s*(?:of\s+)?L\.?|C\.?\s*I\.?\s*O\.?\b'
    r'|building\s+(?:service|employee|worker)\s+(?:union|local|international)'
    r'|BSEIU|Local\s+32'
    r'|wage\s+(?:demand|increase|raise|scale|negotiat)'
    r'|(?:elevator|building)\s+(?:employee|worker)\s+(?:wage|salar|organiz)'
    r'|collective\s+bargain'
    r'|labor\s+(?:dispute|relation|organization|movement|board|demand)'
    r'|(?:union|labor)\s+(?:contract|agreement|negotiat|demand|leader|official|representative)'
    r'|organiz\w+\s+(?:elevator|building)\s+(?:worker|employee|operator)'
    r')',
    re.IGNORECASE
)

# STRIKE keywords
STRIKE_RE = re.compile(
    r'(?:'
    r'(?:elevator|building\s+(?:service|employee|worker))\s+(?:\w+\s+){0,3}strike'
    r'|strike\s+(?:\w+\s+){0,3}(?:elevator|building\s+(?:service|employee|worker))'
    r'|walkout\s+(?:\w+\s+){0,3}(?:elevator|building)'
    r'|(?:elevator|building)\s+(?:\w+\s+){0,3}walkout'
    r'|picket\w*\s+(?:\w+\s+){0,3}(?:elevator|building)'
    r'|(?:elevator|building)\s+(?:\w+\s+){0,3}picket'
    r'|(?:go|went|gone)\s+on\s+strike'
    r'|strike\s+(?:vote|threat|action|call|order|settlement)'
    r'|strik(?:e|ing)\s+(?:elevator|building)\s+(?:worker|employee|operator)'
    r')',
    re.IGNORECASE
)

# ACCIDENT keywords
ACCIDENT_RE = re.compile(
    r'(?:'
    r'elevator\s+(?:accident|crash|fall|plunge|drop|collaps)'
    r'|(?:accident|crash|fall|plunge|drop|collaps)\w*\s+(?:\w+\s+){0,3}elevator'
    r'|(?:kill|injur|crush|trap|struck|hurt|maim|fatal)\w*\s+(?:\w+\s+){0,5}elevator'
    r'|elevator\s+(?:\w+\s+){0,5}(?:kill|injur|crush|trap|struck|hurt|maim|fatal)'
    r'|fell\s+(?:down\s+)?(?:an?\s+)?(?:the\s+)?elevator\s+shaft'
    r'|elevator\s+shaft\s+(?:\w+\s+){0,3}(?:fell|fall|drop|plunge|death|die|kill)'
    r'|death\s+(?:\w+\s+){0,5}elevator'
    r'|elevator\s+(?:\w+\s+){0,5}death'
    r')',
    re.IGNORECASE
)

# CONSTRUCTION keywords
CONSTRUCTION_RE = re.compile(
    r'(?:'
    r'new\s+(?:building|structure|hotel|office|apartment|skyscraper)\s+(?:\w+\s+){0,5}elevator'
    r'|elevator\s+(?:\w+\s+){0,5}new\s+(?:building|structure|hotel|office|apartment|skyscraper)'
    r'|(?:under\s+construction|being\s+built|being\s+erected)\s+(?:\w+\s+){0,5}elevator'
    r'|install\w*\s+(?:\w+\s+){0,3}elevator'
    r'|elevator\s+(?:\w+\s+){0,3}install'
    r'|equip\w*\s+(?:with\s+)?(?:\w+\s+){0,3}elevator'
    r'|elevator\s+(?:\w+\s+){0,3}equip'
    r'|(?:building|construct|erect)\w*\s+(?:\w+\s+){0,5}(?:elevator|shaft)'
    r')',
    re.IGNORECASE
)

# GRAIN context
GRAIN_CONTEXT_RE = re.compile(
    r'(?:'
    r'grain\s+elevator'
    r'|elevator\s+(?:capacity|receipt|storage|bin)'
    r'|(?:wheat|corn|oat|barley|bushel)\s+(?:\w+\s+){0,3}elevator'
    r'|elevator\s+(?:\w+\s+){0,3}(?:wheat|corn|oat|barley|bushel)'
    r'|(?:terminal|country|line)\s+elevator'
    r'|elevator\s+(?:A|B|C|D)\b'
    r')',
    re.IGNORECASE
)


def classify_article(headline: str, text: str) -> str:
    """
    Classify a single article into one of:
    AUTOMATION, LABOR, STRIKE, ACCIDENT, CONSTRUCTION, GRAIN, OTHER

    Applies categories in priority order. Grain context detected last
    as a reclassification of otherwise-OTHER articles.
    """
    full_text = f"{headline} {text}"

    # Check each category
    is_automation = bool(AUTOMATION_RE.search(full_text))
    is_strike = bool(STRIKE_RE.search(full_text))
    is_labor = bool(LABOR_RE.search(full_text))
    is_accident = bool(ACCIDENT_RE.search(full_text))
    is_construction = bool(CONSTRUCTION_RE.search(full_text))
    is_grain = bool(GRAIN_CONTEXT_RE.search(full_text))

    # Priority: STRIKE > AUTOMATION > LABOR > ACCIDENT > CONSTRUCTION > GRAIN > OTHER
    # (Strike is most specific; automation is key to the paper's thesis)
    if is_strike:
        return "STRIKE"
    if is_automation:
        return "AUTOMATION"
    if is_labor:
        return "LABOR"
    if is_accident:
        return "ACCIDENT"
    if is_construction:
        return "CONSTRUCTION"
    if is_grain:
        return "GRAIN"
    return "OTHER"


def assign_city_group(city: str) -> str:
    """Map city to a key-city group or 'Other'."""
    if not city:
        return "Unknown"
    # Normalize
    city_norm = city.strip()
    if city_norm in KEY_CITIES:
        return city_norm
    # Handle D.C. variations
    if city_norm in ("Washington, D.C.", "Washington D.C."):
        return "Washington"
    return "Other"


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

def main():
    if not INPUT_FILE.exists():
        log.error(f"Input not found: {INPUT_FILE}")
        log.error("Run 00b_newspaper_fetch.py first.")
        sys.exit(1)

    # Load raw articles
    df = pq.read_table(INPUT_FILE).to_pandas()
    log.info(f"Loaded {len(df):,} articles from {INPUT_FILE.name}")

    # ── Step 1: Parse geography ──────────────────────────────────────────────
    log.info("Parsing newspaper geography...")
    geo = df["newspaper_name"].apply(parse_location)
    df["city"] = geo.apply(lambda x: x[0])
    df["state"] = geo.apply(lambda x: x[1])

    n_with_city = (df["city"] != "").sum()
    n_total = len(df)
    log.info(f"  Geography resolved: {n_with_city:,}/{n_total:,} "
             f"({n_with_city/n_total*100:.1f}%)")

    # Summary of top cities
    city_counts = df[df["city"] != ""]["city"].value_counts().head(20)
    log.info("  Top 20 cities by article count:")
    for city, count in city_counts.items():
        log.info(f"    {city}: {count:,}")

    # ── Step 2: Classify each article ────────────────────────────────────────
    log.info("Classifying articles by keyword...")
    df["category"] = df.apply(
        lambda row: classify_article(
            str(row.get("headline", "")),
            str(row.get("article", ""))
        ),
        axis=1
    )

    cat_counts = df["category"].value_counts()
    log.info("  Category distribution:")
    for cat, count in cat_counts.items():
        log.info(f"    {cat}: {count:,} ({count/n_total*100:.1f}%)")

    # Cross-check with existing year-level aggregation
    year_cat = df.groupby(["year", "category"]).size().unstack(fill_value=0)
    log.info("\n  Year x Category cross-tab:")
    log.info(f"\n{year_cat.to_string()}")

    # ── Step 3: Assign city groups ───────────────────────────────────────────
    df["city_group"] = df["city"].apply(assign_city_group)

    group_counts = df["city_group"].value_counts()
    log.info("\n  City group distribution:")
    for grp, count in group_counts.items():
        log.info(f"    {grp}: {count:,} ({count/n_total*100:.1f}%)")

    # ── Step 4: Output per-article classified CSV ────────────────────────────
    articles_out = df[["article_id", "year", "city", "state", "city_group", "category"]].copy()
    articles_out.to_csv(OUTPUT_ARTICLES, index=False)
    log.info(f"\nSaved per-article classifications: {OUTPUT_ARTICLES.name} "
             f"({len(articles_out):,} rows)")

    # ── Step 5: Aggregate year x city_group x category ───────────────────────
    agg = (
        df.groupby(["year", "city_group", "category"])
        .size()
        .reset_index(name="n_articles")
    )

    # Pivot to wide format: one row per year x city_group, columns = categories
    agg_wide = agg.pivot_table(
        index=["year", "city_group"],
        columns="category",
        values="n_articles",
        fill_value=0
    ).reset_index()

    # Flatten column names
    agg_wide.columns.name = None

    # Add total column
    cat_cols = [c for c in agg_wide.columns if c not in ("year", "city_group")]
    agg_wide["total"] = agg_wide[cat_cols].sum(axis=1)

    # Sort
    agg_wide = agg_wide.sort_values(["year", "city_group"]).reset_index(drop=True)

    agg_wide.to_csv(OUTPUT_CITY, index=False)
    log.info(f"Saved city aggregation: {OUTPUT_CITY.name} ({len(agg_wide):,} rows)")

    # ── Summary stats ────────────────────────────────────────────────────────
    log.info("\n" + "=" * 60)
    log.info("SUMMARY")
    log.info("=" * 60)
    log.info(f"Total articles:              {n_total:,}")
    log.info(f"With geography:              {n_with_city:,} ({n_with_city/n_total*100:.1f}%)")
    log.info(f"Unique cities:               {df[df['city'] != '']['city'].nunique()}")
    log.info(f"Unique states:               {df[df['state'] != '']['state'].nunique()}")
    log.info(f"Key-city articles:           {(df['city_group'].isin(KEY_CITIES)).sum():,}")
    log.info(f"Output rows (city agg):      {len(agg_wide):,}")
    log.info(f"Output rows (per-article):   {len(articles_out):,}")

    # Key city x year highlights
    log.info("\nKey cities — total articles across all years:")
    for city in sorted(KEY_CITIES):
        n = (df["city_group"] == city).sum()
        if n > 0:
            log.info(f"  {city}: {n:,}")


if __name__ == "__main__":
    main()
