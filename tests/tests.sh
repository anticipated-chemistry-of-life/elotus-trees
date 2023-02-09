#!/usr/bin/env bash

if [ ! -d config ]; then
  echo "Sorry, you need to run that from where your config is."
  exit 1
fi

cp -R config/default config/params &&
Rscript inst/scripts/count_npclasses.R &&
Rscript inst/scripts/papers_taxa_correlation.R &&
Rscript inst/scripts/prepare_pseudoabsence_tables.R &&
Rscript inst/scripts/prettyStructuresTable.R &&
Rscript inst/scripts/prettyTree.R
