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
prepare_occurrence_table <-
  function(df,
           bio_level = biological_level,
           chemo_level = chemical_level) {
    occurrence_table <- df |>
      dplyr::filter(!is.na(!!as.name(bio_level)) &
        !is.na(!!as.name(chemo_level))) |>
      dplyr::distinct(!!as.name(bio_level), !!as.name(chemo_level), .keep_all = TRUE) |>
      dplyr::group_by(!!as.name(bio_level), !!as.name(chemo_level)) |>
      dplyr::count() |>
      tidyr::pivot_wider(
        names_from = !!as.name(chemo_level),
        values_from = n
      ) |>
      tibble::column_to_rownames(var = bio_level)

    return(occurrence_table)
  }
