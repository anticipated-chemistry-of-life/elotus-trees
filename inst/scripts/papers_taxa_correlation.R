start <- Sys.time()

#' Packages
#'  Define packages to be installed from CRAN
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

#' Source necessary scripts
source(file = "R/check_and_load_packages.R")
source(file = "R/load_lotus.R")
source(file = "R/parse_yaml_params.R")

check_and_load_packages_1()
check_and_load_packages_2()

#' Source Scripts from Github
#' Source the debugging script from Github
source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/log_debug.R"
)

#' Source the script to parse paths from a yaml file from Github
source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/parse_yaml_paths.R"
)

#' Source Scripts from Github
#' Source the script to make 2D structures from Github
source(file = "https://raw.githubusercontent.com/Adafede/cascade/main/R/make_2D.R")

#' Source the script to make chromatographiable structures from Github
source(file = "https://raw.githubusercontent.com/Adafede/cascade/main/R/make_chromatographiable.R")

#' Parse the paths from the yaml file
paths <- parse_yaml_paths()

#' Parse the parameters from the yaml file
params <- parse_yaml_params()

#' Load Lotus Data
lotus <- load_lotus()

#' 2D Structures
#' If the dimensionality specified in the yaml file is 2, convert the structures to 2D
if (params$structures$dimensionality == 2) {
  lotus <- lotus |>
    make_2D()
}

#' Chromatographiable Structures
#' If the c18 parameter specified in the yaml file is TRUE, make the structures chromatographiable
if (params$structures$c18 == TRUE) {
  lotus <- lotus |>
    make_chromatographiable()
}

#' Distinct Structures and References
#' Get the distinct structures and references
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
