library(dplyr)
library(jsonlite)
library(readr)
library(tidyr)

source("~/Git/lotus-processor/src/r/treat_npclassifier_json.R")

path_npc_json <-
  "https://raw.githubusercontent.com/mwang87/NP-Classifier/7e4e2001a1416b96968240650dc7d70f1275fdb5/Classifier/dict/index_v1.json"

classified_path <-
  "~/Git/lotus-processor/data/processed/220208_frozen_metadata.csv.gz"

message("Loading LOTUS classified structures")
structures_classified <- readr::read_delim(
  file = classified_path,
  col_select = c(
    "structure_id" = "structure_inchikey",
    "chemical_pathway" = "structure_taxonomy_npclassifier_01pathway",
    "chemical_superclass" = "structure_taxonomy_npclassifier_02superclass",
    "chemical_class" = "structure_taxonomy_npclassifier_03class"
  )
) |>
  dplyr::distinct()

message("Loading NPClassifier taxonomy")
taxonomy <- jsonlite::fromJSON(txt = path_npc_json)

message("Cleaning NPClassifier taxonomy")
taxonomy_semiclean <- treat_npclassifier_json() |>
  tidyr::pivot_longer(
    cols = 1:3,
    names_to = "level",
    values_to = "name"
  ) |>
  dplyr::distinct()

message("Counting structure per group")
structures_count <- structures_classified |>
  dplyr::filter(!is.na(chemical_class)) |>
  dplyr::group_by(chemical_class) |>
  dplyr::add_count(name = "class") |>
  dplyr::filter(!is.na(chemical_superclass)) |>
  dplyr::group_by(chemical_superclass) |>
  dplyr::add_count(name = "superclass") |>
  dplyr::group_by(chemical_pathway) |>
  dplyr::add_count(name = "pathway") |>
  tidyr::pivot_longer(
    cols = 5:7,
    names_to = "level",
    values_to = "values"
  ) |>
  tidyr::pivot_longer(
    cols = 2:4,
    names_to = "class_name",
    values_to = "name"
  ) |>
  dplyr::distinct(name, values, level) |>
  dplyr::bind_rows(data.frame(
    "level" = c("pathway", "superclass", "class"),
    "values" = as.integer(nrow(
      structures_classified |>
        dplyr::filter(
          is.na(chemical_pathway) &
            is.na(chemical_superclass) &
            is.na(chemical_class)
        )
    )),
    "name" = "Not classified"
  ))

message("Combining with NPClassifier taxonomy")
structures_final <- taxonomy_semiclean |>
  dplyr::bind_rows(data.frame(
    "level" = c("pathway", "superclass", "class"),
    "name" = "Not classified"
  )) |>
  dplyr::left_join(structures_count) |>
  dplyr::filter(!is.na(name)) |>
  tidyr::replace_na(list(values = 0)) |>
  dplyr::arrange(dplyr::desc(values), dplyr::desc(level))

message("Pathway level")
pathways <- structures_final |>
  dplyr::filter(level == "pathway") |>
  dplyr::distinct(name, values)
head(pathways, 10)
message(
  "We have ",
  nrow(pathways |> dplyr::filter(values == 0)),
  " on ",
  nrow(pathways),
  " NPClassifier pathways not present in LOTUS"
)
message(pathways |> dplyr::filter(values == 0) |> dplyr::pull(name))

message("Superclass level")
superclasses <- structures_final |>
  dplyr::filter(level == "superclass") |>
  dplyr::distinct(name, values)
head(superclasses, 10)
message(
  "We have ",
  nrow(superclasses |> dplyr::filter(values == 0)),
  " on ",
  nrow(superclasses),
  " NPClassifier superclasses not present in LOTUS"
)
message(superclasses |> dplyr::filter(values == 0) |> dplyr::pull(name))


message("Class level")
classes <- structures_final |>
  dplyr::filter(level == "class") |>
  dplyr::distinct(name, values)
head(classes, 10)
message(
  "We have ",
  nrow(classes |> dplyr::filter(values == 0)),
  " on ",
  nrow(classes),
  " NPClassifier classes not present in LOTUS"
)
message(classes |> dplyr::filter(values == 0) |> dplyr::pull(name))

message(
  "We have ",
  nrow(structures_classified |>
    dplyr::filter(
      is.na(chemical_pathway) &
        is.na(chemical_superclass) &
        is.na(chemical_class)
    )),
  " on ",
  nrow(structures_classified |>
    dplyr::distinct(structure_id)),
  " LOTUS structures that are not classified at all by NPClassifier"
)
