## Code directory

### General Workflow

1.  You updated the config.json... right?:

    -   If yes... You Rock!
    -   If not... no worries... Follow instructions in the
        [config/README.md](/config/README.md) file for instructions

2.  Run [00_setup_script](00_renv_restore.R)

3.  Run [01_cohorting_script](01_cohorting.qmd)

4.  Run [02_analysis_script](02_statistical_analysis.qmd)

    -   **After opening** you may have to click **install** at the top
        of R studio!!... then run
    -   **Windows Users** you make need to download
        [RTools](https://cran.r-project.org/bin/windows/Rtools/ "Go here and download appropriate Rtools package for your version of R")
    -   Cohorts based on ventilator data and start/end times
    -   Then performs project-specific quality control checks on the
        filtered cohort data
    -   Handles outliers using predefined thresholds as given in
        `outlier-thresholds` directory.
    -   Clean and preprocess the data for analysis

    Input:

    -   rclif tables
        -   tables should be named `clif_xyz`

    Output:

    -   **Intermediate** folder (part of git.ignore)

        -   2 check point files (these are parquet files and will be
            ignored)

        -   table1s for each hospital

        -   pdf of vent variation across hospitals

        -   2 "most recent" r.data that will help you restart at
            checkpoints!

    -   **Final** folder

        -   *mode_hospital_summary*: this is aggregated hospital data
            for modes

        -   *mode_hourly_resp_support*: this is aggregated mode data

        -   *lttv_variation_table*: this is aggregated data to compare
            hospitals

        -   *hospital_table1_summary*: this is for table 1

        -   *ltvv_female_table*: this is aggregated data to eval
            difference between Vt \~ sex_category

        -   *model_coefs_daily*: looking at differences in sf, pf, laps2
            scores as severity of illness

            -   outcomes are `inhospital_mortality` and
                `ventilator_free_days`

        -   *model_coefs_sex_category:* these are different models
            looking at the relationship between sex_category and height

        -   *model_preds_sex_category*: predictions at the median/most
            common for plotting
