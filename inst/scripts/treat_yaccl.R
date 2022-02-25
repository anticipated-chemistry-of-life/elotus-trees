source(file = "R/log_debug.R")
start <- Sys.time()

#' Packages
packages_cran <-
  c("dplyr", "jsonlite", "jsonlite", "readr")
packages_bioconductor <- NULL
packages_github <- NULL

source(file = "R/check_and_load_packages.R")

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

end <- Sys.time()

log_debug("Script finished in", format(end - start))
