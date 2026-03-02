###############################################################################
# 05_figures.R — Publication-quality figures
# Paper: Divine Forgiveness Beliefs (apep_0218)
###############################################################################

source("00_packages.R")

data_dir <- "../data"
fig_dir  <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# Load all cleaned datasets
###############################################################################
gss      <- readRDS(file.path(data_dir, "gss_clean.rds"))
ea       <- readRDS(file.path(data_dir, "ea_clean.rds"))
ea_hg    <- readRDS(file.path(data_dir, "ea_highgods.rds"))
sccs     <- readRDS(file.path(data_dir, "sccs_clean.rds"))
sccs_hg  <- readRDS(file.path(data_dir, "sccs_highgods.rds"))
pulotu   <- readRDS(file.path(data_dir, "pulotu_clean.rds"))
pulotu_q <- readRDS(file.path(data_dir, "pulotu_questions.rds"))
seshat   <- readRDS(file.path(data_dir, "seshat_clean.rds"))

cat("All datasets loaded.\n")

###############################################################################
# Figure 1: Time trends in afterlife beliefs (GSS)
###############################################################################
cat("\n=== Figure 1: GSS Beliefs Over Time ===\n")

belief_vars <- c("heaven", "hell", "afterlif")
belief_labels <- c("heaven" = "Belief in Heaven",
                    "hell" = "Belief in Hell",
                    "afterlif" = "Belief in Afterlife")

# Compute proportions and 95% CIs by year
belief_time <- gss %>%
  select(year, all_of(belief_vars)) %>%
  pivot_longer(cols = all_of(belief_vars), names_to = "belief", values_to = "value") %>%
  filter(!is.na(value)) %>%
  group_by(year, belief) %>%
  summarize(
    n      = n(),
    prop   = mean(value),
    se     = sqrt(prop * (1 - prop) / n),
    ci_lo  = prop - 1.96 * se,
    ci_hi  = prop + 1.96 * se,
    .groups = "drop"
  ) %>%
  mutate(
    belief_label = belief_labels[belief],
    belief_label = factor(belief_label,
                          levels = c("Belief in Heaven", "Belief in Afterlife", "Belief in Hell"))
  )

# Only plot years where these items were fielded
belief_time_plot <- belief_time %>% filter(n >= 100)

p1 <- ggplot(belief_time_plot, aes(x = year, y = prop, color = belief_label, shape = belief_label)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_lo, ymax = ci_hi), width = 0.8, linewidth = 0.5) +
  scale_y_continuous(labels = percent_format(accuracy = 1),
                     limits = c(0.5, 1.0),
                     breaks = seq(0.5, 1.0, 0.1)) +
  scale_color_manual(values = c("Belief in Heaven" = "#2166AC",
                                 "Belief in Afterlife" = "#4393C3",
                                 "Belief in Hell" = "#B2182B")) +
  scale_shape_manual(values = c("Belief in Heaven" = 16,
                                 "Belief in Afterlife" = 17,
                                 "Belief in Hell" = 15)) +
  labs(
    title    = "Afterlife Beliefs in the United States, 1991--2018",
    subtitle = "Proportion responding 'yes definitely' or 'yes probably'",
    x        = "Year",
    y        = "Proportion Believing",
    color    = NULL,
    shape    = NULL
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12)
  )

ggsave(file.path(fig_dir, "fig_gss_beliefs_time.pdf"), p1,
       width = 8, height = 6, device = cairo_pdf)
cat("Saved fig_gss_beliefs_time.pdf\n")

###############################################################################
# Figure 2: God-image items (GSS)
###############################################################################
cat("\n=== Figure 2: God-Image Items ===\n")

god_image_vars <- c("judge", "master", "lover", "friend", "creator",
                     "healer", "father", "mother", "king", "spouse", "redeemer")

# Value 1 = "Extremely likely" in GSS god-image battery (1-4 scale)
god_image_data <- gss %>%
  select(all_of(god_image_vars)) %>%
  pivot_longer(cols = everything(), names_to = "image", values_to = "value") %>%
  filter(!is.na(value)) %>%
  group_by(image) %>%
  summarize(
    n           = n(),
    pct_extreme = mean(value == 1) * 100,
    se          = sqrt(pct_extreme / 100 * (1 - pct_extreme / 100) / n) * 100,
    .groups     = "drop"
  ) %>%
  mutate(
    image_label = str_to_title(image),
    image_label = fct_reorder(image_label, pct_extreme)
  )

