#' Title
#'
#' @param df
#' @param bio_level
#' @param chemo_level
#' @param count_children
#' @param count_references
#'
#' @return
#' @export
#'
#' @examples
prepare_occurrence_table <-
  function(df,
           bio_level = params$organisms$level,
           chemo_level = params$structures$level,
           count_children = TRUE,
           count_references = TRUE) {
    filtered_table <- df |>
      dplyr::filter(!is.na(!!as.name(bio_level)) &
        !is.na(!!as.name(chemo_level)))

    if (count_references == FALSE) {
      filtered_table <- filtered_table |>
        dplyr::select(-reference_wikidata, -reference_doi) |>
        dplyr::distinct()
    }

    if (count_children == FALSE) {
      filtered_table <- filtered_table |>
        dplyr::distinct(
          dplyr::across(dplyr::any_of(
            c(
              bio_level,
              chemo_level,
              "reference_wikidata",
              "reference_doi"
            )
          )),
          .keep_all = TRUE
        )
    }

    occurrence_table <- filtered_table |>
      dplyr::group_by(!!as.name(bio_level), !!as.name(chemo_level)) |>
      dplyr::count() |>
      tidyr::pivot_wider(
        names_from = !!as.name(chemo_level),
        values_from = n
      ) |>
      tibble::column_to_rownames(var = bio_level) |>
      dplyr::mutate_all(as.numeric) |>
      as.matrix()

    occurrence_table[is.na(occurrence_table)] <- 0

    return(occurrence_table)
  }
