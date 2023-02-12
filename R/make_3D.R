#' Title
#'
#' @param df
#'
#' @return
#' @export
#'
#' @examples
make_3D <-
  function(df) {
    message("Keeping 3D structures")
    df |>
      dplyr::group_by(!!as.name(names(df)[!grepl(pattern = "structure", x = names(df))])) |>
      dplyr::distinct(dplyr::across(dplyr::any_of(
        c(
          "structure_inchi",
          "reference_wikidata",
          "reference_doi"
        )
      )),
      .keep_all = TRUE
      ) |>
      dplyr::ungroup() |>
      dplyr::select(-structure_inchi) |>
      dplyr::select(-structure_smiles_2D)
  }