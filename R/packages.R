# R/packages.R

required_packages <- c(
  "dplyr",
  "tidyverse",
  "data.table",
  "readr",
  "lubridate",
  "readxl",
  "stringr",
  "ggplot2",
  "purrr",
  "leaflet",
  "ggspatial",
  "prettymapr",
  "osmdata",
  "sf",
  "scales",
  "tidytext",
  "htmlwidgets",
  "forcats",
  "patchwork",
  "ggh4x",
  "tibble",
  "knitr",
  "kableExtra",
  "webshot2"
)

required_packages <- unique(required_packages)

load_packages <- function(pkgs = required_packages) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop(
      "Missing packages: ", paste(missing, collapse = ", "),
      "\nRun: source('setup.R') (or renv::restore())"
    )
  }
  
  invisible(lapply(pkgs, library, character.only = TRUE))
}
