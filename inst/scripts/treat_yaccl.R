source(file = "R/log_debug.R")
start <- Sys.time()

#' TODO move in path
path_yaccl_hierarchy <-
  "https://raw.githubusercontent.com/rwst/yaccl/main/src/data-class-subclass.json"
path_yaccl_hierarchy_names <-
  "https://raw.githubusercontent.com/rwst/yaccl/main/src/data-class-subclass-names.json"

#' Packages
packages_cran <-
  c("dplyr", "jsonlite", "jsonlite", "readr", "tidyr")
packages_bioconductor <- NULL
packages_github <- NULL

source(file = "R/check_and_load_packages.R")
check_and_load_packages_1()
check_and_load_packages_2()

fromYaccl_path <-
  "~/Git/lotus-processor/data/interim/dictionaries_full/structure/yaccl"

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

yaccl_hierarchy <- jsonlite::fromJSON(txt = path_yaccl_hierarchy)

yaccl_hierarchy_names <-
  jsonlite::fromJSON(txt = path_yaccl_hierarchy_names)

manual_corrections <-
  list("item" = "Q134219", "super" = "Q2553138") |>
  data.frame()

yaccl_hierarchy <- yaccl_hierarchy |>
  dplyr::anti_join(manual_corrections)

yaccl_hierarchy_expanded <- yaccl_hierarchy |>
  dplyr::distinct(item, parent_01 = super) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_02 = super),
    by = c("parent_01" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_03 = super),
    by = c("parent_02" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_04 = super),
    by = c("parent_03" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_05 = super),
    by = c("parent_04" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_06 = super),
    by = c("parent_05" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_07 = super),
    by = c("parent_06" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_08 = super),
    by = c("parent_07" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_09 = super),
    by = c("parent_08" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_10 = super),
    by = c("parent_09" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_11 = super),
    by = c("parent_10" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_12 = super),
    by = c("parent_11" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_13 = super),
    by = c("parent_12" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_14 = super),
    by = c("parent_13" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_15 = super),
    by = c("parent_14" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_16 = super),
    by = c("parent_15" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_17 = super),
    by = c("parent_16" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_18 = super),
    by = c("parent_17" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_19 = super),
    by = c("parent_18" = "item")
  ) |>
  dplyr::left_join(yaccl_hierarchy |> dplyr::distinct(item, parent_20 = super),
    by = c("parent_19" = "item")
  ) |>
  dplyr::select_if(function(x) {
    any(!is.na(x))
  })

yaccl_hierarchy_named <- yaccl_hierarchy_expanded |>
  tidyr::pivot_longer(2:ncol(yaccl_hierarchy_expanded)) |>
  dplyr::left_join(yaccl_hierarchy_names |> dplyr::distinct(item, item_label = lab)) |>
  dplyr::left_join(
    yaccl_hierarchy_names |> dplyr::distinct(item, parentLabel = lab),
    by = c("value" = "item")
  ) |>
  dplyr::filter(!is.na(value)) |>
  dplyr::mutate(level = gsub(
    pattern = "parent_",
    replacement = "",
    x = name
  )) |>
  dplyr::select(
    id = item,
    label = item_label,
    parentLevel = level,
    parent = value,
    parentLabel
  ) |>
  dplyr::distinct()

stats <- yaccl_hierarchy_named |>
  dplyr::group_by(id) |>
  dplyr::arrange(dplyr::desc(parentLevel)) |>
  dplyr::distinct(id, .keep_all = TRUE) |>
  dplyr::group_by(parentLevel) |>
  dplyr::add_count() |>
  dplyr::ungroup()

potential_curation <- stats |>
  dplyr::filter(parentLevel == "01") |>
  dplyr::select(-n) |>
  dplyr::distinct() |>
  dplyr::group_by(parentLevel, label) |>
  dplyr::add_count()

smiles_classified <- full |>
  dplyr::filter(hits.classification_names != "NULL") |>
  dplyr::group_by(molecule, ikey) |>
  dplyr::select(-hits.biological_process) |>
  #' https://github.com/rwst/yaccl/issues/11
  #' Actually biological process not linked to all hits
  #' mapping get lost, for the moment simply ignore linked biological processes
  tidyr::unnest(cols = c(hits.classification_names))

end <- Sys.time()

log_debug("Script finished in", format(end - start))
