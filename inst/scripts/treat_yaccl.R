library(dplyr)
library(jsonlite)
library(readr)

fromYaccl_path <- "~/Downloads/tmp/lotus/yaccl"

already_classified <- list.files(fromYaccl_path, full.names = TRUE)

classification_list <-
  lapply(
    X = already_classified,
    FUN = function(x) {
      jsonlite::fromJSON(x) |>
        data.frame()
    }
  )

full <- dplyr::bind_rows(classification_list)

classified <- full |>
  dplyr::filter(hits.classification_names == "NULL")
