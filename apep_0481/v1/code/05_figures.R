## 05_figures.R — Generate all figures
## apep_0481: Gender, Electoral Pathway, and Party Discipline in the German Bundestag

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(data_dir, "analysis_post83.rds"))
df_whipped <- df[free_vote == 0]
df_whipped[, party_period := paste0(ppg, "_", elecper)]
results <- readRDS(file.path(data_dir, "main_results.rds"))

## ============================================================
## Figure 1: Rebellion rates by Gender × Mandate over time
## ============================================================

fig1_data <- df_whipped[, .(
  rebellion_rate = mean(deviate_own) * 100,
  n = .N,
  se = sd(deviate_own) / sqrt(.N) * 100
), by = .(elecper,
          Gender = fifelse(female == 1, "Female", "Male"),
          Mandate = fifelse(district == 1, "District", "List"))]

## Map electoral periods to approximate years
period_years <- c("10" = 1983, "11" = 1987, "12" = 1990, "13" = 1994,
                  "14" = 1998, "15" = 2002, "16" = 2005, "17" = 2009,
                  "18" = 2013, "19" = 2017)
fig1_data[, year := period_years[as.character(elecper)]]
fig1_data[, group := paste(Gender, Mandate)]

p1 <- ggplot(fig1_data, aes(x = year, y = rebellion_rate,
                             color = Gender, linetype = Mandate)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = rebellion_rate - 1.96 * se,
                  ymax = rebellion_rate + 1.96 * se,
                  fill = Gender),
              alpha = 0.1, linetype = 0) +
  scale_color_manual(values = gender_colors) +
  scale_fill_manual(values = gender_colors) +
  scale_linetype_manual(values = c("District" = "solid", "List" = "dashed")) +
  labs(x = "Legislative Period (Start Year)",
       y = "Rebellion Rate (%)",
       title = "Party-Line Deviation by Gender and Mandate Type",
       subtitle = "German Bundestag, 1983-2021 (whipped roll-call votes)") +
  theme(legend.position = "bottom",
        legend.box = "horizontal")

ggsave(file.path(fig_dir, "fig1_rebellion_time.pdf"),
       p1, width = 8, height = 5.5)
cat("Figure 1 saved.\n")

## ============================================================
## Figure 2: DDD coefficient by party
## ============================================================

party_map <- c("1" = "SPD", "2" = "CDU/CSU", "4" = "FDP",
               "5" = "Greens", "6" = "Linke/PDS")

fig2_data <- data.table(
  party = character(),
  estimate = numeric(),
  se = numeric(),
  n = integer()
)

for (p in c("1", "2", "4", "5", "6")) {
  sub <- df_whipped[ppg == as.numeric(p) & !is.na(elecsafe_overall)]
  if (nrow(sub) < 1000 || sum(sub$female) < 100) next

  m <- tryCatch(
    feols(deviate_own ~ female * district + elecsafe_overall |
            as.factor(elecper),
          data = sub, cluster = "id_de_parliament"),
    error = function(e) NULL
  )

  if (!is.null(m) && "female:district" %in% names(coef(m))) {
    fig2_data <- rbind(fig2_data, data.table(
      party = party_map[p],
      estimate = coef(m)["female:district"],
      se = se(m)["female:district"],
      n = nrow(sub)
    ))
  }
}

## Add the overall estimate
m_all <- feols(deviate_own ~ female * district + elecsafe_overall |
                 party_period,
               data = df_whipped[!is.na(elecsafe_overall)],
               cluster = "id_de_parliament")
fig2_data <- rbind(fig2_data, data.table(
  party = "All Parties",
  estimate = coef(m_all)["female:district"],
  se = se(m_all)["female:district"],
  n = nrow(df_whipped[!is.na(elecsafe_overall)])
))

fig2_data[, party := factor(party,
                             levels = rev(c("All Parties", "SPD", "CDU/CSU",
                                            "FDP", "Greens", "Linke/PDS")))]

p2 <- ggplot(fig2_data, aes(x = estimate, y = party)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = estimate - 1.96 * se,
                     xmax = estimate + 1.96 * se),
                 height = 0.2, linewidth = 0.6) +
  geom_point(size = 3, color = "#b2182b") +
  labs(x = expression(hat(beta)[Female %*% District]),
       y = "",
       title = "Gender × Mandate Type Interaction by Party",
       subtitle = "Point estimates with 95% confidence intervals") +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(fig_dir, "fig2_party_heterogeneity.pdf"),
       p2, width = 7, height = 4.5)
cat("Figure 2 saved.\n")

## ============================================================
## Figure 3: Rebellion rate by Gender × Mandate (bar chart)
## ============================================================

fig3_data <- df_whipped[, .(
  rebellion_rate = mean(deviate_own) * 100,
  se = sd(deviate_own) / sqrt(.N) * 100,
  n = .N
), by = .(Gender = fifelse(female == 1, "Female", "Male"),
          Mandate = fifelse(district == 1, "District", "List"))]

