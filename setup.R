# setup.R
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

if(file.exists("renv/activate.R")) source("renv/activate.R")

source("R/packages.R")

if (file.exists("renv.lock")) {
  renv::restore(prompt = FALSE)
} else {
  renv::init(bare = TRUE)
  renv::install(required_packages)
  renv::snapshot(prompt = FALSE)
}

missing <- required_packages[
  !vapply(required_packages, requireNamespace, FUN.VALUE = logical(1), quietly = TRUE)
]

if (length(missing) > 0) {
  stop(
    "These packages are still missing after setup: ",
    paste(missing, collapse = ", "),
    "\nPlease check whether renv.lock is up to date."
  )
}

if (Sys.which("quarto") == "") {
  message("⚠️ Quarto is not installed.")
  message("Please install Quarto from: https://quarto.org/docs/get-started/")
} else {
  message("✅ Quarto is installed.")
}

message("Setup complete. Now run: source('run.R')")