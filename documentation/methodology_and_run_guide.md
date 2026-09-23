# Methodology and Run Guide

## Purpose

The examples show how survey variables can be transformed into binary deprivation indicators, combined using explicit weights and compared with a multidimensional poverty cutoff. They are intended to make each analytical decision traceable in Stata.

## Child MPI examples

The three child-MPI scripts correspond to the 2013, 2016 and 2019 survey waves. They merge relevant household and individual modules and construct age-specific indicators across dimensions including nutrition, health, protection, education, information, water, sanitation and housing.

The definitions are described in the source scripts as adapted from the Child Multidimensional Poverty Report of 2023. Users must verify the authoritative report, survey questionnaires and eligible populations before reproducing or adapting the indicators.

## Household MPI example

The household implementation constructs deprivation indicators across health, education, living environment and employment. It applies explicit indicator weights, calculates the weighted deprivation score and identifies a household as multidimensionally poor at a cutoff of approximately one third of total weighted deprivations.

The code also calls a user-written Stata `mpi` command. Analysts should verify the installed command, its version and its estimation behaviour before relying on the generated results.

## Recommended run procedure

1. Copy `config/paths_template.do` to a local, untracked configuration file.
2. Confirm access to the correct survey wave and modules.
3. Check household and person identifiers before every merge.
4. Review indicator definitions, universes and missing-value treatment.
5. Confirm that the indicator weights sum to one.
6. Run the relevant script from a clean Stata session and retain the log.
7. Reconcile the adjusted headcount result with its component calculations.
8. Review subgroup estimates against the survey design and available sample size.

## Adaptation warning

These examples must not be treated as a universal MPI specification. National and harmonised MPIs may use different dimensions, indicators, deprivation cutoffs, weights, units of identification and population universes. Any adaptation should begin from an approved methodological specification and a documented indicator-to-variable crosswalk.

## Known reproducibility limitations

- Raw microdata are not distributed with the repository.
- Original scripts include project-specific global paths and module names.
- Some missing values are explicitly treated as deprivation or non-deprivation; these choices require methodological review.
- The source scripts require further execution testing in an authorised environment containing the original survey data.

