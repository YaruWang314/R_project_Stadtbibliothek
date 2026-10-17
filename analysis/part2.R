#All plots analyze borrowing and returning transactions of printed book only.

# Visualizing transactions count per month
monthly_count <- stabi %>% filter(AUSLEIHART == "A"| AUSLEIHART == "R") %>% filter(!is.na(genre_label)) %>%
  group_by(month) %>% 
  count(AUSLEIHART)

# Plot : Monthly Library Transactions (p. 11)
p2_1 <- ggplot(monthly_count, aes(x = month, y = n/1000, fill = AUSLEIHART)) + 
  geom_col(position = "dodge") + 
  labs(x = "Month",
       y = "Transactions (in thousands)") +
  scale_fill_manual(
    name = "Action Type",
    values = c(borrow_color, return_color),
    labels = c("Borrow", "Return")
  ) +
  theme_bw() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "part2/monthly.png"), plot = p2_1, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# Setting Monday as week start instead of Sunday
options("lubridate.week.start" = 1) 

# Weekly transactions count starts from the first Monday of Oct '25
weekly_count <- stabi %>% 
  filter(AUSLEIHART %in% c("A", "R")) %>%
  mutate(week_start = floor_date(time, "week")) %>%
  filter(!is.na(week_start)) %>%
  filter(week_start >= as.Date("2025-10-01") & week_start <= as.Date("2026-12-31")) %>% 
  mutate(Action = recode(AUSLEIHART, "A" = "Borrow", "R" = "Return")) %>%
  group_by(week_start, Action) %>% 
  summarise(n = n(), .groups = "drop")

# Plot: Weekly Library Transactions (p. 12)
p2_2 <- ggplot(weekly_count, aes(x = week_start, y = n / 1000, color = Action)) + 
  geom_line(linewidth = 1.2) + 
  geom_point(size = 2.5) +
  labs(x = "Week of Quarter",
       y = "Transactions (in thousands)",
       color = "Action Type") +
  scale_color_manual(values = c(borrow_color, return_color),
                     labels = c("Borrow", "Return")) +
  scale_x_date(date_breaks = "1 week", date_labels = "%b %d") +
  geom_vline(xintercept = as.Date("2025-12-25"), linetype = 2, color = 2, linewidth = 1) + #christmas as time marker
  annotate("text", label = "christmas!", x = as.Date("2025-12-25") - 5.5, y = 90) +
  theme_bw() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14, angle = 45, hjust = 1),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "part2/christmas.png"), plot = p2_2, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# Manipulating the data set to visualize the peak day in a week.
weekdays_count <- stabi %>% filter(AUSLEIHART == "A"| AUSLEIHART == "R") %>% filter(!is.na(genre_label)) %>%
  group_by(days) %>% 
  mutate(days = factor(days, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) %>%
  count(AUSLEIHART)

# Plot: Transaction Pattern by Day of the Week (p. 13)
p2_3 <- ggplot(weekdays_count, aes(x = days, y = n/1000, fill = AUSLEIHART)) + 
  geom_col(position = "dodge") + 
  labs(x = "Days of the Week",
       y = "Transactions (in thousands)") +
  scale_fill_manual(
    name = "Action Type",
    values = c(borrow_color, return_color),
    labels = c("Borrow", "Return")
  ) +
  theme_bw() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "part2/peak_day.png"), plot = p2_3, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# Preparing data set for the visualization of peak time on each day.
weekdays_hourly_count <- stabi %>% filter(AUSLEIHART == "A"| AUSLEIHART == "R") %>% filter(!is.na(genre_label)) %>%
  filter(hour >= 7 & hour <= 20) %>%
  count(AUSLEIHART, hour, days) %>% 
  complete(hour = 7:20,
           days = levels(days),
           AUSLEIHART = c("A", "R"),
           fill = list(n = 0),
           explicit = TRUE) %>%  
  mutate(AUSLEIHART = recode(AUSLEIHART, "A" = "Borrow", "R" = "Return")) %>%
  mutate(days = factor(days, levels = c("Sun", "Sat", "Fri", "Thu", "Wed", "Tue", "Mon"))) 

max_val <- max(weekdays_hourly_count$n / 1000, na.rm = TRUE)

# Plot: Hourly Library Transactions by Day of the Week (p. 14)
p2_4 <- ggplot(weekdays_hourly_count, aes(x = hour, y = days, fill = n / 1000)) +
  geom_tile(colour = "white") +
  scale_fill_viridis_c(
    option = "mako",
    direction = -1,
    limits = c(0, max_val),
    breaks = seq(0, max_val, length.out = 6),
    labels = scales::number_format(accuracy = 1)
  ) +  labs(
    x = "Hour of Day",
    y = "Day of the Week",
    fill = "Transactions\n(in thousands)"
  ) +
  scale_x_continuous(breaks = 7:30) +
  facet_wrap2(
    ~ AUSLEIHART,
    ncol = 1,
    strip = strip_themed(
      background_x = elem_list_rect(fill = c(borrow_color, return_color),
                                    colour = "grey30"),
      text_x = elem_list_text(colour = c("white", "white"),
                              face = c("bold", "bold"),
                              size = c(13, 13))
    )
  ) +
  theme_bw() +
  coord_fixed() +
  theme(
    strip.text = element_text(hjust = 0.5),
    strip.background = element_rect(colour = NA),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12, face = "bold")
  )

ggsave(paste0(paths, "part2/peak_time.png"), plot = p2_4, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)
