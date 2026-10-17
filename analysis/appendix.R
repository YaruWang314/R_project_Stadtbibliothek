# Each plot shows the top 10 book titles in each genre (top 5 genre).

# 1) Children & Youth (p. 26)
title_child <- stabi %>% filter(genre_label == "Children & Youth" & AUSLEIHART == "A") %>% 
  count(TITEL) %>% arrange(desc(n)) %>% 
  slice_head(n = 10) %>% 
  ggplot(aes(x = reorder(TITEL, n / 1000), y = n)) + 
  geom_col(fill = bar_color) + coord_flip() + 
  labs(x = "Titles", y = "Transactions (in thousands)") + 
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "appendix/title_child.png"), plot = title_child, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# 2) Literature & Fiction (p. 27)
title_lit <- stabi %>% filter(genre_label == "Literature & Fiction" & AUSLEIHART == "A") %>% 
  count(TITEL) %>% arrange(desc(n)) %>% 
  mutate(TITEL = str_remove(TITEL, ":.*")) %>%
  slice_head(n = 10) %>% 
  ggplot(aes(x = reorder(TITEL, n / 1000), y = n)) + 
  geom_col(fill = bar_color) + coord_flip() + 
  labs(x = "Titles",y = "Transactions (in thousands)") + 
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "appendix/title_lit.png"), plot = title_lit, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# 3) Humanities & Social Sciences (p. 28)
title_human <- stabi %>% filter(!is.na(genre_label)) %>% 
  filter(genre_label == "Humanities & Social Sciences" & AUSLEIHART == "A") %>% 
  count(TITEL) %>% arrange(desc(n)) %>% 
  mutate(TITEL = str_remove(TITEL, ":.*")) %>%
  slice_head(n = 10) %>% 
  ggplot(aes(x = reorder(TITEL, n / 1000), y = n)) + 
  geom_col(fill = bar_color) + coord_flip() + 
  labs(x = "Titles",y = "Transactions (in thousands)") + 
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "appendix/title_human.png"), plot = title_human, width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# 4) Lifestyle & Practical Topics (p. 29)
title_life <- stabi %>% filter(!is.na(genre_label)) %>% 
  filter(genre_label == "Lifestyle & Practical Topics" & AUSLEIHART == "A") %>% 
  count(TITEL) %>% arrange(desc(n)) %>% 
  mutate(TITEL = str_remove(TITEL, ":.*")) %>%
  slice_head(n = 10) %>% 
  ggplot(aes(x = reorder(TITEL, n / 1000), y = n)) + 
  geom_col(fill = bar_color) + coord_flip() + 
  labs(x = "Titles",y = "Transactions (in thousands)") + 
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )

ggsave(paste0(paths, "appendix/title_life.png"), plot = title_life, 
       width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)

# 5) Comics (p. 30)
title_comic <- stabi %>% filter(!is.na(genre_label)) %>% 
  filter(genre_label == "Comics" & AUSLEIHART == "A") %>% 
  count(TITEL) %>% arrange(desc(n)) %>% 
  mutate(TITEL = str_remove(TITEL, ".*:")) %>%
  slice_head(n = 10) %>% 
  ggplot(aes(x = reorder(TITEL, n / 1000), y = n)) + 
  geom_col(fill = bar_color) + coord_flip() + 
  labs(x = "Titles",y = "Transactions (in thousands)") + 
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14), 
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.title = element_text(size = 14, face = "bold")
  )


ggsave(paste0(paths, "appendix/title_comic.png"), plot = title_comic, 
       width = ggsave_width, height = ggsave_height, dpi = ggsave_dpi)


