# MPI Stata Reproducibility Examples

This repository contains documented Stata examples for constructing multidimensional poverty indices (MPIs) from Malawi household survey data. It is curated by **Lonjezo Erick Folias of Everest Intelligence Consult (EIC)** to demonstrate transparent indicator construction, weighting, poverty identification and reproducible statistical workflows.

## Scope

The repository contains only code directly related to MPI construction:

- child MPI implementations for the 2013, 2016 and 2019 Malawi Integrated Household Panel Survey waves; and
- a household-level MPI implementation developed by Lonjezo Erick Folias.

It deliberately excludes microdata, personally identifiable information, panel-merging code, labels-only scripts and econometric models that do not construct an MPI.

## Repository structure

```text
code/
  child_mpi/
    01_child_mpi_2013.do
    02_child_mpi_2016.do
    03_child_mpi_2019.do
  household_mpi/
    01_household_mpi_source.do
config/
  paths_template.do
documentation/
  methodology_and_run_guide.md
sample_data/
  README.md
```

## Important attribution

The child-MPI scripts identify **Happy Banda** as the original creator and the **NSO** as owner. Those credits are preserved. Lonjezo Erick Folias and EIC are credited only for repository curation and documentation. The household MPI implementation identifies Lonjezo Erick Folias as its creator.

Publication or reuse of the child-MPI scripts remains subject to confirmation of the original owner's permission. No open-source licence is asserted for those files in the absence of that confirmation.

## Data

No survey microdata are included. Users must obtain the relevant Malawi household survey files through the authorised data provider and comply with all applicable access and confidentiality conditions. Source datasets should never be committed to this repository.

## Reproducibility status

These scripts are documented research examples, not a final SADC Harmonised MPI specification. They depend on source variables, survey modules and file paths from the original projects. Before use, analysts must:

1. obtain the authorised source data;
2. configure local paths using `config/paths_template.do`;
3. verify variable names and survey universes against the relevant questionnaires;
4. review deprivation definitions, weights and the poverty cutoff; and
5. validate all outputs before publication or policy use.

See [documentation/methodology_and_run_guide.md](documentation/methodology_and_run_guide.md) for further guidance.

Before treating the source scripts as production-ready, review the documented issues in [documentation/static_code_review.md](documentation/static_code_review.md).

## Contact

**Lonjezo Erick Folias**  
Everest Intelligence Consult (EIC)

