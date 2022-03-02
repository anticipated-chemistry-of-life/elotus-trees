source(file = "R/log_debug.R")
start <- Sys.time()

#' Packages
packages_cran <-
  c(
    "devtools",
    "dplyr",
    "plotly",
    "readr",
    "yaml"
  )
packages_bioconductor <- NULL
packages_github <- NULL

source(file = "R/check_and_load_packages.R")
source(file = "R/load_lotus.R")
source(file = "R/make_2D.R")
source(file = "R/make_chromatographiable.R")
source(file = "R/parse_yaml_params.R")
source(file = "R/parse_yaml_paths.R")
source(file = "R/prepare_occurrence_table.R")
source(file = "R/prepare_occurrence_referenced_table.R")
source(file = "R/prepare_referenced_table.R")

check_and_load_packages()

devtools::source_url(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/get_lotus.R"
)

paths <- parse_yaml_paths()
params <- parse_yaml_params()

load_lotus()

message("Loading LOTUS")
lotus <-
  readr::read_delim(file = paths$inst$extdata$source$libraries$lotus)

if (params$structures$dimensionality == 2) {
  lotus <- lotus |>
    make_2D()
}

if (params$structures$c18 == TRUE) {
  lotus <- lotus |>
    make_chromatographiable()
}

papers <- lotus |>
  dplyr::distinct(structure_inchikey, reference_doi) |>
  dplyr::group_by(structure_inchikey) |>
  dplyr::count(name = "papers") |>
  dplyr::ungroup()

taxa <- lotus |>
  dplyr::distinct(structure_inchikey, !!as.name(params$organisms$level)) |>
  dplyr::group_by(structure_inchikey) |>
  dplyr::count(name = "taxa") |>
  dplyr::ungroup()

final <- papers |>
  dplyr::inner_join(taxa)

plotly::plot_ly(
  data = final,
  x = ~papers,
  y = ~taxa,
  type = "scatter",
  mode = "markers",
  alpha = 0.25,
  sizes = 0.5
) |>
  plotly::toWebGL()
