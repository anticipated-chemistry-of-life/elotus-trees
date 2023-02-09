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
packages_bioconductor <- c("phyloseq")
packages_github <- NULL

source(file = "R/check_and_load_packages.R")
source(file = "R/load_lotus.R")
source(file = "R/parse_yaml_params.R")
source(file = "R/prepare_occurrence_table.R")
source(file = "R/prepare_referenced_table.R")

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

message("Creating occurrence tables...")
#' bio and chemo levels as arguments to later compute all vs all levels
message("... children + refs")
occurrence_table_with_children_with_ref <- lotus |>
  prepare_occurrence_table()

message("... children no refs")
occurrence_table_with_children_no_ref <- lotus |>
  prepare_occurrence_table(count_references = FALSE)

message("... no children + refs")
occurrence_table_no_children_with_ref <- lotus |>
  prepare_occurrence_table(count_children = FALSE)

message("... no children no refs")
occurrence_table_no_children_no_ref <- lotus |>
  prepare_occurrence_table(
    count_children = FALSE,
    count_references = FALSE
  )

message("Creating chemical referenced table")
#' level as arguments to later compute all vs all levels
chemical_referenced_table <- lotus |>
  prepare_referenced_table(level = params$structures$level)

message("Creating biological referenced table")
#' level as arguments to later compute all vs all levels
biological_referenced_table <- lotus |>
  prepare_referenced_table(level = params$organisms$level)

#' WIP exploration
# otu_table <- occurrence_table_with_children_with_ref |>
#   phyloseq::otu_table(taxa_are_rows = TRUE)
#
# sam_data <- chemical_classes_dictionary |>
#   dplyr::distinct(!!as.name(params$structures$level), .keep_all = TRUE) |>
#   dplyr::filter(
#     !!as.name(params$structures$level) %in%
#       colnames(occurrence_table_with_children_with_ref)
#   ) |>
#   tibble::column_to_rownames(var = params$structures$level) |>
#   dplyr::mutate_all(factor) |>
#   phyloseq::sample_data()
#
# tax_table <- biological_classes_dictionary |>
#   dplyr::distinct(!!as.name(params$organisms$level), .keep_all = TRUE) |>
#   dplyr::filter(
#     !!as.name(params$organisms$level) %in%
#       rownames(occurrence_table_with_children_with_ref)
#   ) |>
#   phyloseq::tax_table()
#
# my_phylo <-
#   phyloseq::phyloseq(otu_table = otu_table, sample_data = sam_data)
# ## TODO find why it does not accept the taxa table with this method
# ## temp hack
# my_phylo@tax_table <- tax_table
# ## TODO Work on automatic label/order assignment
# plot_heatmap(
#   physeq = my_phylo,
#   taxa.label = "ta3",
#   taxa.order = "ta3",
#   # trans = "identity",
#   sample.label = "structure_taxonomy_npclassifier_02superclass",
#   sample.order = "structure_taxonomy_npclassifier_02superclass"
# )

message("Exporting tables ...")
taxo <- gsub(
  pattern = "_taxonomy_",
  replacement = "",
  x = params$organisms$level
)
chemo <- gsub(
  pattern = "_taxonomy_npclassifier_",
  replacement = "",
  x = params$structures$level
)
filename <- paste0(
  chemo,
  "_",
  taxo
)

create_dir(paths$data$pseudo$path)

message("... occurrence tables ...")
message("... no children no ref")
write.table(
  x = occurrence_table_no_children_no_ref,
  file = file.path(
    paths$data$pseudo$path,
    paste0(
      filename,
      "_noChildren",
      "_noRef",
      ".csv"
    )
  )
)
message("... no children with ref")
write.table(
  x = occurrence_table_no_children_with_ref,
  file = file.path(
    paths$data$pseudo$path,
    paste0(
      filename,
      "_noChildren",
      "_ref",
      ".csv"
    )
  )
)
message("... with children no ref")
write.table(
  x = occurrence_table_with_children_no_ref,
  file = file.path(
    paths$data$pseudo$path,
    paste0(
      filename,
      "_children",
      "_noRef",
      ".csv"
    )
  )
)
message("... with children with ref")
write.table(
  x = occurrence_table_with_children_with_ref,
  file = file.path(
    paths$data$pseudo$path,
    paste0(
      filename,
      "_children",
      "_ref",
      ".csv"
    )
  )
)
message("... references per chemical")
write.table(
  x = chemical_referenced_table,
  file = file.path(
    paths$data$pseudo$path,
    paste0(
      chemo,
      "_references",
      ".csv"
    )
  )
)
message("... references per taxon")
write.table(
  x = biological_referenced_table,
  file = file.path(
    paths$data$pseudo$path,
    paste0(
      taxo,
      "_references",
      ".csv"
    )
  )
)
message("... chemical dictionary")
write.table(
  x = chemical_classes_dictionary,
  file = file.path(
    paths$data$pseudo$path,
    "chemical_dictionary.csv"
  )
)
end <- Sys.time()

log_debug("Script finished in", format(end - start))
