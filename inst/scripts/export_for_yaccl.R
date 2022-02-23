library(dplyr)
library(readr)

classified_path <-
  "~/Git/lotus-processor/data/processed/220208_frozen_metadata.csv.gz"

forYaccl_path <- "~/Git/elotus-trees/data/smiles4yaccl.txt"

message("exporting unique LOTUS 2D structures for yaccl classification")
smiles_2D_classified <- readr::read_delim(
  file = classified_path,
  col_select = c("smiles" = "structure_smiles_2D")
) |>
  dplyr::distinct() |>
  readr::write_tsv(file = forYaccl_path,
                   col_names = FALSE)
