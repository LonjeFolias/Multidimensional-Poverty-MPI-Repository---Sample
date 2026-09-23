# Static code review

This review records issues identified without executing the scripts against the restricted source microdata. It is intentionally transparent: documentation must not imply that code has passed an end-to-end reproduction test when the required data are unavailable.

## Child MPI scripts

- The scripts depend on wave-specific globals and survey modules established outside the files.
- Several merges suppress `_merge` using `nogen`; a production version should inspect and assert merge results before continuing.
- Some missing observations are treated as deprivation and others as non-deprivation. These are substantive methodological decisions and must be checked against the approved child-MPI specification.
- The scripts contain wave-specific variable names and cannot be transferred to another survey by changing only the file path.
- The consultancy provenance stated in the headers should remain visible.

## Household MPI source

- The source contains a personal hard-coded project path and depends on an `asset.dta` file created elsewhere. These must be replaced with a controlled configuration and documented preparation step before reproducible execution.
- A duplicate command creates `hh_15_counta` twice and would stop execution on the second occurrence.
- Several merges suppress `_merge`; merge coverage and key uniqueness should be checked explicitly.
- All missing deprivation indicators are recoded to zero before aggregation. This assumption may bias the index and requires methodological approval.
- The direction of selected indicators, including electricity and asset ownership, should be checked against the source questionnaire and approved deprivation definitions before use.
- The external `mpi` command and its version must be documented. A production workflow should also calculate and reconcile H, A and M0 transparently rather than rely only on a user-written command.

## Publication status

The repository is suitable as a documented code-review and capacity-building example. It should not be described as independently reproduced or publication-ready until the issues above are resolved and the complete workflow is tested with authorised source data.
