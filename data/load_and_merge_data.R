# Loading and merging transaction data in October
stabi_Oct <- list.files("Data/raw/stat_2510/", pattern = "\\.csv$", full.names = TRUE) %>%
  map(read_csv2) %>% bind_rows() %>% rename(ID = `\fID`) %>% select(-...23)

# Loading and mering transaction data in November
stabi_Nov <- list.files("Data/raw/stat_2511/", pattern = "\\.csv$", full.names = TRUE) %>%
  map(read_csv2) %>% bind_rows() %>% rename(ID = `\fID`) %>% select(-...23)

# Loading and mering transaction data in December
stabi_Dec <- data_Nov <- list.files("Data/raw/stat_2512-01/", pattern = "\\.csv$", full.names = TRUE) %>%
  map(read_csv2) %>% bind_rows() %>% rename(ID = `\fID`) %>% select(-...23)

temp <- rbind(stabi_Oct, stabi_Nov, stabi_Dec)