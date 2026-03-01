#!/usr/bin/env python3
"""
00f_validation_sample.py — Validation of keyword-based newspaper classifier
for apep_0478 (Going Up Alone).

Steps:
  1. Load raw newspaper articles
  2. Apply keyword classifier (AUTOMATION, LABOR, STRIKE, ACCIDENT,
     CONSTRUCTION, GRAIN, OTHER)
  3. Sample 100 non-OTHER, non-GRAIN articles (random_state=42)
  4. Hand-code each sampled article based on headline + first 200 words
  5. Compare keyword_category vs hand_category
  6. Report precision/recall per category and overall accuracy
"""

import re
import sys
from pathlib import Path

import pandas as pd
import pyarrow.parquet as pq

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
INPUT_FILE = DATA_DIR / "newspaper_matches_raw.parquet"
OUTPUT_FILE = DATA_DIR / "validation_sample.csv"

# =============================================================================
# Keyword classifier rules
# =============================================================================
# Applied to combined text = headline + " " + article_text (case-insensitive)

KEYWORD_RULES = {
    "AUTOMATION": [
        r"automatic\s+elevator",
        r"push[\s\-]?button",
        r"self[\s\-]?service\s+elevator",
        r"operatorless",
        r"automatic\s+service",
    ],
    "LABOR": [
        r"\bunion\b",
        r"\bwage[s]?\b",
        r"working\s+condition",
        r"\borganize[ds]?\b",
        r"\bA\.?\s*F\.?\s*L\.?\b",
        r"\bC\.?\s*I\.?\s*O\.?\b",
        r"local\s+32",
        r"building\s+service",
    ],
    "STRIKE": [
        r"\bstrike[sr]?\b",
        r"\bwalkout\b",
        r"\bpicket",
        r"stopped\s+work",
    ],
    "ACCIDENT": [
        r"\baccident",
        r"\binjur",
        r"\bkill(?:ed|s|ing)?\b",
        r"\bfell\b",
        r"\bcrush",
        r"\bdeath[s]?\b",
        r"\btrap(?:ped)?\b",
    ],
    "CONSTRUCTION": [
        r"new\s+building",
        r"under\s+construction",
        r"\binstall",
        r"\bequip(?:ped|ment)?\b",
        r"stories?\s+high",
        r"story\s+building",
    ],
    "GRAIN": [
        r"\bbushel",
        r"grain\s+elevator",
        r"\bwheat\b",
        r"\bharvest",
        r"terminal\s+elevator",
        r"country\s+elevator",
    ],
}

# Compile patterns
COMPILED_RULES = {}
for cat, patterns in KEYWORD_RULES.items():
    COMPILED_RULES[cat] = re.compile("|".join(patterns), re.IGNORECASE)


def classify_article(text: str) -> str:
    """Classify article text using keyword rules.

    Priority order: STRIKE > AUTOMATION > LABOR > ACCIDENT > CONSTRUCTION > GRAIN > OTHER
    STRIKE gets priority because strike articles also match LABOR keywords.
    AUTOMATION gets second priority as the paper's primary focus.
    """
    matches = {}
    for cat, pattern in COMPILED_RULES.items():
        hits = pattern.findall(text)
        if hits:
            matches[cat] = len(hits)

    if not matches:
        return "OTHER"

    # Priority ordering
    priority = ["STRIKE", "AUTOMATION", "LABOR", "ACCIDENT", "CONSTRUCTION", "GRAIN"]
    for cat in priority:
        if cat in matches:
            return cat
    return "OTHER"


def first_n_words(text: str, n: int = 200) -> str:
    """Return first n words of text."""
    words = text.split()
    return " ".join(words[:n])


# =============================================================================
# Hand-coded classifications for the 100 sampled articles
#
# Each entry: (sequence_index, hand_category, brief_rationale)
#
# Categories:
#   AUTOMATION - primarily about automatic/push-button/self-service elevators
#   LABOR      - primarily about unions, wages, working conditions, employment
#   STRIKE     - primarily about a strike, walkout, picket
#   ACCIDENT   - primarily about an elevator accident, injury, death
#   CONSTRUCTION - primarily about building construction/installation
#   OTHER      - not primarily about any elevator topic above
#   GRAIN      - actually about grain elevators, not building elevators
#
# Hand-coding is based on reading the headline + first 200 words of each
# article and determining the PRIMARY topic. If the keyword matched on an
# incidental word (e.g., "killed" in an article about a tornado, or "union"
# in a church event), the hand code reflects the actual content, not the
# keyword match.
# =============================================================================

