-- Intermediate: Enriched order details with products and pricing

WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

order_rows AS (
    SELECT * FROM {{ ref('stg_orderrows') }}
),

products AS (
    SELECT * FROM {{ ref('stg_product') }}
),

dates AS (
    SELECT * FROM {{ ref('stg_date') }}
),

joined AS (
    SELECT
        o.order_key,
        o.order_date,
        o.delivery_date,
        o.currency_code,
        o.delivery_days,

        d.date_key,
        d.year,
        d.quarter,
        d.month_name,
        d.month_number,
        d.day_of_week,
        d.is_working_day,

        o.customer_key,
        o.store_key,

        r.line_number,
        r.product_key,
        p.product_name,
        p.brand,
        p.category_name,
        p.subcategory_name,

        r.quantity,
        r.unit_price,
        r.net_price,
        r.unit_cost,
        r.gross_revenue,
        r.net_revenue,
        r.total_cost,
        r.profit,

        {{ calc_profit_margin('r.profit','r.net_revenue') }} AS profit_margin_pct

    FROM orders o
    INNER JOIN order_rows r   ON o.order_key   = r.order_key
    INNER JOIN products p     ON r.product_key = p.product_key
    LEFT JOIN  dates d        ON d.date_value  = o.order_date  -- join on date
)

SELECT * FROM joined