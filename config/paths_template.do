/*******************************************************************************
* MPI STATA REPRODUCIBILITY EXAMPLES: LOCAL PATH CONFIGURATION
* Curated by: Lonjezo Erick Folias, Everest Intelligence Consult (EIC)
*
* Copy this file to config/paths_local.do and replace the example root path.
* Do not commit paths_local.do or any restricted source data.
*******************************************************************************/

version 17.0
clear all
set more off

* Change only this path for the local installation.
global mpi_project_root "C:/replace/with/local/mpi-project"

global mpi_code   "${mpi_project_root}/code"
global mpi_raw    "${mpi_project_root}/data/raw"
global mpi_work   "${mpi_project_root}/data/working"
global mpi_output "${mpi_project_root}/output"
global mpi_logs   "${mpi_project_root}/logs"

