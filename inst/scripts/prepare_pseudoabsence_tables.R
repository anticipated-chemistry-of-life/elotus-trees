start <- Sys.time()

library(package = devtools, quietly = TRUE)
library(package = dplyr, quietly = TRUE)
library(package = readr, quietly = TRUE)
library(package = tidyr, quietly = TRUE)
library(package = yaml, quietly = TRUE)

devtools::source_url(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/get_lotus.R"
)
source(file = "r/parse_yaml_paths.R")

paths <- parse_yaml_paths()

if (!file.exists(paths$inst$extdata$source$libraries$lotus)) {
  message("Downloading LOTUS")
  get_lotus(export = paths$inst$extdata$source$libraries$lotus)
} else {
  message("LOTUS found")
}

message("Loading LOTUS")
lotus <- readr::read_delim(
  file = paths$inst$extdata$source$libraries$lotus
)
