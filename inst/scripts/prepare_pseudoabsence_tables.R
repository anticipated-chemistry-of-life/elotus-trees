start <- Sys.time()

library(package = devtools, quietly = TRUE)
library(package = dplyr, quietly = TRUE)
library(package = readr, quietly = TRUE)
library(package = tibble, quietly = TRUE)
library(package = tidyr, quietly = TRUE)
library(package = yaml, quietly = TRUE)

devtools::source_url(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/get_lotus.R"
)
source(file = "r/parse_yaml_paths.R")
source(file = "r/prepare_occurrence_table.R")

biological_level <- "organism_taxonomy_08genus"
chemical_level <- "structure_taxonomy_npclassifier_02superclass"

paths <- parse_yaml_paths()

if (!file.exists(paths$inst$extdata$source$libraries$lotus)) {
  message("Downloading LOTUS")
  get_lotus(export = paths$inst$extdata$source$libraries$lotus)
} else {
  message("LOTUS found")
}

message("Loading LOTUS")
lotus <-
  readr::read_delim(file = paths$inst$extdata$source$libraries$lotus)

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
