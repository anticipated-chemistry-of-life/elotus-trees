# elotus-trees

Repository for first explorations on lotus data.

## tl;dr

Normally, all paths and parameters are externalized in `paths.yaml` and `config/default/params.yaml`.
This means you should not need to modify any arguments in R scripts.
If anyone feels uncomfortable with this way to do, shout out loud. 
We might also implement those arguments as command line arguments.

## Required packages

They should install from themselves if you do not have them.
Only thing you will probably need to configure is `remotes` as described [here](https://remotes.r-lib.org/).

## Working scripts

- inst/scripts/count_npclasses.R
- inst/scripts/papers_taxa_correlation.R (no output written for now)
- inst/scripts/prepare_pseudoabsence_tables.R
- inst/scripts/prettyStructuresTable.R
- inst/scripts/prettyTree.R

This README will be improved over time.
