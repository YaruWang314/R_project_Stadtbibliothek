# Filtering and sorting the lending libraries by printed book borrowing transactions
trans_ranking_org <- stabi %>% filter(AUSLEIHART == "A")  %>% filter(test != "minus1") %>%
  filter(!is.na(genre_label)) %>% select(AUSGEBENDEBIBLIOTHEK_NAME) %>%
  table() %>% sort(decreasing = TRUE)

# Cutting the top 10 libraries by transactions
cut_point <- 10
trans_ranking <- trans_ranking_org[1:cut_point]

# Data frame for top 10 bar plot
counts <- data.frame(Var1 = names(trans_ranking), 
                     Freq = as.numeric(trans_ranking))

# Top Lending Libraries by Number of Transactions (p. 7)
p_top10 <- ggplot(counts, aes(x = reorder(Var1, Freq), y = (Freq / 1000))) +
  geom_bar(stat = "identity", fill = bar_color) +
  labs(
    x = "Lending Library",
    y = "Transactions (in thousands)") +
  theme_bw() +
  coord_flip() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "part1/top10.png"), plot = p_top10, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# GPS data for each branch in Munich.
standort <- read_csv("Data/raw/Stabi_Standorte.csv")

# Setting library names as a matching key
standort$bib_name <- gsub("Stadtteilbibliothek ", "", standort$bib_name)

# Including all the libraries.
map_data <- data.frame(Var1 = names(trans_ranking_org), 
                       Freq = as.numeric(trans_ranking_org))


# Merging the frequency table with spatial data (GPS coordinates)
map_data <- standort %>% select(bib_name, lon, lat) %>% 
  left_join(map_data, by = c("bib_name" = "Var1")) %>% filter(!is.na(Freq))

# Drawing libraries with At least 500 transactions
map_data <- map_data %>% filter(Freq > 500)

# As a ggplot
map_points_sf <- st_as_sf(
  map_data,
  coords = c("lon", "lat"),
  crs = 4326
)

# Loading Munich district boundaries and transform all spatial data to a common CRS for mapping.
# Extracting bounding box to define the map extent.
munich_districts <- st_read("data/raw/munichDistricts.geo.json")
munich_districts_3857 <- st_transform(munich_districts, 3857)
map_points_3857 <- st_transform(map_points_sf, 3857)
bbox <- st_bbox(munich_districts_3857)

# defining the range of maps for saving
x_pad <- (bbox["xmax"] - bbox["xmin"]) * 0.14
y_pad <- (bbox["ymax"] - bbox["ymin"]) * 0.14

# Plot: Library Usage Across Munich (p. 6)
p_map <- ggplot() +
  annotation_map_tile(
    type = "cartolight",
    zoom = 11 
  ) +
  geom_sf(
    data = munich_districts_3857,
    fill = NA,
    color = "#7f7f7f",
    linewidth = 0.5
  ) +
  geom_sf(
    data = map_points_3857,
    aes(color = Freq),
    size = 5,
    stroke = 0.2
  ) +
  scale_color_gradientn(
    colours = c("#e6eff8", "#8fb6d9", "#003a7d"),
    labels = comma
  ) +
  coord_sf(
    xlim = c(bbox["xmin"] - x_pad, bbox["xmax"] + x_pad),
    ylim = c(bbox["ymin"] - y_pad, bbox["ymax"] + y_pad),
    expand = FALSE,
    clip = "off"
  ) +
  labs(
    color = "Transactions"
  ) +
  theme_void(base_size = 18) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(10, 90, 10, 10),
    legend.position = c(1.03, 0.28),
    legend.justification = c(0, 0),
    legend.direction = "vertical",
    
    legend.title = element_text(size = 14, face = "bold"),
    legend.text = element_text(size = 11),
    
    legend.background = element_rect(
      fill = scales::alpha("white", 0.9),
      color = NA
    ),
    legend.key.height = unit(1.3, "cm"),
    legend.key.width = unit(0.5, "cm")
  )

ggsave(paste0(paths, "part1/map.png"), plot = p_map, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# A vector for the libraries with high proportion of inter-branch transactions
high_interbranch <- stabi %>%
  filter(!is.na(genre_label)) %>% filter(AUSLEIHART == "A") %>%
  count(BESITZENDEBIBLIOTHEK_NAME, test) %>%
  group_by(BESITZENDEBIBLIOTHEK_NAME) %>%
  mutate(prop = n / sum(n)) %>% 
  filter(test == "inter-branch" & prop > 0.9) %>% filter(prop != 1) %>% pull(BESITZENDEBIBLIOTHEK_NAME)


# This vector has libraries in top 10 by borrowing transaction and the libraries with
# high inter-branch rate.
high_interbranch <- unique(c(names(trans_ranking) , high_interbranch))

# Extracting all the sourcing libraries.
all_owning <- unique(stabi$BESITZENDEBIBLIOTHEK_NAME)

# Selecting sourcing libraries which aren't the top10 or libraries with high inter-branch transactions.
not_top_10 <- all_owning[!(all_owning %in% high_interbranch)]

# For ordering and better visualization, Stadtbibliothek im HP8 temporarily excluded 
not_top_10 <- not_top_10[-4]

# The type of transactions as a factor
stabi$test <- factor(stabi$test, levels = c("own-branch", "inter-branch",  "minus1"))

# Plot: Own-branch vs Inter-Branch Borrowing by Library (p. 8)
p_ratio <- stabi %>%
  filter(!is.na(genre_label)) %>% filter(AUSLEIHART == "A") %>%
  filter(test != "minus1") %>%
  filter(AUSGEBENDEBIBLIOTHEK_NAME %in% high_interbranch) %>% 
  count(AUSGEBENDEBIBLIOTHEK_NAME, test) %>%
  group_by(AUSGEBENDEBIBLIOTHEK_NAME) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = factor(AUSGEBENDEBIBLIOTHEK_NAME, levels = rev(high_interbranch)), y = prop, fill = test)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("own-branch" = "#9ecae1", "inter-branch" = "#3182bd")) + 
  labs(
    x = "Lending Library",
    y = "Percentage",
    fill = "Case"
  ) + theme_bw() +   theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "part1/own_vs_inter.png"), plot = p_ratio, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)


