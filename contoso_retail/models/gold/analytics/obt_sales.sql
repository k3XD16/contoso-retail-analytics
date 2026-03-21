-- Analytics: OneBigTable (Wide flat table for BI tools)

WITH fact_sales AS (
    SELECT * FROM {{ ref('fact_sales') }}
),
dim_customers AS (
    SELECT * FROM {{ ref('dim_customer') }}
),
dim_products AS (
    SELECT * FROM {{ ref('dim_product') }}
),
dim_stores AS (
    SELECT * FROM {{ ref('dim_store') }}
),
dim_date AS (
    SELECT * FROM {{ ref('dim_date') }}
),

final AS (
    SELECT
        -- Transaction keys
        f.order_key,
        f.line_number,
        f.currency_code,

        -- Date
        d.date_value            AS order_date,
        d.year,
        d.quarter,
        d.month_name,
        d.month_number,
        d.day_of_week,
        d.is_working_day,
        d.is_weekend,

        -- Customer
        c.customer_key,
        c.full_name             AS customer_name,
        c.gender,
        c.age,
        c.city                  AS customer_city,
        c.state_name            AS customer_state,
        c.country_name          AS customer_country,
        c.continent,
        c.occupation,
        c.customer_segment,
        c.lifetime_net_revenue  AS customer_lifetime_value,

        -- Product
        p.product_key,
        p.product_name,
        p.brand,
        p.category_name,
        p.subcategory_name,
        p.manufacturer,
        p.color,
        p.margin_pct            AS product_margin_pct,

        -- Store
        s.store_key,
        s.store_code,
        s.country_name          AS store_country,
        s.state                 AS store_state,
        s.status                AS store_status,
        s.is_active             AS store_is_active,
        s.square_meters         AS store_size_sqm,

        -- Measures
        f.quantity,
        f.unit_price,
        f.net_price,
        f.unit_cost,
        f.gross_revenue,
        f.net_revenue,
        f.total_cost,
        f.profit,
        f.profit_margin_pct,
        f.discount_amount,
        f.discount_pct,

        f.loaded_at

    FROM fact_sales f
    LEFT JOIN dim_date      d ON f.date_key     = d.date_key
    LEFT JOIN dim_customers c ON f.customer_key = c.customer_key
    LEFT JOIN dim_products  p ON f.product_key  = p.product_key
    LEFT JOIN dim_stores    s ON f.store_key    = s.store_key
)

SELECT * FROM final
