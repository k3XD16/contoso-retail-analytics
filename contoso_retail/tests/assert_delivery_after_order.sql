-- Fail if delivery date is before order date

SELECT
    order_key,
    order_date,
    delivery_date
FROM {{ ref('stg_orders') }}
WHERE delivery_date < order_date
