## Code directory

### General Workflow

1.  You updated the config.json... right?:

    -   If yes... You Rock!
    -   If not... no worries... Follow instructions in the
        [config/README.md](/config/README.md) file for instructions

2.  Run [vent_variation_qmd](01_ventilation_variation_script.qmd)

    -   **After opening** you may have to click **install** at the top
        of R studio!!... then run
    -   Cohorts
    -   Then performs project-specific quality control checks on the
        filtered cohort data
    -   Handles outliers using predefined thresholds as given in
        `outlier-thresholds` directory.
    -   Clean and preprocess the data for analysis

    Input:

    -   rclif tables

    Output:

    -   **Intermediate** folder (part of git.ignore)

        -   2 check point files (these are parquet files and will be
            ignored)

        -   table1s for each hospital

        -   pdf of vent variation across hospitals

        -   2 "most recent" r.data that will help you restart at
            checkpoints!

    -   **Final** folder

        -   *lttv_variation_table*: this is aggregated data to compare
            hospitals

        -   *mode_hospital_summary*: this is aggregated mode data

        -   *trach_variation_table*: this is aggregated data for time to
            trach