# Classify images as benevolent vs. authoritative for coloring
god_image_data <- god_image_data %>%
  mutate(
    image_type = case_when(
      image %in% c("judge", "master", "king") ~ "Authoritative",
      image %in% c("lover", "friend", "healer", "mother", "spouse") ~ "Benevolent",
      TRUE ~ "Mixed"
    )
  )

p2 <- ggplot(god_image_data, aes(x = image_label, y = pct_extreme, fill = image_type)) +
  geom_col(width = 0.7) +
  geom_errorbar(aes(ymin = pct_extreme - 1.96 * se, ymax = pct_extreme + 1.96 * se),
                width = 0.25, linewidth = 0.4) +
  scale_fill_manual(
    values = c("Authoritative" = "#B2182B", "Benevolent" = "#2166AC", "Mixed" = "#999999"),
    name   = "Image Type"
  ) +
  coord_flip() +
  labs(
    title    = "Images of God: Proportion Rating 'Extremely Likely'",
    subtitle = "GSS God-Image Battery (N per item ~ 2,000)",
    x        = NULL,
    y        = "Percent 'Extremely Likely'"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12)
  )

ggsave(file.path(fig_dir, "fig_gss_god_images.pdf"), p2,
       width = 8, height = 6, device = cairo_pdf)
cat("Saved fig_gss_god_images.pdf\n")

###############################################################################
# Figure 3: Distribution of COPE4 (punishing) vs FORGIVE3 (forgiving)
###############################################################################
cat("\n=== Figure 3: Forgive vs. Punish Distribution ===\n")

# COPE4: 1=strongly agree ... 4=strongly disagree (God punishing as coping)
# FORGIVE3: 1=strongly agree ... 4=strongly disagree (God forgives)
cope_forgive <- gss %>%
  select(cope4, forgive3) %>%
  pivot_longer(cols = everything(), names_to = "item", values_to = "value") %>%
  filter(!is.na(value)) %>%
  mutate(
    item_label = ifelse(item == "cope4",
                        "COPE4: God Punishes\nThose Who Sin",
                        "FORGIVE3: God\nForgives My Sins"),
    response = factor(value,
                      levels = 1:4,
                      labels = c("Strongly\nAgree", "Agree",
                                 "Disagree", "Strongly\nDisagree"))
  )

# Compute proportions within each item
cope_forgive_pct <- cope_forgive %>%
  group_by(item_label, response) %>%
  summarize(n = n(), .groups = "drop") %>%
  group_by(item_label) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup()

p3 <- ggplot(cope_forgive_pct, aes(x = response, y = pct, fill = item_label)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  scale_fill_manual(
    values = c("COPE4: God Punishes\nThose Who Sin" = "#B2182B",
               "FORGIVE3: God\nForgives My Sins" = "#2166AC"),
    name   = NULL
  ) +
  labs(
    title    = "Divine Punishment vs. Forgiveness Beliefs",
    subtitle = "GSS: Distribution of agreement (1 = Strongly Agree, 4 = Strongly Disagree)",
    x        = "Response",
    y        = "Percent of Respondents"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12),
    axis.text.x = element_text(size = 9)
  )

ggsave(file.path(fig_dir, "fig_gss_forgive_punish.pdf"), p3,
       width = 8, height = 6, device = cairo_pdf)
cat("Saved fig_gss_forgive_punish.pdf\n")

###############################################################################
# Figure 4: Beliefs by religious tradition (GSS)
###############################################################################
cat("\n=== Figure 4: Beliefs by Religious Tradition ===\n")

beliefs_by_relig <- gss %>%
  filter(!is.na(relig_cat)) %>%
  select(relig_cat, heaven, hell) %>%
  pivot_longer(cols = c(heaven, hell), names_to = "belief", values_to = "value") %>%
  filter(!is.na(value)) %>%
  group_by(relig_cat, belief) %>%
  summarize(
    n    = n(),
    prop = mean(value),
    se   = sqrt(prop * (1 - prop) / n),
    .groups = "drop"
  ) %>%
  mutate(
    belief_label = ifelse(belief == "heaven", "Belief in Heaven", "Belief in Hell"),
    relig_cat    = factor(relig_cat,
                          levels = c("Protestant", "Catholic", "Jewish", "Other", "None"))
  )

