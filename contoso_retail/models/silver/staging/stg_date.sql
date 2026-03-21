WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_DATE') }}
),
renamed_and_cleaned AS (
    SELECT
        DATEKEY                         AS date_key,
        TRY_TO_DATE(DATE_VALUE)         AS date_value,
        YEAR                            AS year,
        TRIM(YEARQUARTER)               AS year_quarter,
        YEARQUARTERNUMBER               AS year_quarter_number,
        TRIM(QUARTER)                   AS quarter,
        TRIM(YEARMONTH)                 AS year_month,
        TRIM(YEARMONTHSHORT)            AS year_month_short,
        YEARMONTHNUMBER                 AS year_month_number,
        TRIM(MONTH)                     AS month_name,
        TRIM(MONTHSHORT)                AS month_short,
        MONTHNUMBER                     AS month_number,
        TRIM(DAYOFWEEK)                 AS day_of_week,
        TRIM(DAYOFWEEKSHORT)            AS day_of_week_short,
        DAYOFWEEKNUMBER                 AS day_of_week_number,
        WORKINGDAY                      AS is_working_day,
        WORKINGDAYNUMBER                AS working_day_number,
        CURRENT_TIMESTAMP()             AS loaded_at
    FROM source
)
SELECT * FROM renamed_and_cleaned
