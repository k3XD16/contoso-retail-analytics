WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_CURRENCYEXCHANGE') }}
),
renamed_and_cleaned AS (
    SELECT
        EXCHANGE_DATE                                       AS exchange_date,
        TRIM(FROM_CURRENCY)                                 AS from_currency,
        TRIM(TO_CURRENCY)                                   AS to_currency,
        CAST(EXCHANGE AS DECIMAL(18,6))                     AS exchange_rate,
        CONCAT(TRIM(FROM_CURRENCY), '_', TRIM(TO_CURRENCY)) AS currency_pair,
        CURRENT_TIMESTAMP()                                 AS loaded_at
    FROM source
) 
SELECT * FROM renamed_and_cleaned