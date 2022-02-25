start <- Sys.time()

#' Packages
packages_cran <-
  c(
    "dplyr",
    "readr",
    "stringr"
  )
packages_bioconductor <- NULL
packages_github <- NULL

# source(file = "R/check_and_load_packages.R")
# check_and_load_packages()

#' TODO clean
lotus_metadata_path <-
  "~/Git/lotus-processor/data/processed/220208_frozen_metadata.csv.gz"

forYaccl_path <- "~/Git/elotus-trees/data/smiles4yaccl.txt"

fromYaccl_path <- "~/Downloads/tmp/lotus/yaccl"

already_classified <- list.files(fromYaccl_path) |>
  gsub(
    pattern = ".txt",
    replacement = ""
  )

message("exporting unique LOTUS 2D structures for yaccl classification")
smiles_2D_classified <- readr::read_delim(
  file = lotus_metadata_path,
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

message(nrow(smiles_2D_classified), "to go")

end <- Sys.time()

message("Script finished in", format(end - start))