p4 <- ggplot(beliefs_by_relig, aes(x = relig_cat, y = prop, fill = belief_label)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_errorbar(aes(ymin = prop - 1.96 * se, ymax = prop + 1.96 * se),
                position = position_dodge(width = 0.7), width = 0.2, linewidth = 0.4) +
  scale_y_continuous(labels = percent_format(accuracy = 1),
                     limits = c(0, 1.05),
                     breaks = seq(0, 1, 0.2)) +
  scale_fill_manual(
    values = c("Belief in Heaven" = "#2166AC", "Belief in Hell" = "#B2182B"),
    name   = NULL
  ) +
  labs(
    title    = "Heaven and Hell Beliefs by Religious Tradition",
    subtitle = "GSS cumulative (1991, 1998, 2008, 2018)",
    x        = "Religious Tradition",
    y        = "Proportion Believing"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12)
  )

ggsave(file.path(fig_dir, "fig_gss_beliefs_by_religion.pdf"), p4,
       width = 8, height = 6, device = cairo_pdf)
cat("Saved fig_gss_beliefs_by_religion.pdf\n")

###############################################################################
# Figure 5: World map of EA034 High Gods
###############################################################################
cat("\n=== Figure 5: EA World Map ===\n")

world <- ne_countries(scale = "medium", returnclass = "sf")

# Prepare EA high-gods data for mapping, excluding "Missing data"
ea_map <- ea_hg %>%
  filter(!is.na(Description), Description != "Missing data") %>%
  mutate(
    god_cat = case_when(
      grepl("absent", Description, ignore.case = TRUE)    ~ "Absent",
      grepl("otiose", Description, ignore.case = TRUE)    ~ "Otiose",
      grepl("not.*moral", Description, ignore.case = TRUE) ~ "Active/Not Moralizing",
      grepl("supportive.*moral", Description, ignore.case = TRUE) ~ "Active/Moralizing",
      TRUE ~ NA_character_
    ),
    god_cat = factor(god_cat,
                     levels = c("Absent", "Otiose", "Active/Not Moralizing", "Active/Moralizing"))
  ) %>%
  filter(!is.na(god_cat))

# Use divine_pal from 00_packages.R
map_colors <- c(
  "Absent"              = divine_pal[["Absent"]],
  "Otiose"              = divine_pal[["Otiose"]],
  "Active/Not Moralizing" = divine_pal[["Active/Not Moralizing"]],
  "Active/Moralizing"   = divine_pal[["Active/Moralizing"]]
)

p5 <- ggplot() +
  geom_sf(data = world, fill = "grey95", color = "grey70", linewidth = 0.15) +
  geom_point(data = ea_map,
             aes(x = Longitude, y = Latitude, color = god_cat),
             size = 1.2, alpha = 0.75) +
  scale_color_manual(values = map_colors, name = "High God Category") +
  coord_sf(xlim = c(-170, 180), ylim = c(-55, 75), expand = FALSE) +
  labs(
    title    = "Global Distribution of High God Beliefs",
    subtitle = paste0("Ethnographic Atlas (EA034), N = ", nrow(ea_map), " societies")
  ) +
  theme(
    legend.position   = "bottom",
    plot.title        = element_text(face = "bold", size = 12),
    axis.title        = element_blank(),
    axis.text         = element_text(size = 7),
    panel.grid.major  = element_line(color = "grey90", linewidth = 0.2),
    panel.background  = element_rect(fill = "aliceblue"),
    legend.key.size   = unit(0.4, "cm")
  ) +
  guides(color = guide_legend(override.aes = list(size = 3, alpha = 1), nrow = 1))

ggsave(file.path(fig_dir, "fig_ea_world_map.pdf"), p5,
       width = 10, height = 6, device = cairo_pdf)
cat("Saved fig_ea_world_map.pdf\n")

###############################################################################
# Figure 6: EA034 High Gods by world region
###############################################################################
cat("\n=== Figure 6: EA Region Distribution ===\n")

# Aggregate regions into broader macro-regions for readability
ea_region <- ea_map %>%
  filter(!is.na(region)) %>%
  mutate(
    macro_region = case_when(
      grepl("Africa", region)                          ~ "Africa",
      grepl("Europe|Caucasus", region)                 ~ "Europe",
      grepl("Asia|China|Mongolia|Siberia|Indo-China|Indian", region) ~ "Asia",
      grepl("Pacific|Papuasia|Malesia|Australia|New Zealand|Subantarctic", region) ~ "Oceania",
      grepl("America|Canada|U.S.A.|Mexico|Caribbean|Brazil", region) ~ "Americas",
      grepl("Arabian|Western Asia|Middle", region)     ~ "Middle East",
      TRUE ~ "Other"
    )
  )

