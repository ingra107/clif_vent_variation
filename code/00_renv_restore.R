# 00_renv_restore.R
# Ensure renv is installed and load the project environment

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}


# Restore the project's package environment
# renv::activate()
# renv::restore()


# # Initialize renv for the project:
# renv::init(bare = TRUE, settings = list(use.cache = FALSE))
# 
# # Install required packages:
# renv::install("BiocManager")
# BiocManager::install("IRanges")
# 
# # renv::install(c("tidyverse", "ggthemes", "systemfonts",  "styler", "readxl", "writexl", "DBI", "dbplyr", "knitr", "pandoc", "janitor", "data.table", "duckdb" ,"powerjoin", "collapse", "tidyfast", "datapasta", "fst", "dtplyr", "bit64", "zoo", "fuzzyjoin", "arrow", "hrbrthemes", "here", "table1", "rvest", "tidymodels", "pscl", "survminer", "gt", "gtsummary", "broom.helpers", "broom.mixed", "lme4", "lmerTest", "merTools"))
# 
#   
# renv::install(c("tidyverse", "systemfonts", "readxl", "DBI", "dbplyr", "knitr", "janitor", "data.table", "powerjoin", "collapse", "tidyfast", "datapasta", "fst", "dtplyr", "bit64", "arrow", "hrbrthemes", "here", "table1", "rvest", "tidymodels", "pscl", "survival", "survminer", "gt", "gtsummary", "broom.helpers"))
# 
# # # Save the project's package state:
# renv::snapshot()


library(lmerTest)
library(tidyverse)
library(systemfonts)
library(readxl)
library(DBI)
library(dbplyr)
library(knitr)
library(janitor)
library(data.table)
library(powerjoin)
library(collapse)
library(tidyfast)
library(datapasta)
library(fst)
library(dtplyr)
library(bit64)
library(arrow)
library(hrbrthemes)
library(here)
library(table1)
library(rvest)
library(gt)
library(gtsummary)
library(broom.helpers)
library(broom.mixed)
# library(tidymodels)
library(pscl)
library(survival)
library(survminer)
library(merTools)
library(lme4)
library(finalfit)
library(furrr)
library(rms)
library(ggeffects)

select <- dplyr::select

setDTthreads(0)

# Plan for parallel execution
plan(multisession)



## create output directories 
create_directories <- function() {
  # Define the directories
  dirs <- c("output", "output/intermediate", "output/final",  "output/intermediate/clean_db")
  
  # Loop through and create directories if they don't exist
  for (dir in dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
      message(paste("Directory created:", dir))
    } else {
      message(paste("Directory already exists:", dir))
    }
  }
}

# Call the function to create the directories
create_directories()



# Load the configuration utility
source("utils/config.R")

# Access configuration parameters
site_name <- config$site_name
tables_path <- config$tables_path
file_type <- config$file_type


# Print the configuration parameters
print(paste("Site Name:", site_name))
print(paste("Tables Path:", tables_path))
print(paste("File Type:", file_type))



# List of all table names from the CLIF 2.0 ERD
tables <- c(
  "patient",
  "hospitalization",
  "vitals",
  "labs",
  "medication_admin_continuous",
  "adt",
  "patient_assessments",
  "respiratory_support",
  "position",
  "dialysis",
  "intake_output",
  "ecmo_mcs",
  "procedures",
  "admission_diagnosis",
  "provider",
  "sensitivity",
  "medication_orders",
  "medication_admin_intermittent",
  "therapy_details",
  "microbiology_culture",
  "sensitivity",
  "microbiology_nonculture"
)

# Tables that should be set to TRUE for this project
true_tables <- c(
  "hospitalization",
  "vitals",
  "labs",
  # "medication_admin_continuous",
  "adt",
  # "patient_assessments",
  "respiratory_support",
  # "position",
  # "dialysis",
  # "intake_output",
  # "ecmo_mcs",
  # "procedures",
  # "admission_diagnosis",
  # "provider",
  # "sensitivity",
  # "medication_orders",
  # "medication_admin_intermittent",
  # "therapy_details",
  # "microbiology_culture",
  # "sensitivity",
  # "microbiology_nonculture",
  "patient"
)

# Create a named vector and set the boolean values
table_flags <- setNames(tables %in% true_tables, tables)


