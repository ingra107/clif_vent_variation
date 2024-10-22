# Ventilation Variation

## Objective

-   Explore *low tidal volume ventilation* variation between males and
    females
-   Identify risk factors for length of mechanical ventilation. Specific
    variables of interest:
    -   `ltvv`
    -   `sex`
    -   `oxygenation_index`
    -   `hospital`

## Required CLIF tables and fields

Please refer to the online [CLIF data
dictionary](https://clif-consortium.github.io/website/data-dictionary.html),
[ETL
tools](https://github.com/clif-consortium/CLIF/tree/main/etl-to-clif-resources),
and [specific table
contacts](https://github.com/clif-consortium/CLIF?tab=readme-ov-file#relational-clif)
for more information on constructing the required tables and fields.
List all required tables for the project here, and provide a brief
rationale for why they are required.

The following tables are required:

1.  **patient**: `patient_id`, `race_category`, `ethnicity_category`,
    `sex_category`, `death_date`
2.  **hospitalization**: `hospitalization_id`, `admission_dttm`,
    `discharge_dttm`, `age_at_admission`, `patient_id`,
    `admission_type_name`, `admission_type_category`, `discharge_name`,
    `discharge_category`
3.  **vitals**: `hospitalization_id`, `recorded_dttm`, `vital_category`,
    `vital_value` - `vital_category` = 'heart_rate', 'resp_rate', 'sbp',
    'dbp', 'map', 'resp_rate', 'spo2'
4.  **labs**: `hospitalization_id`, `lab_result_dttm`, `lab_order_dttm`,
    `lab_collect_dttm`, `lab_category`, `lab_name`, `lab_value_numeric`,
    `reference_unit`, `lab_category` = 'sodium', 'albumin', 'anion_gap',
    'bilirubin_total', 'bun', 'carbon_dioxide', 'creatinine',
    'glucose_serum', 'hemoglobin', 'lactate',
    'pco2_arterial', 'po2_arterial', 'ph_arterial', 'platelet_count',
    'so2_arterial', 'sodium', 'troponin_i', 'wbc'
5.  **adt**: `hospitalization_id`, `in_dttm`,
    `out_dttm`, `location_name`, `location_category`
6.  **respiratory_support**: `hospitalization_id`, `recorded_dttm`,
    `device_name`, `device_category`, `mode_name`, `mode_category`,
    `fio2_set`, `lpm_set`, `tidal_volume_set`, `resp_rate_set`,
    `pressure_support_set`, `peep_set`, `tidal_volume_obs`,
    `plateau_pressure_obs`, `peak_inspiratory_pressure_obs`,
    `mean_airway_pressure_obs`, `minute_vent_obs`, `tracheostomy`
7.  **patient_assessments**: `hospitalization_id`, `recorded_dttm`,
    `numerical_value`, `assessment_category` = "gcs_total"

## Cohort identification

### Inclusion

1.  Adults (age \>= 18 years old)
2.  Mechnical Ventilation within 72 hours of admission
3.  Admission from 2020-2021
4.  Volume control with a set tidal volume within 24 hours of mechanical
    ventilation

### Exclusion

1.  Patient that died within 24 hours of mechanical ventilation

## Expected Results

`Table 1` - descriptive data by hospital `aggregaged data 1` - male vs.
female LTVV `aggregated data 2` - odds ratios for regression of
ventilator days

project results will be saved in the [`output/final`](output/README.md)
directory.

## Detailed Instructions for running the project

## 1. Setup Project Environment **(Script Developer Only)**

*This has been completed by Nick when making this script already*
(**SKIP**)\
Describe the steps to setup the project environment.

```         
# Install renv if not already installed:
if (!require("renv", quietly = TRUE)) {
  install.packages("renv")
}
# Initialize renv for the project:
renv::init(bare = TRUE, settings = list(use.cache = FALSE))

# Install required packages:
renv::install("BiocManager")
BiocManager::install("IRanges")

# renv::update()
renv::install(c("tidyverse", "ggthemes", "systemfonts",  "styler", "readxl", "writexl", "DBI", "dbplyr", "knitr", "pandoc", "janitor", "data.table", "duckdb" ,"powerjoin", "collapse", "tidyfast", "datapasta", "fst", "dtplyr", "bit64", "zoo", "fuzzyjoin", "arrow", "hrbrthemes", "here", "table1", "rvest", "tidymodels", "pscl", "survminer"))

# Save the project's package state:
renv::snapshot()
```

Example for Python:

```         
python3 -m venv .mobilization
source .mobilization/bin/activate
pip install -r requirements.txt 
```

## 2. Update `config/config.json`

Follow instructions in the [config/README.md](config/README.md) file for
detailed configuration steps.

## 3. Run code

Detailed instructions on the code workflow are provided in the [code
directory](code/README.md)

## Example Repositories

-   [CLIF Adult Sepsis
    Events](https://github.com/08wparker/CLIF_adult_sepsis_events) for R

-   [CLIF Eligibility for
    mobilization](https://github.com/kaveriC/mobilization) for Python
