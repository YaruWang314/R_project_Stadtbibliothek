if (file.exists("renv/activate.R")) source("renv/activate.R")

source("R/packages.R")
load_packages()

# Data loading and preprocessing

# Unified color for bar plots
bar_color <- "#003a7d"

# Unified color for gender
male_color <- "#00BFC4"
female_color <- "#F8766D"

# Unified color for Borrow / Return
borrow_color <- "#98c127"
return_color <- "#ffb255"

# For same saving size and resolution.
ggsave_width <- 8
ggsave_height <- 5
ggsave_dpi <- 300

# Path for saving plots
paths <- "results/visualization/"

# loading and preprocessing of data set
source("Data/load_and_merge_data.R")
source("Data/preprocessing.R")

# Disable scientific notation
options(scipen = 999) 

# Unifying the theme
theme_set(theme_bw()) 

# Producing the visualization for analysis.
source("analysis/table.R")
source("analysis/part1.R")
source("analysis/part2.R")
source("analysis/part3.R")
source("analysis/appendix.R")