source(file = "R/log_debug.R")
start <- Sys.time()

#' Packages
packages_cran <-
  c(
    "devtools",
    "dplyr",
    "readr",
    "tibble",
    "tidyr",
    "yaml"
  )
packages_bioconductor <- NULL
packages_github <- NULL

source(file = "R/check_and_load_packages.R")
source(file = "R/load_lotus.R")
source(file = "R/make_2D.R")
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

message("Creating chemical classes dictionary")
chemical_classes_dictionary <- lotus |>
  dplyr::filter(!is.na(structure_taxonomy_npclassifier_01pathway)) |>
  dplyr::distinct(
    structure_taxonomy_npclassifier_01pathway,
    structure_taxonomy_npclassifier_02superclass,
    structure_taxonomy_npclassifier_03class
  )

message("Creating biological classes dictionary")
biological_classes_dictionary <- lotus |>
  dplyr::distinct(
    organism_taxonomy_01domain,
    organism_taxonomy_02kingdom,
    organism_taxonomy_03phylum,
    organism_taxonomy_04class,
    organism_taxonomy_05order,
    organism_taxonomy_06family,
    organism_taxonomy_07tribe,
    organism_taxonomy_08genus,
    organism_taxonomy_09species,
    organism_taxonomy_10varietas
  )

message("Creating occurrence table")
#' bio and chemo levels as arguments to later compute all vs all levels
occurrence_table <- lotus |>
  prepare_occurrence_table()

message("Creating occurrences referenced table")
#' bio and chemo levels as arguments to later compute all vs all levels
occurrence_referenced_table <- lotus |>
  prepare_occurrence_referenced_table()

message("Creating chemical referenced table")
#' level as arguments to later compute all vs all levels
chemical_referenced_table <- lotus |>
  prepare_referenced_table(level = params$structures$level)

message("Creating biological referenced table")
#' level as arguments to later compute all vs all levels
biological_referenced_table <- lotus |>
  prepare_referenced_table(level = params$organisms$level)

end <- Sys.time()

log_debug("Script finished in", format(end - start))