# List all CLIF files in the directory
clif_table_filenames <- list.files(path = tables_path, 
                                   pattern = paste0("^clif_.*\\.", file_type, "$"), 
                                   full.names = TRUE)

# Extract the base names of the files (without extension)
clif_table_basenames <- basename(clif_table_filenames) %>%
  str_remove(paste0("\\.", file_type, "$"))

# Create a lookup table for required files based on table_flags
required_files <- paste0("clif_", names(table_flags)[table_flags])

# Check if all required files are present
missing_tables <- setdiff(required_files, clif_table_basenames)
if (length(missing_tables) > 0) {
  stop(paste("Missing required tables:", 
             paste(missing_tables, collapse = ", ")))
}

# Filter only the filenames that are required
required_filenames <- clif_table_filenames[clif_table_basenames %in% required_files] 


# Quickly look at the data like we would in stata, default is 100
ni_peek <- function(x, n=100){
  view(head(x, n))
}

# check missing variables
ni_count_missing <- function(df, group_vars, x_var) {
  df |> 
    group_by(pick({{ group_vars }})) |> 
    summarise(
      n_miss = sum(is.na({{ x_var }})),
      .groups = "drop"
    )
}
# flights |>  count_missing(c(year, month, day), dep_time)

# look at the variables
ni_check_variables <- function(df, n=500) {
  check <- tibble(
    col_name = names(df), 
    col_type = map_chr(df, vctrs::vec_ptype_full),
    n_miss = map_int(df, \(x) sum(is.na(x)))
  )
  print(check, n=n)
}

ni_count_prop <- function(df, var, sort = TRUE) {
  df |>
    count({{ var }}, sort = sort) |>
    mutate(prop = n / sum(n)
    )
}

# Identify and create a table of duplicate rows based on clif_hospitalizations_joined_id
ni_duplicate_finder <- function(df, group_vars = c(clif_hospitalizations_joined_id), n=1){
  df |> 
    dplyr::group_by(pick({{ group_vars }})) |> 
    filter(n() > {{ n }}) |> 
    ungroup()
}

ni_tic <- function() {
  .GlobalEnv$time_start_temp <- proc.time()
  .GlobalEnv$time_start_sys <- Sys.time()
  return(Sys.time())
}

ni_toc <- function() {
  time_end_sys <- Sys.time()
  .GlobalEnv$time_diff.time <- round(time_end_sys - time_start_sys,2)
  mylist <- list(time_diff.time, cat("Finished in",timetaken(time_start_temp),"\n"
  ))
  return(print(mylist[[1]]))
}

fio2warning <- function() {
  warning("fio2 variable needed to be fixed, it was multiplied by 100!!!")
}

labwarning <- function() {
  warning("lab values are character and needed to be fixed, they were forced to numeric!!!")
}

vitalwarning <- function() {
  warning("vital values are character and needed to be fixed, they were forced to numeric!!!")
}



read_data <- function(file_path) {
  file_path_temp <- paste0(tables_path,"/", file_path, ".", file_type)
  print(file_path_temp)
  
  if (grepl("\\.csv$", file_path_temp)) {
    return(read.csv(file_path_temp) |> 
             mutate(across(ends_with("_id"), as.character))
    )
    
  } else if (grepl("\\.parquet$", file_path_temp)) {
    return(arrow::open_dataset(file_path_temp)  |> 
             mutate(across(ends_with("_id"), as.character)) |> 
             collect()
    )
    
  } else if (grepl("\\.fst$", file_path_temp)) {
    return(fst::read.fst(file_path_temp) |> 
             mutate(across(ends_with("_id"), as.character))
    )
  } else {
    stop("Unsupported file format")
  }
}

# for quick opening and filtering...
#     ni_open_dataset_clif(adt) |> filter(patient_id == "asdf") |> collect() |> View()
ni_open_dataset_clif <- function(file){
  file_quoted <- deparse(substitute(file))
  open_dataset(paste0(tables_path, "/",  "clif_", file_quoted, ".parquet"), thrift_string_size_limit = 1000000000) |> 
    mutate(across(where(is.character), as.character)) |> 
    mutate(across(where(is.character), str_to_lower)) 
}

## Date range
start_date <- "2018-01-01"
end_date <- "2024-09-30"



message("##########################################
You have completed setup!!! Woohooo!!! \n Please proceed on to 01_cohorting script \n 
##########################################")
