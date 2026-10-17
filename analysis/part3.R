# Counting and sorting by borrowing transactions
# Data cleaning: exclude missing values
top_genres_10 <- stabi %>% filter(!is.na(genre_label)) %>%
  filter(AUSLEIHART == "A") %>%  
  count(genre_label, sort = TRUE) 

# Plot: Library Borrows by Genre (p. 16)
p3_1 <- ggplot(top_genres_10, 
               aes(x = reorder(genre_label, n / 1000), 
                   y = n / 1000)) +
  geom_col(fill = bar_color) +
  coord_flip() + # Horizontal bar chart: easier to read long labels
  labs(
    x = "Genre",
    y = "Transactions (in thousands)") + 
  # Add 15% padding to the top
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  theme_bw() + 
  theme( # Customize font sizes for readability
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 11)
  )

ggsave(paste0(paths, "part3/genre_ranking.png"), plot = p3_1, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# Ranking same as before, but with gender(Male and Female)
gender_genre_data <- stabi %>%
  # Data cleaning: remove rows with missing gender or genre labels
  filter(!is.na(GESCHLECHT) & !is.na(genre_label)) %>% 
  filter(AUSLEIHART == "A") %>%
  # Grouping: prepare for bivariate analysis
  group_by(GESCHLECHT, genre_label) %>% 
  # Aggregation: calculate frequencies and ungroup for a clean output
  summarise(Frequency = n(), .groups = "drop") 

# Plot: Genre Preference by Gender (p. 17)
p3_2_app <- ggplot(gender_genre_data, 
                   aes(x = reorder(genre_label, Frequency), 
                       y = Frequency / 1000, 
                       fill = GESCHLECHT)) + 
  # Grouped bars: places bars for Male and Female side-by-side
  geom_col(position = "dodge", alpha = 0.85) + 
  coord_flip() +
  scale_fill_manual( # Manual color mapping for consistency
    name = "Gender",
    values = c("M" = male_color, 
               "W" = female_color),
    labels = c("M" = "Male", "W" = "Female")
  ) +
  labs(
    x = "Genre", 
    y = "Transactions (in thousands)") +
  theme_bw() +
  theme(
    legend.position = "right",
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 11)
  )

ggsave(paste0(paths, "part3/genre_ranking_by_gender.png"), plot = p3_2_app, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

top5_genres <- stabi %>%
  filter(!is.na(genre_label)) %>% 
  filter(AUSLEIHART == "A") %>%
  # 1. Select the top 5 records after sorting      
  count(genre_label, sort = TRUE) %>% 
  slice_head(n = 5) %>%  
  # 2. Extract the 'genre_label' column as a vector
  pull(genre_label) 

age_genre_data <- stabi %>%
  # 1. Focus only on the most popular categories
  filter(genre_label %in% top5_genres) %>% 
  # 2. Data cleaning: ensure age data is available
  filter(!is.na(age)) %>% 
  filter(AUSLEIHART == "A") %>%
  group_by(age, genre_label) %>%
  summarise(Frequency = n(), .groups = "drop")

# Plot: Book Genre Preferences Across Age Groups (p. 18)
p3_2_final <- ggplot(age_genre_data, aes(x = age, y = Frequency / 1000, color = genre_label)) + 
  geom_line(size = 1.2, alpha = 0.8) +
  scale_color_brewer(palette = "Set1", name = "Book Genre") +
  labs(
    x = "Age", 
    y = "Transactions (in thousands)") +
  # Control x-axis: range from 0 to 100 with intervals of 10
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, by = 10)) + 
  theme_bw() + theme(
    legend.position = "right",
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 11),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12, face = "bold")
  )

ggsave(paste0(paths, "part3/genre_trend.png"), plot = p3_2_final, 
       width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

p3_2_final_jagged_line <- p3_2_final + geom_point()

ggsave(paste0(paths, "part3/genre_trend_appendix.png"), plot = p3_2_final_jagged_line, 
       width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)


# Plot: Borrowing Density by Age and Gender (p. 19)
p5_1_updated <- stabi %>%
  # 1. Focus on specific genders and standard loans
  filter(!is.na(genre_label)) %>% 
  # 2. Group by gender then count occurrences for each age
  filter(GESCHLECHT %in% c("M", "W") & AUSLEIHART == 'A') %>% 
  group_by(GESCHLECHT) %>%
  count(age) %>%
  ggplot(aes(
    x = age,
    y = n/1000,
    color = GESCHLECHT,
    group = GESCHLECHT
  )) +
  geom_line(size = 1.2, alpha = 0.8) +
  #geom_point() +
  labs(
    x = "Age",
    y = "Transactions (in thousands)",
    color = "Gender"
  ) +
  scale_color_manual( # 3. Apply custom colors and labels for gender
    values = c("M" = male_color, "W" = female_color),
    labels = c("M" = "Male", "W" = "Female")
  ) + theme(
    legend.position = "right",
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 13),
    axis.text.y = element_text(size = 11),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 12, face = "bold")
  )


ggsave(paste0(paths, "part3/age_trend.png"), plot = p5_1_updated, 
       width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)
