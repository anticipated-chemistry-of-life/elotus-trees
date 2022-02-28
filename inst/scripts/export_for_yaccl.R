start <- Sys.time()

#' Packages
packages_cran <-
  c(
    "dplyr",
    "readr",
    "stringr",
    "yaml"
  )
packages_bioconductor <- NULL
packages_github <- NULL

source(file = "R/check_and_load_packages.R")
source(file = "R/parse_yaml_paths.R")
source(file = "R/load_lotus.R")

#' TODO clean
forYaccl_path <- "~/Git/elotus-trees/data/smiles4yaccl.txt"
fromYaccl_path <- "~/Git/lotus-processor/data/interim/dictionaries_full/structure/yaccl"

paths <- parse_yaml_paths()

load_lotus()

already_classified <- list.files(fromYaccl_path) |>
  gsub(
    pattern = ".txt",
    replacement = ""
  )

message("exporting unique LOTUS 2D structures for yaccl classification")
smiles_2D_classified <- readr::read_delim(
  file = paths$inst$extdata$source$libraries$lotus,
  col_select = c("smiles" = "structure_smiles_2D")
) |>
  dplyr::distinct() |>
  dplyr::filter(!smiles %in% already_classified) |>
  dplyr::filter(!stringr::str_count(smiles) > 250) |>
  #' because of yaccl not saving >250char files (change later on)
  readr::write_tsv(
    file = forYaccl_path,
    col_names = FALSE
  )

message(nrow(smiles_2D_classified), " smiles to go")

end <- Sys.time()

message("Script finished in", format(end - start))
