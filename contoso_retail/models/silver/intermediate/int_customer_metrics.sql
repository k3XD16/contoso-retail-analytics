-- Intermediate: Customer-level aggregated metrics

WITH order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),

customer_aggregates AS (
    SELECT
        customer_key,

        -- Order metrics
        COUNT(DISTINCT order_key)       AS total_orders,
        SUM(quantity)                   AS total_items_purchased,

        -- Revenue metrics
        SUM(gross_revenue)              AS total_gross_revenue,
        SUM(net_revenue)                AS total_net_revenue,
        SUM(total_cost)                 AS total_cost,
        SUM(profit)                     AS total_profit,
        AVG(profit_margin_pct)          AS avg_profit_margin_pct,

        -- Date range (uses order_date since date_key may be NULL from LEFT JOIN)
        MIN(order_date)                 AS first_order_date,
        MAX(order_date)                 AS last_order_date,
        MIN(date_key)                   AS first_order_date_key,
        MAX(date_key)                   AS last_order_date_key,

        -- Recency
        DATEDIFF('day', MAX(order_date), CURRENT_DATE()) AS days_since_last_order

    FROM order_details
    GROUP BY customer_key
)

SELECT * FROM customer_aggregates
