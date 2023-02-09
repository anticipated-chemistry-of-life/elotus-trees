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
source(file = "R/parse_yaml_params.R")

check_and_load_packages_1()
check_and_load_packages_2()

source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/log_debug.R"
)
source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/parse_yaml_paths.R"
)

source(file = "https://raw.githubusercontent.com/Adafede/cascade/main/R/make_2D.R")
source(file = "https://raw.githubusercontent.com/Adafede/cascade/main/R/make_chromatographiable.R")

paths <- parse_yaml_paths()
params <- parse_yaml_params()

lotus <- load_lotus()

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