region_summary <- ea_region %>%
  count(macro_region, god_cat) %>%
  group_by(macro_region) %>%
  mutate(
    total = sum(n),
    pct   = n / total * 100
  ) %>%
  ungroup() %>%
  mutate(macro_region = fct_reorder(macro_region, total, .desc = TRUE))

p6 <- ggplot(region_summary, aes(x = macro_region, y = n, fill = god_cat)) +
  geom_col(position = "fill", width = 0.7) +
  scale_fill_manual(values = map_colors, name = "High God Category") +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  labs(
    title    = "High God Beliefs by World Region",
    subtitle = "Ethnographic Atlas (EA034), societies with non-missing data",
    x        = "Region",
    y        = "Proportion of Societies"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12),
    axis.text.x = element_text(angle = 25, hjust = 1)
  ) +
  guides(fill = guide_legend(nrow = 1))

ggsave(file.path(fig_dir, "fig_ea_region_distribution.pdf"), p6,
       width = 8, height = 6, device = cairo_pdf)
cat("Saved fig_ea_region_distribution.pdf\n")

###############################################################################
# Figure 7: Seshat moralizing supernatural punishment over time
###############################################################################
cat("\n=== Figure 7: Seshat MSP Over Time ===\n")

# Compute midpoint of each polity-period and bin into centuries
seshat_time <- seshat %>%
  filter(!is.na(MSP), !is.na(Start), !is.na(End)) %>%
  mutate(
    midpoint = (Start + End) / 2,
    century  = floor(midpoint / 100) * 100
  ) %>%
  # Remove extreme ancient data for readability (sparse before -5000)
  filter(century >= -5000)

# Aggregate: mean MSP and component prevalence by century
seshat_century <- seshat_time %>%
  group_by(century) %>%
  summarize(
    n          = n(),
    msp_mean   = mean(MSP, na.rm = TRUE),
    msp_se     = sd(MSP, na.rm = TRUE) / sqrt(n()),
    afterlife  = mean(afterlife, na.rm = TRUE),
    thislife   = mean(thislife, na.rm = TRUE),
    .groups    = "drop"
  ) %>%
  filter(n >= 3)  # Require at least 3 observations per century

# Reshape for multi-line plot
seshat_long <- seshat_century %>%
  select(century, n, afterlife, thislife, msp_mean) %>%
  pivot_longer(cols = c(afterlife, thislife, msp_mean),
               names_to = "measure", values_to = "value") %>%
  mutate(
    measure_label = case_when(
      measure == "afterlife" ~ "Afterlife Punishment",
      measure == "thislife"  ~ "This-Life Punishment",
      measure == "msp_mean"  ~ "MSP Composite"
    ),
    measure_label = factor(measure_label,
                           levels = c("MSP Composite", "This-Life Punishment", "Afterlife Punishment"))
  )

# Create century label for x-axis
seshat_long <- seshat_long %>%
  mutate(century_label = ifelse(century < 0,
                                paste0(abs(century / 100), " BCE"),
                                paste0(century / 100, " CE")))

p7 <- ggplot(seshat_long, aes(x = century, y = value, color = measure_label)) +
  geom_point(size = 2) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1.0, span = 0.75) +
  scale_x_continuous(
    breaks = seq(-5000, 2000, 1000),
    labels = function(x) ifelse(x < 0, paste0(abs(x/100), " BCE"), paste0(x/100, " CE"))
  ) +
  scale_y_continuous(limits = c(0, 1.05), labels = percent_format(accuracy = 1)) +
  scale_color_manual(
    values = c("MSP Composite" = "#2166AC",
               "This-Life Punishment" = "#B2182B",
               "Afterlife Punishment" = "#4393C3"),
    name = NULL
  ) +
  labs(
    title    = "Moralizing Supernatural Punishment Over Time",
    subtitle = paste0("Seshat Databank (N = ", nrow(seshat_time),
                      " polity-periods, ", length(unique(seshat_time$NGA)), " NGAs)"),
    x        = "Century",
    y        = "Prevalence (proportion of polities)"
  ) +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12),
    axis.text.x = element_text(angle = 30, hjust = 1, size = 8)
  )

ggsave(file.path(fig_dir, "fig_seshat_time.pdf"), p7,
       width = 9, height = 6, device = cairo_pdf)
cat("Saved fig_seshat_time.pdf\n")

###############################################################################
# Figure 8: Pulotu supernatural punishment for impiety
###############################################################################
cat("\n=== Figure 8: Pulotu Supernatural Punishment ===\n")

