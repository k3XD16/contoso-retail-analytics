WITH customers AS (
    SELECT * FROM {{ ref('stg_customer') }}
),

customer_metrics AS (
    SELECT * FROM {{ ref('int_customer_metrics') }}
),

final AS (
    SELECT

        c.customer_key,
        c.geo_area_key,

        c.start_dt,
        c.end_dt,

        c.full_name,
        c.first_name,
        c.last_name,
        c.title,
        c.middle_initial,
        c.gender,
        c.birth_date,
        c.age,

        c.continent,
        c.country_code,
        c.country_name,
        c.state_code,
        c.state_name,
        c.city,
        c.zip_code,
        c.street_address,
        c.latitude,
        c.longitude,

        c.occupation,
        c.company,
        c.vehicle,

        COALESCE(m.total_orders, 0)             AS total_orders,
        COALESCE(m.total_items_purchased, 0)    AS total_items_purchased,
        COALESCE(m.total_gross_revenue, 0)      AS lifetime_gross_revenue,
        COALESCE(m.total_net_revenue, 0)        AS lifetime_net_revenue,
        COALESCE(m.total_profit, 0)             AS lifetime_profit,
        COALESCE(m.avg_profit_margin_pct, 0)    AS avg_profit_margin_pct,
        m.first_order_date,
        m.last_order_date,
        m.days_since_last_order,

        {{ calc_customer_segment ('COALESCE(m.total_net_revenue, 0)') }} AS customer_segment,

        CURRENT_TIMESTAMP() AS loaded_at

    FROM customers c
    LEFT JOIN customer_metrics m ON c.customer_key = m.customer_key
)

SELECT * FROM final
