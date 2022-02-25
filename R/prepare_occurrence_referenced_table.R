#' Title
#'
#' @param df
#' @param bio_level
#' @param chemo_level
#'
#' @return
#' @export
#'
#' @examples
prepare_occurrence_referenced_table <-
  function(df,
           bio_level = params$organisms$level,
           chemo_level = params$structures$level) {
    occurrence_referenced_table <- df |>
      dplyr::filter(!is.na(!!as.name(bio_level)) &
        !is.na(!!as.name(chemo_level))) |>
      dplyr::distinct(!!as.name(bio_level),
        !!as.name(chemo_level),
        reference_doi,
        .keep_all = TRUE
      ) |>
      dplyr::group_by(
        !!as.name(bio_level),
        !!as.name(chemo_level),
        reference_doi
      ) |>
      dplyr::count() |>
      dplyr::group_by(!!as.name(bio_level), !!as.name(chemo_level)) |>
      dplyr::mutate(n = sum(n)) |>
      dplyr::select(-reference_doi) |>
      dplyr::distinct() |>
      tidyr::pivot_wider(
        names_from = !!as.name(chemo_level),
        values_from = n
      ) |>
      tibble::column_to_rownames(var = bio_level)

    return(occurrence_referenced_table)
  }