HAND_CODES = [
    # Art 0: keyword=ACCIDENT. Updike Grain Co selling country elevators. "killed" not present
    # but "country elevators" + grain storage = GRAIN topic entirely
    (0, "GRAIN", "About Updike Grain Co selling grain elevators in Nebraska"),

    # Art 1: keyword=CONSTRUCTION. Farmers purchasing grain elevator, installing machinery
    (1, "GRAIN", "Farmers buying Dakota grain elevator, installing grain machinery"),

    # Art 2: keyword=CONSTRUCTION. Garbled OCR classified ads, mentions 'operators experienced'
    # and job listings. No real elevator construction content.
    (2, "OTHER", "Garbled classified job ads, no elevator construction content"),

    # Art 3: keyword=LABOR. Miscellaneous news notes; 'union' refers to typographical union,
    # 'organized' to the union. Hog got into an elevator (grain). Not about elevator labor.
    (3, "OTHER", "Local news roundup; union is typographical, elevator is grain"),

    # Art 4: keyword=LABOR. Artesian well company 'organized' at Oakes; elevator is grain
    # (Hawkeye elevator). Not about elevator labor at all.
    (4, "OTHER", "Well company organized; Hawkeye elevator is grain elevator"),

    # Art 5: keyword=LABOR. Death of woman from fall down elevator shaft at Union hotel.
    # 'Union' triggered LABOR but article is about an accident/death.
    (5, "ACCIDENT", "Woman died from fall down elevator shaft at Union hotel"),

    # Art 6: keyword=CONSTRUCTION. Manufacturing plant with power elevator, resaws, etc.
    # The 'equipped' keyword matched. Article is a real estate listing for a factory.
    (6, "OTHER", "Real estate listing for manufacturing plant, elevator is incidental"),

    # Art 7: keyword=CONSTRUCTION. Apartment ad mentioning 'tradesman elevator' and modern
    # bath equipment. This is a real estate ad, not about construction.
    (7, "OTHER", "Apartment rental advertisement, elevator mentioned incidentally"),

    # Art 8: keyword=LABOR. New hotel opening in Birmingham with luxury amenities.
    # No labor content; probably triggered by generic word match.
    (8, "OTHER", "Hotel opening announcement, no labor or elevator-specific content"),

    # Art 9: keyword=CONSTRUCTION. Apartment building ad with elevator service. 'new building'
    # triggered it. It IS about a new building with elevator service for rent.
    (9, "CONSTRUCTION", "New building apartments for rent with elevator service"),

    # Art 10: keyword=LABOR. Help wanted classified ads for various domestic positions.
    # No elevator labor content specifically.
    (10, "OTHER", "Classified help wanted ads, no elevator labor content"),

    # Art 11: keyword=STRIKE. Congressional address about railway regulation. 'Elevator
    # allowances should be stopped' = railroad/grain term. Strike not mentioned.
    (11, "OTHER", "Congressional speech on railroad regulation; elevator allowances are rail term"),

    # Art 12: keyword=ACCIDENT. Local news items; Allen Elliott has charge of Dakota Elevator
    # (grain). No accident content.
    (12, "OTHER", "Local news; Dakota Elevator is grain; no accident"),

    # Art 13: keyword=ACCIDENT. Manager of Farmers Elevator at Chatsworth stabbed himself.
    # 'Farmers Elevator' = grain elevator company. Self-inflicted wounds.
    (13, "OTHER", "Manager of grain elevator company self-inflicted wounds; not elevator accident"),

    # Art 14: keyword=CONSTRUCTION. For sale listing of elevator equipment (hydraulic,
    # electric elevators). Equipment sale, not construction.
    (14, "CONSTRUCTION", "Sale of elevator equipment including hydraulic and electric elevators"),

    # Art 15: keyword=LABOR. Help wanted ads including 'ELEVATOR BOY; MUST HAVE HAD experience'.
    # This IS about elevator labor (seeking an elevator operator).
    (15, "LABOR", "Job ad seeking experienced elevator boy with references"),

    # Art 16: keyword=CONSTRUCTION. Georgetown Barge, Dock, Elevator & Railway Company
    # annual report showing financial losses. Freight/railroad context.
    (16, "OTHER", "Financial report of barge/dock/elevator/railway company"),

    # Art 17: keyword=ACCIDENT. Asa Wright injured in St. Anthony & Dakota elevator (grain
    # elevator) caught in belt machinery, leg amputated, died. Industrial accident
    # but at a grain elevator.
    (17, "ACCIDENT", "Worker killed in grain elevator machinery accident"),

    # Art 18: keyword=LABOR. Contrib union dinner at Waldorf Astoria - literary/social
    # club, not a labor union. 'union' triggered the match.
    (18, "OTHER", "Social club dinner, not about labor unions"),

    # Art 19: keyword=ACCIDENT. Gardener crushed on top of elevator at Soldiers Home.
    # Genuine building elevator accident.
    (19, "ACCIDENT", "Gardener crushed to death on top of building elevator"),

    # Art 20: keyword=STRIKE. J.H. Parker Co wins building contract for Interior Dept.
    # Otis Elevator Company gets elevator installation contract. 'strike' not in excerpt.
    # This is construction.
    (20, "CONSTRUCTION", "Building contract awarded; Otis Elevator to install elevators"),

    # Art 21: keyword=ACCIDENT. Fiction story about romance and social class. No elevator
    # accident. 'fell' probably triggered match incidentally.
    (21, "OTHER", "Fiction story, no elevator accident"),

    # Art 22: keyword=ACCIDENT. Elevator cables snap, car drops 10 floors, 2 dead, many
    # injured. Genuine elevator accident.
    (22, "ACCIDENT", "Elevator cables snap, car drops 10 floors, 2 killed"),

    # Art 23: keyword=CONSTRUCTION. Milling company erecting building, mentions 'steel tank
    # elevator' = grain elevator.
    (23, "GRAIN", "Milling company building grain elevator"),

    # Art 24: keyword=STRIKE. Former elevator boy killed jumping train. 'strike' not
    # in excerpt. Headline mentions 'Former Elevator Boy' but the death is from
    # jumping a train, not an elevator accident.
    (24, "OTHER", "Former elevator boy killed jumping train; not elevator-related incident"),

    # Art 25: keyword=ACCIDENT. Insurance policy advertisement listing accident scenarios
    # including 'wrecking of passenger elevator'. Not about a specific accident.
    (25, "OTHER", "Insurance ad listing hypothetical accident scenarios"),

    # Art 26: keyword=LABOR. Local news from various towns; 'union' appears in church
    # context; Fields & Slaughter building new elevator at Dakota City = grain.
    (26, "OTHER", "Local news roundup; elevator is grain context"),

    # Art 27: keyword=STRIKE. Factory fire in Philadelphia, girls jump to death.
    # 'strike' mentioned (shirtwaist strike reduced workers). Fire started in
    # elevator shaft. Primarily about fire/panic, not a strike.
    (27, "ACCIDENT", "Factory fire starting in elevator shaft, workers jump to death"),

    # Art 28: keyword=LABOR. 'wages of sin is death' (proverb), 'elevator to success'
    # (metaphor). Farm advice column. No elevator labor content.
    (28, "OTHER", "Farm advice column; elevator is metaphorical"),

    # Art 29: keyword=LABOR. Financial/legal content about Safe Deposit company paying rent.
    # No elevator labor content. 'union' or 'wage' must have triggered match.
    (29, "OTHER", "Financial records of Safe Deposit company, no elevator content"),

    # Art 30: keyword=ACCIDENT. Elevator operator Michael Sullivan killed by actor Roy Atwell.
    # 'crushed' in elevator. Genuine elevator accident/death involving operator.
    (30, "ACCIDENT", "Elevator operator killed, crushed in elevator car"),

    # Art 31: keyword=CONSTRUCTION. General store ads, local items; no elevator construction.
    # 'equipment' triggered CONSTRUCTION keyword.
    (31, "OTHER", "Local ads and store listings, no elevator construction"),

    # Art 32: keyword=ACCIDENT. Tornado in Heaton ND destroyed buildings including 'two
    # elevators' (grain), killed two people. Natural disaster, not elevator accident.
    (32, "OTHER", "Tornado destroyed grain elevators and buildings"),

    # Art 33: keyword=STRIKE. Threatened building service strike in NYC. Elevator operators,
    # janitors. Local 32-B. LaGuardia to declare emergency. Classic elevator strike article.
    (33, "STRIKE", "NYC building service workers threaten elevator strike"),

    # Art 34: keyword=LABOR. Various local items; 'union rally' at church; 'injured in
    # automobile accident'. No elevator labor content.
    (34, "OTHER", "Local news roundup; union rally is general, no elevator content"),

    # Art 35: keyword=CONSTRUCTION. Movie review/entertainment listings. 'equipment' or
    # 'install' must have triggered. No elevator construction.
    (35, "OTHER", "Movie reviews and entertainment listings"),

    # Art 36: keyword=CONSTRUCTION. Apartment building ad: 'NEW BUILDING' with elevator
    # and janitor service. Genuine new building with elevator.
    (36, "CONSTRUCTION", "New apartment building advertisement with elevator service"),

    # Art 37: keyword=ACCIDENT. Fiction/personal narrative about dining in department store.
    # No elevator accident. 'fell' or 'death' probably triggered.
    (37, "OTHER", "Personal narrative/fiction, no elevator accident"),

    # Art 38: keyword=ACCIDENT. News briefs: 'A falling elevator in the Rock Island arsenal
    # killed Edward O'Toole and injured two others.' Genuine elevator accident.
    (38, "ACCIDENT", "Falling elevator at arsenal kills one, injures two"),

    # Art 39: keyword=CONSTRUCTION. Long-wheelbase cars don't fit municipal garage elevators.
    # Need new elevators or new garage. Actually about elevator infrastructure.
    (39, "CONSTRUCTION", "Municipal garage elevators too small for new cars; need replacement"),

    # Art 40: keyword=CONSTRUCTION. Queens Hospital ad listing amenities including elevator
    # service. 'equipped' triggered match. Hospital ad.
    (40, "OTHER", "Hospital advertisement listing amenities including elevator"),

    # Art 41: keyword=CONSTRUCTION. Classified job ads (situations wanted). No elevator
    # construction. 'install' or 'equipment' triggered.
    (41, "OTHER", "Classified job ads, no elevator construction content"),

    # Art 42: keyword=LABOR. Article about hotel tipping culture; elevator men get tips,
    # 'wage' or 'union' triggered. Actually about elevator worker wages/conditions.
    (42, "LABOR", "Hotel tipping system including elevator men; about their compensation"),

    # Art 43: keyword=ACCIDENT. Local news from Hastings ND; 'killing frosts', Alfred
    # Larson 'employed at the farmers elevators' (grain). No elevator accident.
    (43, "OTHER", "Local news; farmers elevators are grain; no accident"),

    # Art 44: keyword=ACCIDENT. Man fell down elevator shaft six stories, broke leg,
    # will recover. Genuine elevator accident.
    (44, "ACCIDENT", "Man fell down elevator shaft six stories"),

    # Art 45: keyword=LABOR. Classified job ads. Very garbled OCR. No elevator labor
    # content identifiable.
    (45, "OTHER", "Garbled classified job ads, no discernible elevator content"),

    # Art 46: keyword=LABOR. Anti-tipping movement article. Describes tipping elevator men,
    # bellboys. About service worker compensation culture. Related to elevator workers.
    (46, "LABOR", "Anti-tipping movement; describes elevator man tipping customs"),

    # Art 47: keyword=LABOR. Employment ads: 'Bell and elevator boys, different jobs, $15,
    # $40'. About elevator worker job listings.
    (47, "LABOR", "Employment ads for elevator boys with wages listed"),

    # Art 48: keyword=STRIKE. Building trades strike in Chicago involving Otis Elevator
    # Company. Elevator constructors' dispute. Genuine strike about elevators.
    (48, "STRIKE", "Building trades strike involving Otis Elevator Company in Chicago"),

    # Art 49: keyword=ACCIDENT. Obituary of Norton P. Otis, co-founder of Otis Elevator
    # Company. 'death' triggered. Not an accident - it's an obituary/biography.
    (49, "OTHER", "Obituary of Otis Elevator Company co-founder"),

    # Art 50: keyword=ACCIDENT. Town of Epiphany declining after Father Kroeger's death.
    # He had projected 'electric line, paper, elevator, mills.' The 'death' keyword
    # triggered. Not an elevator accident.
    (50, "OTHER", "Town decline story; elevator mentioned among businesses"),

    # Art 51: keyword=STRIKE. Miscellaneous news briefs; Philadelphia 'strike' mentioned
    # but about general Philadelphia transit strike. Elevator not related.
    (51, "OTHER", "News briefs; strike is general Philadelphia, not elevator-related"),

    # Art 52: keyword=ACCIDENT. State house smoke from boilers that operate elevator and
    # lights. 'accident' triggered. About building infrastructure issue.
    (52, "OTHER", "State house smoke problem from boilers; elevator incidental"),

    # Art 53: keyword=LABOR. Brief news items; 'Union Elevator Company's elevator at Joliet
    # burned down' from lightning. 'Union' triggered LABOR but it's the company name.
    (53, "ACCIDENT", "Union Elevator Company building struck by lightning, burned down"),

    # Art 54: keyword=ACCIDENT. Fiction excerpt about attempt to kill someone in an elevator
    # shaft. 'elevator shaft' + 'kill' triggered match. It's fiction.
    (54, "OTHER", "Fiction excerpt involving elevator shaft scene"),

    # Art 55: keyword=LABOR. Classified job ads; mentions 'ELEVATOR OPERATOR' position.
    # About elevator worker employment.
    (55, "LABOR", "Job ads including elevator operator position"),

    # Art 56: keyword=ACCIDENT. Worker's foot caught between elevator and building siding,
    # toe crushed. Genuine elevator accident.
    (56, "ACCIDENT", "Worker's toe crushed by building elevator"),

    # Art 57: keyword=ACCIDENT. About building management; elevator system maintenance,
    # complaints about 'accidents and alleged injuries.' Not a specific accident.
    (57, "OTHER", "Building management article; discusses elevator complaint handling"),

    # Art 58: keyword=LABOR. Classified job ads. Garbled OCR. Includes janitor and
    # general help positions. No clear elevator labor content.
    (58, "OTHER", "Garbled classified job ads"),

    # Art 59: keyword=ACCIDENT. Biographical sketches of African Americans (John Chavis,
    # Frances Harper, Charles Chesnutt). No elevator content at all.
    (59, "OTHER", "Biographical sketches; no elevator content"),

    # Art 60: keyword=ACCIDENT. Local news items; Siberian Millet for sale at Lyon Elevator
    # (grain). 'killed' refers to a dog being shot. No elevator accident.
    (60, "OTHER", "Local news; Lyon Elevator is grain; dog killed"),

    # Art 61: keyword=LABOR. Wedding and social announcements. No elevator or labor content.
    # 'union' must have triggered (e.g., 'unite my worldly life').
    (61, "OTHER", "Social announcements; no elevator content"),

    # Art 62: keyword=CONSTRUCTION. Architect to make plans for new building with freight
    # elevator and passenger elevator provisions. Genuine construction.
    (62, "CONSTRUCTION", "New building plans with freight and passenger elevators"),

    # Art 63: keyword=CONSTRUCTION. WAC member previously was 'an elevator operator at the
    # Durant hotel.' Not about construction; it's a military assignment note.
    (63, "OTHER", "Military assignment; former elevator operator mentioned in passing"),

    # Art 64: keyword=ACCIDENT. State-wide news briefs from Wisconsin. Various incidents.
    # No elevator accident in the excerpt.
    (64, "OTHER", "State news briefs; no elevator accident"),

    # Art 65: keyword=ACCIDENT. Janitor's son crushed to death trying to operate passenger
    # elevator. Genuine elevator accident.
    (65, "ACCIDENT", "Boy crushed to death trying to operate passenger elevator"),

    # Art 66: keyword=ACCIDENT. Gossip column; sister of soldier killed in action is 'an
    # elevator girl we know.' 'killed' triggered match. Not an elevator accident.
    (66, "OTHER", "Gossip column; elevator girl mentioned incidentally"),

    # Art 67: keyword=STRIKE. General strike of elevator constructors threatened due to
    # Otis Elevator Company lockout. Genuine elevator labor strike.
    (67, "STRIKE", "Elevator constructors threaten general strike against Otis"),

    # Art 68: keyword=CONSTRUCTION. Article about Alabama seaport development; cotton
    # warehouses, elevators = grain/port elevators. 'equip' triggered match.
    (68, "OTHER", "Alabama seaport development; elevators are port/grain facilities"),

    # Art 69: keyword=CONSTRUCTION. Hotel/bath house advertising; mentions 'automatic
    # heating' and 'Private elevator each floor to the baths.' 'installing' triggered.
    (69, "OTHER", "Hotel/bath house advertisement; elevator mentioned as amenity"),

    # Art 70: keyword=LABOR. Real estate listings for stores and lofts with elevator
    # service. No labor content. Probably 'union' in a street name.
    (70, "OTHER", "Real estate listings; elevator is building amenity"),

    # Art 71: keyword=CONSTRUCTION. Essay about social commentary; 'forty-story building'
    # mentioned at the end. 'install' or 'equipment' triggered. Not about construction.
    (71, "OTHER", "Social commentary essay; building mentioned in passing"),

    # Art 72: keyword=CONSTRUCTION. Grand Forks mill and elevator bonds being subscribed.
    # 'construction' of grain processing plant.
    (72, "GRAIN", "Mill and grain elevator bond subscription in Grand Forks"),

    # Art 73: keyword=ACCIDENT. Local news ('Wednesday Wrinkles'); various personal items.
    # No elevator accident content. 'killed' or 'death' triggered on unrelated items.
    (73, "OTHER", "Local personal news items; no elevator content"),

    # Art 74: keyword=ACCIDENT. Lawyer killed in elevator at Cape May Hotel, caught between
    # ceiling and car. Genuine elevator accident.
    (74, "ACCIDENT", "Lawyer killed in hotel elevator, caught between ceiling and car"),

    # Art 75: keyword=LABOR. Shooting in Union Pacific offices. Night elevator boy found
    # the wounded man. 'Union' triggered. Article is about a shooting incident.
    (75, "OTHER", "Shooting in Union Pacific offices; elevator boy is witness"),

    # Art 76: keyword=STRIKE. Various union news; International Union of Elevator
    # Constructors local subscribed to exposition stock. Samson foundry strike mentioned.
    # The elevator union item is real labor/union activity for elevator workers.
    (76, "LABOR", "Elevator constructors union local news; subscribing to exposition stock"),

    # Art 77: keyword=ACCIDENT. Man gets finger caught in freight elevator machinery.
    # Genuine elevator accident.
    (77, "ACCIDENT", "Man's finger caught in freight elevator cog wheels"),

    # Art 78: keyword=LABOR. Classified real estate listings and business directory.
    # No elevator labor content.
    (78, "OTHER", "Business directory and real estate listings"),

    # Art 79: keyword=LABOR. Construction of new railroad station; mentions 'operation of
    # the elevator' and water from spring. 'union' in 'union station' triggered.
    (79, "CONSTRUCTION", "New railroad station construction with elevator"),

    # Art 80: keyword=ACCIDENT. Building explosion damage: windows smashed, 'minor accidents.'
    # Not about elevator accident. 'accident' triggered on general building damage.
    (80, "OTHER", "Building explosion damage; no elevator accident"),

    # Art 81: keyword=ACCIDENT. Child killed in elevator at Meier & Frank's store, neck
    # broken. Genuine elevator accident.
    (81, "ACCIDENT", "4-year-old killed in department store elevator"),

    # Art 82: keyword=ACCIDENT. Crime/incident roundup; mentions various deaths, injuries.
    # No elevator accident in the items listed.
    (82, "OTHER", "Crime roundup; no elevator accident"),

    # Art 83: keyword=CONSTRUCTION. Humorous one-liner: man sailed airship to top of
    # building, 'they wouldn't let him go up on the elevator.' Not construction.
    (83, "OTHER", "Humorous anecdote; elevator mentioned as punchline"),

    # Art 84: keyword=CONSTRUCTION. Apartment ad with tradesman elevator. Same as Art 7.
    (84, "OTHER", "Apartment rental ad; elevator mentioned as amenity"),

    # Art 85: keyword=LABOR. Elevator drops in office building, six injured. This is an
    # elevator accident despite keyword=LABOR (triggered by 'union' somewhere).
    (85, "ACCIDENT", "Elevator falls from second floor, six persons injured"),

    # Art 86: keyword=ACCIDENT. Local news from Ogden; fish ponds, marriage licenses,
    # real estate. No elevator accident content.
    (86, "OTHER", "Local news items; no elevator content"),

    # Art 87: keyword=STRIKE. Various local news; farmers considering cooperative lumber
    # and elevator company (grain). 'strike' on Samson foundry.
    (87, "OTHER", "Local news; elevator is cooperative grain elevator"),

    # Art 88: keyword=LABOR. Article about building operators' strike. Loss of elevator
    # service, union stationed personnel. Genuine elevator labor/strike article.
    (88, "STRIKE", "Building operators strike; loss of elevator service"),

    # Art 89: keyword=ACCIDENT. Worker injured by falling wheel in mill elevator. Suing
    # for damages. Genuine elevator workplace accident.
    (89, "ACCIDENT", "Worker injured by equipment falling in mill elevator"),

    # Art 90: keyword=ACCIDENT. Article about people scratching matches on walls/surfaces.
    # 'accident' not about elevator. 'new building' with elevator sign mentioned.
    (90, "OTHER", "Essay about property respect; elevator sign mentioned incidentally"),

    # Art 91: keyword=LABOR. Lawsuit against Montana Grain Growers corporation, formerly
    # Montana Equity Elevator company. Grain/farming organization dispute.
    (91, "GRAIN", "Lawsuit against grain growers/elevator company"),

    # Art 92: keyword=CONSTRUCTION. Brief Q&A: 'How long have buildings been equipped with
    # elevators?' About elevator history.
    (92, "OTHER", "Brief historical note about when elevators appeared"),

    # Art 93: keyword=CONSTRUCTION. Fiction story ('The Domestic Lady') with no elevator
    # content. 'install' or 'equipment' triggered on unrelated text.
    (93, "OTHER", "Fiction story; no elevator content"),

    # Art 94: keyword=CONSTRUCTION. Otis Elevator Company to install passenger elevator at
    # St. Thomas hospital. Genuine elevator installation/construction.
    (94, "CONSTRUCTION", "Otis Elevator installing passenger elevator at hospital"),

    # Art 95: keyword=CONSTRUCTION. Farmers Elevator Company installed grain cleaner.
    # 'installed' triggered. Article is about grain elevator operations.
    (95, "GRAIN", "Farmers Elevator Company installing grain cleaning equipment"),

    # Art 96: keyword=ACCIDENT. Fireman scalded to death in Hotel Manhattan boiler room;
    # steam cut off elevator power. Genuine hotel accident involving elevator.
    (96, "ACCIDENT", "Fireman scalded to death; steam cut off elevator power"),

    # Art 97: keyword=LABOR. Classified job ads including janitor positions. Garbled OCR.
    # No clear elevator labor content.
    (97, "OTHER", "Garbled classified job ads"),

    # Art 98: keyword=ACCIDENT. Man killed, wedged in elevator shaft. Genuine elevator
    # accident.
    (98, "ACCIDENT", "Man killed, wedged in elevator shaft"),

    # Art 99: keyword=CONSTRUCTION. Political metaphor: 'running the political elevators
    # and dusting the political carpets.' 'equipment' triggered.
    (99, "OTHER", "Political commentary; elevator is metaphorical"),
]


