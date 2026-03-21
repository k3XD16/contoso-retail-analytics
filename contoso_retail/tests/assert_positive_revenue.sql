-- FAIL if any net_revenue is negative

SELECT 
    order_key,
    line_number,
    net_revenue
FROM {{ ref ('fact_sales')}}
WHERE net_revenue < 0