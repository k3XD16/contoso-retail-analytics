-- Count the number of rows in each of the tables

SELECT 'BRONZE_ORDERS' AS table_name, COUNT(*) AS row_count FROM {{ source('bronze', 'BRONZE_ORDERS') }}
UNION ALL
SELECT 'BRONZE_ORDERROWS', COUNT(*) FROM {{ source('bronze', 'BRONZE_ORDERROWS') }}
UNION ALL
SELECT 'BRONZE_CUSDEV_CONTOSO_RETAILTOMERS', COUNT(*) FROM {{ source('bronze', 'BRONZE_CUSTOMER') }}
UNION ALL
SELECT 'BRONZE_PRODUCTS', COUNT(*) FROM {{ source('bronze', 'BRONZE_PRODUCT') }}
UNION ALL
SELECT 'BRONZE_STORES', COUNT(*) FROM {{ source('bronze', 'BRONZE_STORE') }}
UNION ALL
SELECT 'BRONZE_DATES', COUNT(*) FROM {{ source('bronze', 'BRONZE_DATE') }}
UNION ALL
SELECT 'BRONZE_CURRENCYEXCHANGE', COUNT(*) FROM {{ source('bronze', 'BRONZE_CURRENCYEXCHANGE') }};



-- Select a sample of rows from bronze tables to validate data ingestion

SELECT * FROM {{ source('bronze', 'BRONZE_CURRENCYEXCHANGE') }} LIMIT 100;

SELECT * FROM {{ source('bronze', 'BRONZE_DATE') }} LIMIT 100;

SELECT * FROM {{ source('bronze', 'BRONZE_CUSTOMER') }} LIMIT 100;

SELECT * FROM {{ source('bronze', 'BRONZE_ORDERS') }} LIMIT 100;

SELECT * FROM {{ source('bronze', 'BRONZE_ORDERROWS') }} LIMIT 100;

SELECT * FROM {{ source('bronze', 'BRONZE_PRODUCT') }} LIMIT 100;

SELECT * FROM {{ source('bronze', 'BRONZE_STORE') }} LIMIT 100;



-- select a sample of rows from the silver staging models to validate transformations and data quality

SELECT * FROM {{ ref('stg_currencyexchange') }} LIMIT 100;

SELECT * FROM {{ ref('stg_customer') }} LIMIT 100;

SELECT * FROM {{ ref('stg_date') }} LIMIT 100;

SELECT * FROM {{ ref('stg_product') }} LIMIT 100;

SELECT * FROM {{ ref('stg_orders') }} LIMIT 100;

SELECT * FROM {{ ref('stg_orderrows') }} LIMIT 100;

SELECT * FROM {{ ref('stg_store') }} LIMIT 100;



-- select a sample of rows from the silver intermediate models to validate transformations and data quality

SELECT * FROM {{ ref('int_order_details') }} LIMIT 100;

SELECT * FROM {{ ref('int_customer_metrics') }} LIMIT 100;



-- Select a sample of rows from the gold layer and final models
SELECT * FROM {{ ref('obt_sales')}} LIMIT 100;

SELECT * FROM {{ ref('fact_sales')}} LIMIT 100;

SELECT * FROM {{ ref('dim_customer')}} LIMIT 100;

SELECT * FROM {{ ref('dim_product')}} LIMIT 100;

SELECT * FROM {{ ref('dim_store')}} LIMIT 100;

SELECT * FROM {{ ref('dim_date')}} LIMIT 100;
