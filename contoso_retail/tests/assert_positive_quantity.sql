-- Fail if quantity is zero or negative

SELECT
    order_key,
    line_number,
    quantity
FROM {{ ref('fact_sales') }}
WHERE quantity <= 0