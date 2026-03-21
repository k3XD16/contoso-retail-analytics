-- Staging: Cleaning the customer data

WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_CUSTOMER') }}
),
renamed_and_cleaned AS (
    SELECT

        CustomerKey         AS customer_key,
        GeoAreaKey          AS geo_area_key,

        TRY_TO_DATE(StartDT) AS start_dt,
        TRY_TO_DATE(EndDT)   AS end_dt,
        TRIM(Continent)     AS continent,
        TRIM(Country)       AS country_code,
        TRIM(CountryFull)   AS country_name,
        TRIM(State)         AS state_code,
        TRIM(StateFull)     AS state_name,
        TRIM(City)          AS city,
        TRIM(ZipCode)       AS zip_code,
        TRIM(StreetAddress) AS street_address,
        CAST(Latitude  AS DECIMAL(10,6)) AS latitude,
        CAST(Longitude AS DECIMAL(10,6)) AS longitude,
        TRIM(Title)         AS title,
        TRIM(GivenName)     AS first_name,
        TRIM(MiddleInitial) AS middle_initial,
        TRIM(Surname)       AS last_name,
        CONCAT(TRIM(GivenName), ' ', TRIM(Surname)) AS full_name,
        TRIM(Gender)        AS gender,
        TRY_TO_DATE(Birthday) AS birth_date,
        CAST(Age AS INT)    AS age,
        TRIM(Occupation)    AS occupation,
        TRIM(Company)       AS company,
        TRIM(Vehicle)       AS vehicle,

        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at

    FROM source
)

SELECT * FROM renamed_and_cleaned