def main():
    # =========================================================================
    # Step 1: Load raw articles
    # =========================================================================
    print(f"Loading {INPUT_FILE}...")
    df = pq.read_table(INPUT_FILE).to_pandas()
    print(f"  Loaded {len(df):,} articles")

    # =========================================================================
    # Step 2: Apply keyword classifier
    # =========================================================================
    print("Applying keyword classifier...")
    df["combined_text"] = df["headline"].fillna("") + " " + df["article"].fillna("")
    df["keyword_category"] = df["combined_text"].apply(classify_article)

    cat_counts = df["keyword_category"].value_counts()
    print("\nKeyword classification distribution:")
    for cat, count in cat_counts.items():
        print(f"  {cat}: {count:,} ({count/len(df)*100:.1f}%)")

    # =========================================================================
    # Step 3: Sample 100 non-OTHER, non-GRAIN articles
    # =========================================================================
    substantive = df[~df["keyword_category"].isin(["OTHER", "GRAIN"])].copy()
    print(f"\nSubstantive articles (excl OTHER, GRAIN): {len(substantive):,}")

    sample = substantive.sample(n=100, random_state=42).copy()
    print(f"Sampled 100 articles for validation")

    # =========================================================================
    # Step 4: Prepare excerpts for hand-coding
    # =========================================================================
    sample["headline_excerpt"] = sample["headline"].fillna("").str[:200]
    sample["text_excerpt"] = sample["article"].fillna("").apply(
        lambda x: first_n_words(x, 200)
    )

    # =========================================================================
    # Step 5: Apply hand-coded classifications
    # =========================================================================
    # Build lookup from sequence index to hand code
    hand_code_map = {seq: cat for seq, cat, _ in HAND_CODES}
    rationale_map = {seq: rat for seq, _, rat in HAND_CODES}

    records = []
    for idx, (_, row) in enumerate(sample.iterrows()):
        hand_cat = hand_code_map.get(idx, "UNKNOWN")
        if hand_cat == "UNKNOWN":
            print(f"WARNING: No hand code for article {idx}")
            continue
        records.append({
            "article_id": row["article_id"],
            "year": row["year"],
            "headline_excerpt": row["headline_excerpt"][:100],
            "keyword_category": row["keyword_category"],
            "hand_category": hand_cat,
            "match": 1 if row["keyword_category"] == hand_cat else 0,
        })

    results_df = pd.DataFrame(records)

    # =========================================================================
    # Step 6: Save output
    # =========================================================================
    results_df.to_csv(OUTPUT_FILE, index=False)
    print(f"\nSaved validation sample to {OUTPUT_FILE}")

    # =========================================================================
    # Step 7: Summary statistics
    # =========================================================================
    print("\n" + "=" * 80)
    print("VALIDATION RESULTS")
    print("=" * 80)

    overall_accuracy = results_df["match"].mean()
    print(f"\nOverall accuracy: {overall_accuracy:.1%} ({results_df['match'].sum()}/100)")

    # Category distribution in hand codes
    print(f"\nHand-coded distribution:")
    for cat, count in results_df["hand_category"].value_counts().items():
        print(f"  {cat}: {count}")

    print(f"\nKeyword distribution in sample:")
    for cat, count in results_df["keyword_category"].value_counts().items():
        print(f"  {cat}: {count}")

    # Per-category precision and recall
    all_cats = sorted(set(results_df["keyword_category"].unique()) |
                      set(results_df["hand_category"].unique()))

    print(f"\n{'Category':<16} {'Precision':>10} {'Recall':>10} {'F1':>10}  "
          f"{'TP':>4} {'FP':>4} {'FN':>4}")
    print("-" * 70)

    for cat in all_cats:
        # TP: keyword says cat AND hand says cat
        tp = ((results_df["keyword_category"] == cat) &
              (results_df["hand_category"] == cat)).sum()
        # FP: keyword says cat BUT hand says something else
        fp = ((results_df["keyword_category"] == cat) &
              (results_df["hand_category"] != cat)).sum()
        # FN: hand says cat BUT keyword said something else
        fn = ((results_df["keyword_category"] != cat) &
              (results_df["hand_category"] == cat)).sum()

        precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
        recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0
        f1 = (2 * precision * recall / (precision + recall)
              if (precision + recall) > 0 else 0.0)

        print(f"{cat:<16} {precision:>10.1%} {recall:>10.1%} {f1:>10.1%}  "
              f"{tp:>4} {fp:>4} {fn:>4}")

    # Confusion matrix
    print("\nConfusion matrix (rows=keyword, cols=hand):")
    confusion = pd.crosstab(results_df["keyword_category"],
                            results_df["hand_category"],
                            margins=True)
    print(confusion.to_string())

    # Disagreement analysis
    disagreements = results_df[results_df["match"] == 0]
    print(f"\n{'=' * 80}")
    print(f"DISAGREEMENTS ({len(disagreements)} of 100)")
    print(f"{'=' * 80}")

    if len(disagreements) > 0:
        # Group disagreements by type
        print("\nMisclassification patterns:")
        patterns = disagreements.groupby(
            ["keyword_category", "hand_category"]).size().reset_index(name="count")
        patterns = patterns.sort_values("count", ascending=False)
        for _, p in patterns.iterrows():
            print(f"  {p['keyword_category']:>14} -> {p['hand_category']:<14} : "
                  f"{p['count']} articles")

        print(f"\nDetailed disagreements:")
        for _, row in disagreements.iterrows():
            rationale_idx = records.index(
                next(r for r in records if r["article_id"] == row["article_id"])
            )
            rationale = rationale_map.get(rationale_idx, "")
            print(f"  [{row['year']}] {row['article_id'][:45]:<47} "
                  f"kw={row['keyword_category']:<14} hand={row['hand_category']:<14} "
                  f"{rationale}")

    # Summary interpretation
    print(f"\n{'=' * 80}")
    print("INTERPRETATION")
    print(f"{'=' * 80}")
    n_other = (results_df["hand_category"] == "OTHER").sum()
    n_grain = (results_df["hand_category"] == "GRAIN").sum()
    n_correct_topic = results_df["match"].sum()
    n_wrong_cat = len(disagreements) - n_other - n_grain
    print(f"\nOf 100 keyword-classified 'substantive' articles:")
    print(f"  {n_correct_topic} correctly classified (right category)")
    print(f"  {n_other} are actually OTHER (keyword triggered on incidental word)")
    print(f"  {n_grain} are actually GRAIN (grain elevator, not building elevator)")
    print(f"  {n_wrong_cat} assigned wrong substantive category (e.g., LABOR->ACCIDENT)")


if __name__ == "__main__":
    main()
