WITH stg_date AS (
    SELECT * FROM {{ ref('stg_date') }}
),

final AS (
    SELECT
        date_key,
        date_value,
        year,
        year_quarter,
        year_quarter_number,
        quarter,
        year_month,
        year_month_short,
        year_month_number,
        month_name,
        month_short,
        month_number,
        day_of_week,
        day_of_week_short,
        day_of_week_number,
        is_working_day,
        working_day_number,

        CASE
            WHEN day_of_week_number IN (6, 7) THEN TRUE
            ELSE FALSE
        END AS is_weekend,

        CURRENT_TIMESTAMP() AS loaded_at

    FROM stg_date
)

SELECT * FROM final
