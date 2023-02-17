require(package = purrr, quietly = TRUE)
require(package = yaml, quietly = TRUE)

source(file = "R/log_debug.R")

#' Title
#'
#' @return
#' @export
#'
#' @examples
parse_yaml_paths <- function() {
  ## TODO Almost the same exists in <https://github.com/taxonomicallyinformedannotation/tima-r>
  ## Try to harmonize both
  log_debug("Loading paths")
  suppressWarnings(paths <- yaml::read_yaml(
    file = "paths.yaml",
    handlers = list(
      seq = function(x) {
        purrr::flatten(x)
      }
    )
  ))
  setwd(paths$base_dir)

  return(paths)
}
