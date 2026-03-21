-- Staging: Cleaning the orders data
WITH source AS (
    SELECT 
        * 
    FROM {{ source ('bronze','BRONZE_ORDERS')}}
),
renamed_and_cleaned AS (
    SELECT
        ORDERKEY AS order_key,
        CUSTOMERKEY AS customer_key,
        STOREKEY AS store_key,
        ORDERDATE AS order_date,
        DELIVERYDATE AS delivery_date,
        CURRENCYCODE AS currency_code,
        DATEDIFF('day', ORDERDATE, DELIVERYDATE) AS delivery_days,
        CURRENT_TIMESTAMP() AS loaded_at
    FROM source       
)
SELECT *
FROM renamed_and_cleaned
