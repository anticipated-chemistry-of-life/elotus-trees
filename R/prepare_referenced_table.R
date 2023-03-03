#' Title
#'
#' @param df
#' @param level
#'
#' @return
#' @export
#'
#' @examples
prepare_referenced_table <-
  function(df,
           level) {
    referenced_table <- df %>%
      dplyr::filter(!is.na(!!as.name(level))) %>%
      dplyr::distinct(!!as.name(level),
        reference_doi,
        .keep_all = TRUE
      ) %>%
      dplyr::group_by(!!as.name(level)) %>%
      dplyr::count() %>%
      tibble::column_to_rownames(var = level) %>%
      dplyr::mutate_all(as.numeric) %>%
      as.matrix()

    referenced_table[is.na(referenced_table)] <- 0

    return(referenced_table)
  }
