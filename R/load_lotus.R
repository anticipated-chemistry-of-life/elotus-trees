source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/create_dir.R"
)
source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/get_last_version_from_zenodo.R"
)

load_lotus <- function() {
  get_last_version_from_zenodo(
    doi = paths$url$lotus$doi,
    pattern = paths$urls$lotus$pattern,
    path = paths$data$source$libraries$lotus
  )

  message("Loading LOTUS")
  lotus <-
    readr::read_delim(file = paths$data$source$libraries$lotus)

  return(lotus)
}