p3 <- ggplot(fig3_data, aes(x = Mandate, y = rebellion_rate, fill = Gender)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  geom_errorbar(aes(ymin = rebellion_rate - 1.96 * se,
                    ymax = rebellion_rate + 1.96 * se),
                position = position_dodge(0.7), width = 0.15) +
  scale_fill_manual(values = gender_colors) +
  labs(x = "Electoral Pathway",
       y = "Rebellion Rate (%)",
       title = "Raw Party-Line Deviation by Gender and Mandate Type",
       subtitle = "Unconditional means, whipped votes, WP 10-19") +
  coord_cartesian(ylim = c(0, 3))

ggsave(file.path(fig_dir, "fig3_raw_means.pdf"),
       p3, width = 6, height = 4.5)
cat("Figure 3 saved.\n")

## ============================================================
## Figure 4: Female share of Bundestag over time
## ============================================================

fig4_data <- df[, .(
  pct_female = mean(female) * 100,
  n_mps = uniqueN(id_de_parliament),
  n_female_mps = uniqueN(id_de_parliament[female == 1])
), by = elecper]
fig4_data[, year := period_years[as.character(elecper)]]

## Add quota adoption markers
quota_events <- data.table(
  year = c(1988, 1996, 2010),
  label = c("SPD 40%\nquota", "CDU 33%\nquorum", "CSU 40%\nquota"),
  y = c(38, 38, 38)
)

p4 <- ggplot(fig4_data[!is.na(year)], aes(x = year, y = pct_female)) +
  geom_line(linewidth = 1, color = "#b2182b") +
  geom_point(size = 2.5, color = "#b2182b") +
  geom_vline(data = quota_events, aes(xintercept = year),
             linetype = "dotted", color = "grey40") +
  geom_text(data = quota_events, aes(x = year, y = y, label = label),
            size = 2.8, hjust = -0.1, color = "grey30") +
  labs(x = "Legislative Period (Start Year)",
       y = "Female Share (%)",
       title = "Women in the German Bundestag, 1983-2021",
       subtitle = "With party-level quota adoption dates") +
  scale_y_continuous(limits = c(0, 42))

ggsave(file.path(fig_dir, "fig4_female_share.pdf"),
       p4, width = 7, height = 4.5)
cat("Figure 4 saved.\n")

## ============================================================
## Figure 5: RDD — Rebellion rate by district margin (dual candidates)
## ============================================================

df_dual <- df_whipped[dualcand == 1 & !is.na(closeness_district)]
mp_period <- df_dual[, .(
  rebellion_rate = mean(deviate_own) * 100,
  n_votes = .N,
  district = first(district),
  female = first(female),
  closeness = first(closeness_district)
), by = .(id_de_parliament, elecper)]

## Create bins for visualization
mp_period[, margin_bin := cut(closeness, breaks = seq(0, 0.5, by = 0.025),
                               include.lowest = TRUE)]
bin_means <- mp_period[!is.na(margin_bin), .(
  rebellion_rate = mean(rebellion_rate),
  n = .N,
  closeness_mid = mean(closeness)
), by = .(margin_bin, district)]

p5 <- ggplot(bin_means, aes(x = closeness_mid, y = rebellion_rate,
                             color = factor(district))) +
  geom_point(aes(size = n), alpha = 0.7) +
  geom_smooth(data = mp_period[closeness < 0.25],
              aes(x = closeness, y = rebellion_rate,
                  color = factor(district)),
              method = "lm", se = TRUE, linewidth = 0.8) +
  scale_color_manual(values = c("0" = "#762a83", "1" = "#1b7837"),
                     labels = c("List Entrant", "District Winner")) +
  labs(x = "District Vote Closeness",
       y = "Rebellion Rate (%)",
       color = "Mandate",
       size = "N",
       title = "Rebellion Rate by District Race Closeness",
       subtitle = "Dual candidates only (ran in both district and list)") +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig5_rdd_dual.pdf"),
       p5, width = 7, height = 5)
cat("Figure 5 saved.\n")

## ============================================================
## Figure 6: Policy domain heterogeneity
## ============================================================

## CAP policy codes with labels
policy_labels <- c(
  "1" = "Macro-\neconomics", "2" = "Civil\nRights",
  "3" = "Health", "5" = "Labor",
  "6" = "Education", "7" = "Environment",
  "10" = "Transport", "12" = "Law &\nCrime",
  "13" = "Social\nWelfare", "15" = "Commerce",
  "16" = "Defense", "25" = "Government\nOperations",
  "19" = "Foreign\nAffairs", "27" = "EU\nIntegration"
)

fig6_data <- data.table(
  policy = character(),
  estimate = numeric(),
  se = numeric(),
  n = integer(),
  type = character()
)

for (pol in names(policy_labels)) {
  sub <- df_whipped[policy1 == as.integer(pol) & !is.na(elecsafe_overall)]
  if (nrow(sub) < 5000) next

  m <- tryCatch(
    feols(deviate_own ~ female * district + elecsafe_overall |
            party_period,
          data = sub, cluster = "id_de_parliament"),
    error = function(e) NULL
  )

  if (!is.null(m) && "female:district" %in% names(coef(m))) {
    is_fem <- as.integer(pol) %in% c(2, 3, 6, 13)
    fig6_data <- rbind(fig6_data, data.table(
      policy = policy_labels[pol],
      estimate = coef(m)["female:district"],
      se = se(m)["female:district"],
      n = nrow(sub),
      type = ifelse(is_fem, "Feminine", "Other")
    ))
  }
}

fig6_data[, policy := factor(policy, levels = fig6_data[order(estimate)]$policy)]

p6 <- ggplot(fig6_data, aes(x = estimate, y = policy, color = type)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = estimate - 1.96 * se,
                     xmax = estimate + 1.96 * se),
                 height = 0.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("Feminine" = "#b2182b", "Other" = "#2166ac")) +
  labs(x = expression(hat(beta)[Female %*% District]),
       y = "",
       color = "Policy Type",
       title = "Gender × Mandate Interaction by Policy Domain",
       subtitle = "Estimates with 95% CIs (CAP policy classification)") +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(fig_dir, "fig6_policy_heterogeneity.pdf"),
       p6, width = 7, height = 5.5)
cat("Figure 6 saved.\n")

cat("\nAll figures generated.\n")
