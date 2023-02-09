start <- Sys.time()

#' Packages
packages_cran <-
  c(
    "devtools",
    "dplyr",
    "jsonlite",
    "readr",
    "tidyr",
    "yaml"
  )
packages_bioconductor <- NULL
packages_github <- NULL

source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/log_debug.R"
)
source(
  "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/R/parse_yaml_paths.R"
)

source(file = "https://raw.githubusercontent.com/Adafede/cascade/main/R/make_2D.R")
source(file = "https://raw.githubusercontent.com/Adafede/cascade/main/R/make_chromatographiable.R")

source(file = "R/check_and_load_packages.R")
source(file = "R/load_lotus.R")
source(file = "R/parse_yaml_params.R")

check_and_load_packages_1()
check_and_load_packages_2()

devtools::source_url(
  "https://raw.githubusercontent.com/lotusnprod/lotus-processor/main/src/r/treat_npclassifier_json.R"
)

paths <- parse_yaml_paths()
params <- parse_yaml_params()

lotus <- load_lotus()

message("Keeping classified structures")
structures_classified <- lotus |>
  dplyr::select(
    structure_id = structure_inchikey,
    # "structure_exact_mass",
    # "structure_xlogp",
    structure_smiles_2D,
    chemical_pathway = structure_taxonomy_npclassifier_01pathway,
    chemical_superclass = structure_taxonomy_npclassifier_02superclass,
    chemical_class = structure_taxonomy_npclassifier_03class
  ) |>
  dplyr::distinct()

if (params$structures$dimensionality == 2) {
  structures_classified <- structures_classified |>
    make_2D()
}

if (params$structures$c18 == TRUE) {
  structures_classified <- structures_classified |>
    make_chromatographiable()
}

message("Loading NPClassifier taxonomy")
taxonomy <- jsonlite::fromJSON(txt = paths$urls$npc_json)

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
  nrow(pathways) - 1,
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
  nrow(superclasses) - 1,
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
  nrow(classes) - 1,
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

end <- Sys.time()

log_debug("Script finished in", crayon::green(format(end - start)))
