library(dplyr)
library(readr)

lotus_metadata_path <-
  "~/Git/lotus-processor/data/processed/220208_frozen_metadata.csv.gz"

forYaccl_path <- "~/Git/elotus-trees/data/smiles4yaccl.txt"

fromYaccl_path <- "~/Downloads/tmp/lotus/yaccl"

already_classified <- list.files(fromYaccl_path) |> 
  gsub(pattern = ".txt",
       replacement = "")

message("exporting unique LOTUS 2D structures for yaccl classification")
smiles_2D_classified <- readr::read_delim(
  file = lotus_metadata_path,
  col_select = c("smiles" = "structure_smiles_2D")
) |>
  dplyr::distinct() |> 
  dplyr::filter(!smiles %in% already_classified) |>
  readr::write_tsv(file = forYaccl_path,
                   col_names = FALSE)