# Parameter 7 = "Supernatural punishment for impiety" (0=absent, 1=present)
pulotu_sp <- pulotu %>%
  select(Language_ID, Name, Latitude, Longitude, param7 = `7`) %>%
  filter(!is.na(param7)) %>%
  mutate(
    sp_label = ifelse(param7 == 1, "Present", "Absent"),
    sp_label = factor(sp_label, levels = c("Present", "Absent"))
  )

cat("Pulotu supernatural punishment: N =", nrow(pulotu_sp), "\n")
cat("Present:", sum(pulotu_sp$param7 == 1), ", Absent:", sum(pulotu_sp$param7 == 0), "\n")

# Since Macroarea is all NA, we use geographic binning by longitude
# Austronesian cultures span the Pacific — bin by longitude bands
pulotu_sp <- pulotu_sp %>%
  mutate(
    geo_zone = case_when(
      Longitude < 110                     ~ "Island SE Asia",
      Longitude >= 110 & Longitude < 140  ~ "Near Oceania",
      Longitude >= 140 & Longitude < 170  ~ "Melanesia/Micronesia",
      Longitude >= 170 | Longitude < -150 ~ "Polynesia (West)",
      Longitude >= -150                   ~ "Polynesia (East)",
      TRUE ~ "Other"
    ),
    geo_zone = factor(geo_zone,
                      levels = c("Island SE Asia", "Near Oceania",
                                 "Melanesia/Micronesia", "Polynesia (West)",
                                 "Polynesia (East)"))
  )

# Summary by geographic zone
pulotu_zone <- pulotu_sp %>%
  group_by(geo_zone, sp_label) %>%
  summarize(n = n(), .groups = "drop") %>%
  group_by(geo_zone) %>%
  mutate(
    total = sum(n),
    pct   = n / total * 100
  ) %>%
  ungroup()

# Combine: Map + bar chart with patchwork
p8_map <- ggplot() +
  geom_sf(data = world, fill = "grey95", color = "grey70", linewidth = 0.15) +
  geom_point(data = pulotu_sp,
             aes(x = Longitude, y = Latitude, color = sp_label),
             size = 1.8, alpha = 0.75) +
  scale_color_manual(
    values = c("Present" = "#B2182B", "Absent" = "#2166AC"),
    name   = "Supernatural Punishment\nfor Impiety"
  ) +
  coord_sf(xlim = c(90, 220), ylim = c(-50, 30), expand = FALSE) +
  labs(subtitle = paste0("Geographic distribution (N = ", nrow(pulotu_sp), " cultures)")) +
  theme(
    legend.position   = "bottom",
    axis.title        = element_blank(),
    axis.text         = element_text(size = 7),
    panel.grid.major  = element_line(color = "grey90", linewidth = 0.2),
    panel.background  = element_rect(fill = "aliceblue"),
    legend.key.size   = unit(0.4, "cm")
  ) +
  guides(color = guide_legend(override.aes = list(size = 3, alpha = 1)))

p8_bar <- ggplot(pulotu_zone, aes(x = geo_zone, y = n, fill = sp_label)) +
  geom_col(width = 0.7) +
  scale_fill_manual(
    values = c("Present" = "#B2182B", "Absent" = "#2166AC"),
    name   = NULL
  ) +
  labs(
    subtitle = "By geographic zone",
    x        = NULL,
    y        = "Number of Cultures"
  ) +
  theme(
    legend.position = "none",
    axis.text.x     = element_text(angle = 30, hjust = 1, size = 8)
  )

p8 <- (p8_map / p8_bar) +
  plot_layout(heights = c(2, 1)) +
  plot_annotation(
    title    = "Supernatural Punishment for Impiety in Austronesian Cultures",
    subtitle = "Pulotu Database",
    theme    = theme(
      plot.title    = element_text(face = "bold", size = 13),
      plot.subtitle = element_text(size = 10, color = "grey40")
    )
  )

ggsave(file.path(fig_dir, "fig_pulotu_supernatural.pdf"), p8,
       width = 9, height = 8, device = cairo_pdf)
cat("Saved fig_pulotu_supernatural.pdf\n")

###############################################################################
# Summary
###############################################################################
cat("\n=== All Figures Complete ===\n")
fig_files <- list.files(fig_dir, pattern = "\\.pdf$")
for (f in fig_files) {
  sz <- file.size(file.path(fig_dir, f))
  cat(sprintf("  %s: %.1f KB\n", f, sz / 1024))
}
cat(sprintf("Total: %d figures generated.\n", length(fig_files)))
