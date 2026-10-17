# Artificial table for the explanation
example_data <- tibble(
  Type   = c("A", "R", "C", "A", "T"),
  Owning   = c("Motorama", "Giesing", "Sendling", "Motorama", "Neuhausen"),
  Lending  = c("Motorama", "Giesing", "Motorama", "HP8", "Neuhausen"),
  Case   = c("Own", "Own", "Inter", "Inter", "Own"),
  Format = c("Print", "DVD & Bluray", "CD", "Print", "Print"),
  Age    = c(19, 57, 21, 42, 11),
  Gender = c("Male", "Female", "Male", "Female", "Female"),
  Genre  = c("Lifestyle", "Humanities", "Literature", "Children & Youth", "Children & Youth")
)

kbl(example_data, booktabs = TRUE, align = "c") %>%
  kable_styling(
    full_width = TRUE,
    font_size = 18
  ) %>% save_kable(paste0(paths, "table.png"), zoom = 3)


  