# Stadtbibliothek München Data Analysis

## Project Overview

This project analyzes transaction data from the Munich Public Library (Stadtbibliothek München) for the fourth quarter of 2025.
The goal is to identify spatial, temporal, and demographic patterns in library usage, including differences across branches, time periods, and user groups (age and gender).

* Presentations:
  * `results/presentation_old.pdf`
  * `results/presentation_updated.pdf`

* Executive Summary:
  * `results/executive_summary.pdf`

* Latest Dataset → `data/raw/`

* Code for Data Preprocessing → `data/preprocessing.R`

* Code for Data Analysis → `analysis/`
  
* All plots and tables → `results/visualization/`
  
*  AI usage documentation:
  * `results/ai_documentation.pdf`


---

## Reproducibility

This project is fully reproducible. All data processing, analysis, and visualization steps can be executed automatically without manual intervention.

###  Setup

Run the following in R:

```r
source("setup.R")
```

This will:

* Install required packages using **renv**
* Restore the project environment

---

### Run Analysis

After setup, run:

```r
source("run.R")
```

This will:

* Load and preprocess data
* Execute all analysis scripts
* Generate all plots and tables
* Save results in the `results/visualization` folder

---

### Render Presentation (Quarto)

To render the presentation as a PDF, the following must be installed on your system:

1. Quarto
  → https://quarto.org/docs/get-started/
2. A TeX distribution (required for PDF output)

If no TeX installation is available, install TinyTeX in the terminal:

```
quarto install tinytex

```
Run the following command in the terminal:

```
quarto render results/presentation_updated.qmd
```
This will generate the final presentation based on the latest analysis results.

---

## Project Structure

```
.
├── data/
│   ├── raw/                  # Original dataset and artifical dataset
│   ├── load_and_merge_data.R # Data loading
│   └── preprocessing.R       # Data preprocessing
│
├── analysis/
│   ├── table.R                   # Table for data example
│   ├── part1.R                   # Spatial analysis
│   ├── part2.R                   # Temporal analysis
│   └── part3.R                   # User behavior analysis
│   └── appendix.R                # Popular Book titles for each genre.
│
├── results/
│   ├── presentation_old.pdf            # Slides for the presentation (not updated)
│   ├── presentation_updated.pdf        # Updated version of the slides
│   ├── executive_summary.pdf           # Executive summary
│   ├── visualization/                  # Generated plots & tables (organized by analysis parts and appendix).
│   └── ai_documentation.pdf            # Documentation of AI usage
│
├── R/
│   └── packages.R           # Required packages
│
├── renv.lock                # Reproducible environment
├── setup.R                  # Environment setup
├── run.R                    # Main execution script
└── README.md
```


---

## Dependencies

All dependencies are managed via **renv**.

* R version: (automatically handled via renv)
* Packages and versions are recorded in `renv.lock`

To restore the exact environment:

```r
renv::restore()
```
---

## Notes

* No manual steps are required — the project is designed to run **fully automatically**.
* All file paths are relative, ensuring portability across systems.
* Output folders are created automatically if they do not exist.

---

## Authors

* Seref Artar
* Ivana Gunawan
* Jaehee Kim
* Yaru Wang

---