-- Fail if profit margin is outside realistic range (-100% to 100%)

SELECT
    order_key,
    line_number,
    profit_margin_pct
FROM {{ ref('fact_sales') }}
WHERE profit_margin_pct < -100
   OR profit_margin_pct > 100
