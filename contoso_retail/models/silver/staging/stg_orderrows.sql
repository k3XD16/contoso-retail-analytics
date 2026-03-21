-- Staging: Cleaning the order_rows data
WITH source AS (
    SELECT 
        *
    FROM {{ source ('bronze','BRONZE_ORDERROWS') }}
),
renamed_and_cleaned AS (
    SELECT 
        ORDERKEY AS order_key,
        LINENUMBER AS line_number,
        PRODUCTKEY AS product_key,
        QUANTITY AS quantity,
        CAST(UNITPRICE AS DECIMAL(18,2)) AS unit_price,
        CAST(NETPRICE AS DECIMAL(18,2)) AS net_price,
        CAST(UNITCOST AS DECIMAL(18,2)) AS unit_cost,
        CAST(QUANTITY * UNITPRICE AS DECIMAL(18,2)) AS gross_revenue,
        CAST(Quantity * NetPrice AS DECIMAL(18,2)) AS net_revenue,
        CAST(Quantity * UnitCost AS DECIMAL(18,2)) AS total_cost,
        CAST((NetPrice - UnitCost) * Quantity AS DECIMAL(18,2)) AS profit,
        CURRENT_TIMESTAMP() AS loaded_at
    FROM source
)
SELECT * FROM renamed_and_cleaned