# Counting the transactions grouped by sourcing and lending libraries.
heatmap_high_org <- stabi %>%
  filter(!is.na(genre_label)) %>%
  filter(AUSLEIHART == "A") %>%
  filter(test == "inter-branch") %>%
  count(AUSGEBENDEBIBLIOTHEK_NAME, BESITZENDEBIBLIOTHEK_NAME, name = "n") %>%
  group_by(AUSGEBENDEBIBLIOTHEK_NAME) %>%
  mutate(prop_total = n / sum(n))

# Selecting a few libraries
# Top10 lending libaries and all sourcing libaries
heatmap_high <- heatmap_high_org %>% 
  filter(
    AUSGEBENDEBIBLIOTHEK_NAME %in% names(trans_ranking),
    BESITZENDEBIBLIOTHEK_NAME %in% c(high_interbranch, "Stadtbibliothek im HP8", not_top_10)
  ) %>%
  mutate(
    AUSGEBENDEBIBLIOTHEK_NAME = factor(
      AUSGEBENDEBIBLIOTHEK_NAME,
      levels = rev(names(trans_ranking))
    ),
    
    BESITZENDEBIBLIOTHEK_NAME = factor(
      BESITZENDEBIBLIOTHEK_NAME,
      levels =  c(high_interbranch, "Stadtbibliothek im HP8", not_top_10)
    )
  )

# This heatmap is row-wise adding up to 100%
check <- heatmap_high %>% group_by(AUSGEBENDEBIBLIOTHEK_NAME) %>% summarise(prop = sum(prop_total))

# All the sourcing libraries not only on the x-axis, but also on the y-axis.
heatmap_high_full <- heatmap_high_org %>% 
  filter(
    AUSGEBENDEBIBLIOTHEK_NAME %in% c(high_interbranch, "Stadtbibliothek im HP8", not_top_10),
    BESITZENDEBIBLIOTHEK_NAME %in% c(high_interbranch, "Stadtbibliothek im HP8", not_top_10)
  ) %>%
  mutate(
    AUSGEBENDEBIBLIOTHEK_NAME = factor(
      AUSGEBENDEBIBLIOTHEK_NAME,
      levels = rev(c(high_interbranch, "Stadtbibliothek im HP8", not_top_10))
    ),
    BESITZENDEBIBLIOTHEK_NAME = factor(
      BESITZENDEBIBLIOTHEK_NAME,
      levels =  c(high_interbranch, "Stadtbibliothek im HP8", not_top_10)
    )
  )

# Heatmap: What are the Sources of Inter-branch Transactions? (p. 9)
p_heatmap <- ggplot(
  heatmap_high,
  aes(
    x = BESITZENDEBIBLIOTHEK_NAME,
    y = AUSGEBENDEBIBLIOTHEK_NAME,
    fill = prop_total
  )
) +
  geom_tile(color = "white", linewidth = 0.5) +
  scale_fill_gradientn(
    colours = c("#f7fbff", "#9ecae1", "#3182bd", "#003a7d"),
    labels = percent_format(accuracy = 0.1)
  ) +
  labs(
    x = "Source Library (Owning Library)",
    y = "Lending Library",
    fill = "Percentage"
  ) +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, size = 14, hjust = 1),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  ) 

ggsave(paste0(paths, "part1/heatmap.png"), plot = p_heatmap, width = ggsave_width + 4, height = ggsave_height + 2, dpi = ggsave_dpi)


# Full Heatmap (add row-wise up to 100%) (p. 31)

p_heatmap_full <- ggplot(
  heatmap_high_full,
  aes(
    x = BESITZENDEBIBLIOTHEK_NAME,
    y = AUSGEBENDEBIBLIOTHEK_NAME,
    fill = prop_total
  )
) +
  geom_tile(color = "white", linewidth = 0.5) +
  scale_fill_gradientn(
    colours = c("#f7fbff", "#9ecae1", "#3182bd", "#003a7d"),
    labels = percent_format(accuracy = 0.1)
  ) +
  labs(
    x = "Source Library (Owning Library)",
    y = "Lending Library",
    fill = "Percentage"
  ) +
  theme_bw() +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, size = 14, hjust = 1),
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  ) 
check_full <- heatmap_high_full %>% group_by(AUSGEBENDEBIBLIOTHEK_NAME) %>% summarize(sum(prop_total))

ggsave(paste0(paths, "part1/heatmap_full.png"), plot = p_heatmap_full, width = ggsave_width + 4, height = ggsave_height + 4, dpi = ggsave_dpi)

# rougly 32% of all inter-branch transactions stem from 3 major hubs.
avg_from_major <- heatmap_high %>% 
  filter(BESITZENDEBIBLIOTHEK_NAME %in% c("Stadtbibliothek im Motorama", "Münchner Stadtbibliothek / Magazin", "Stadtbibliothek im HP8")) %>%
  group_by(AUSGEBENDEBIBLIOTHEK_NAME) %>% 
  summarise(from_major = sum(prop_total)) %>% summarise(avg = mean(from_major)) %>% pull(avg)
