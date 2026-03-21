WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_STORE') }}
),
renamed_and_cleaned AS (
    SELECT
        StoreKey AS store_key,
        TRIM(StoreCode) AS store_code,
        GeoAreaKey AS geo_area_key,
        TRIM(CountryCode) AS country_code,
        TRIM(CountryName) AS country_name,
        TRIM(State) AS state,
        TRY_TO_DATE(OpenDate) AS open_date,
        TRY_TO_DATE(CloseDate) AS close_date,
        TRIM(Description) AS description,
        SquareMeters AS square_meters,
        COALESCE(TRIM(Status), 'Active') AS status,
        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at
    FROM source
)

SELECT * FROM renamed_and_cleaned