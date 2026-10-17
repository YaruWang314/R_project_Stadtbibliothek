# Loading the key tables
excel_sheets("Data/raw/LMU_Statistik_OD_Datensatzbeschreibung.xlsx")

# Key table for location
location <- read_excel("Data/raw/LMU_Statistik_OD_Datensatzbeschreibung.xlsx", sheet = "Standortliste")
genre_table <- read.csv("Data/raw/genre_category.csv")

# Key table for Genre (Sachgruppen)
genre_mapping <- read_excel("Data/raw/LMU_Statistik_OD_Datensatzbeschreibung.xlsx", sheet = "Mapping")
genre_mapping <- genre_mapping %>% filter(FELD == "KUERZEL")
genre_mapping <- genre_mapping %>% 
  rename(Art = Bedeutung) %>% rename(Gattung = ...4) %>% 
  rename(Zielgruppe = ...5) %>% rename(Sprache = ...6) %>% 
  rename(Medium = ...7) %>% rename(MedienArt = ...8) %>% 
  rename(Thema = ...9) %>% rename(Altbestand = ...10) %>% 
  rename(Grossgruppe = ...11) %>% rename(Sachgruppe = ...12) %>%
  rename(KUERZEL = Symbol)

# All the entries are KUERZEL in the first column. We don't need it.
genre_mapping <- genre_mapping[,-1]

# Filtering the media which is not printed book
genre_mapping <- genre_mapping %>% filter(MedienArt == "Print") %>% filter(Altbestand == "Nein")

# Adding columns called genre_code and genre_label in the genre_mapping data table.
genre_mapping <- genre_mapping %>% left_join(genre_table, by = c("Thema" = "thema")) 

# 1Z ZS -> General Knowledge & Reference / general_knowledge_reference
# 2B -> Children & Youth / children_youth
# Alle Belletristik -> Literature & Fiction / literature_fiction
# Manually labelling the blanked entries for genre with other hint-giving columns.
genre_mapping <- genre_mapping %>% 
  mutate(genre_group_code = case_when(
    is.na(Thema) & Zielgruppe == "Jugend" ~ "children_youth",
    is.na(Thema) & Art == "Zeitschrift" ~ "general_knowledge_reference",
    is.na(Thema) & Art == "Literatur" ~ "literature_fiction",
    TRUE ~ genre_group_code
  )) %>% mutate(genre_group_label = case_when(
    is.na(Thema) & genre_group_code == "children_youth" ~ "Children & Youth",
    is.na(Thema) & genre_group_code == "general_knowledge_reference" ~ "General Knowledge & Reference",
    is.na(Thema) & genre_group_code == "literature_fiction" ~ "Literature & Fiction",
    TRUE ~ genre_group_label
  )) 


# Allocating the orginal data set to stabi. 
stabi <- temp

# Add columns called genre and gerne_label with predefined table.
stabi <- stabi %>% left_join(genre_mapping %>% select(KUERZEL, genre_group_code, genre_group_label), by = "KUERZEL") %>%
  rename(genre = genre_group_code) %>% 
  rename(genre_label = genre_group_label)
                                                 
# Change the ID to integer
stabi <- stabi %>% mutate(BESITZENDEBIBLIOTHEKID := as.integer(BESITZENDEBIBLIOTHEKID),
                  AUSFUEHRENDEBIBLIOTHEKID := as.integer(AUSFUEHRENDEBIBLIOTHEKID),
                  AUSGEBENDEBIBLIOTHEKID := as.integer(AUSGEBENDEBIBLIOTHEKID))

# Give the names by ID
stabi <- stabi %>% left_join(location %>% select(SIGEL, BIB_ORIG), by = c("AUSGEBENDEBIBLIOTHEKID" = "SIGEL")) %>% 
  rename(AUSGEBENDEBIBLIOTHEK_NAME = BIB_ORIG)

stabi <- stabi %>% left_join(location %>% select(SIGEL, BIB_ORIG), by = c("BESITZENDEBIBLIOTHEKID" = "SIGEL")) %>% 
  rename(BESITZENDEBIBLIOTHEK_NAME = BIB_ORIG)

stabi <- stabi %>% mutate(IS_OWN_COLLECTION := (AUSGEBENDEBIBLIOTHEKID == BESITZENDEBIBLIOTHEKID))

# Cleaning, converting and deriving key temporal features (day, month, week, hour) from the time column.
# Creating variables to analyze seasonal patterns, weekly trends, and hourly usage behavior
stabi <- stabi %>% mutate(time = str_remove(ERFASSUNGSDATUM, ",\\d+$"),
                          time = dmy_hms(time)) %>% 
  mutate(days = lubridate::wday(time, label = TRUE)) %>% 
  mutate(month = lubridate::month(time, label = TRUE, abbr = FALSE),
         is_last_quarter = month %in% c("Oct", "Nov", "Dec")) %>%
  mutate(weekq4 = as.integer(difftime(ceiling_date(time, "week"), min(time), units = "weeks"))) %>%
  mutate(hour = lubridate::hour(time))

stabi$GESCHLECHT <- factor(stabi$GESCHLECHT, levels = c("M", "W"))

# Age
stabi <- stabi %>% filter(GEBURTSDATUM != 0) %>% mutate(age = 2026 - GEBURTSDATUM) 

# Age group
stabi <- stabi %>%
  mutate(age_group = case_when(
    age >= 0  & age <= 6 ~ "0-6",
    age >= 7  & age <= 12 ~ "7-12", # Children
    age >= 13 & age <= 18 ~ "13-18", # Teenagers
    age >= 19 & age <= 25 ~ "19-25", # Young Adults / Students
    age >= 26 & age <= 40 ~ "26-40", # Adults
    age >= 41 & age <= 60 ~ "41-60", # Middle-age Adults
    age >= 61 & age <= 80 ~ "61-80", # Senior
    age >= 81             ~ "81+", # Oldest-old
    TRUE ~ NA_character_
  )) %>% mutate(age_group = factor(age_group, levels = c("0-6", "7-12", "13-18", "19-25", "26-40", "41-60", "61-80", "81+"), ordered = TRUE))

## Labelling for -1 values in the AUSGEBENDEBIBLIOTHEK_ID

stabi <- stabi %>% mutate(test = case_when(
  AUSGEBENDEBIBLIOTHEKID == -1 ~ "minus1",
  #AUSGEBENDEBIBLIOTHEKID == -1 ~ "own-branch",
  AUSGEBENDEBIBLIOTHEKID == BESITZENDEBIBLIOTHEKID ~ "own-branch",
  AUSGEBENDEBIBLIOTHEKID != BESITZENDEBIBLIOTHEKID ~ "inter-branch",
  TRUE ~ NA
))