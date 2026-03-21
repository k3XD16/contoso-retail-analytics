WITH stores AS (
    SELECT * FROM {{ ref('stg_store') }}
),

final AS (
    SELECT
        store_key,
        store_code,
        geo_area_key,
        country_code,
        country_name,
        state,
        open_date,
        close_date,
        description,
        square_meters,
        status,

        -- Flags
        CASE
            WHEN close_date IS NOT NULL THEN FALSE
            ELSE TRUE
        END AS is_active,

        DATEDIFF('day', open_date,
            COALESCE(close_date, CURRENT_DATE())) AS days_operational,

        CURRENT_TIMESTAMP() AS loaded_at

    FROM stores
)

SELECT * FROM final
