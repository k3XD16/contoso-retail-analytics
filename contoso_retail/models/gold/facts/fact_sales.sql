WITH order_details AS (
    SELECT * FROM {{ ref('int_order_details') }}
),

final AS (
    SELECT
        -- Keys
        order_key,
        line_number,
        date_key,
        customer_key,
        product_key,
        store_key,
        currency_code,

        -- Date attributes
        order_date,
        delivery_date,
        delivery_days,

        -- Measures
        quantity,
        unit_price,
        net_price,
        unit_cost,
        gross_revenue,
        net_revenue,
        total_cost,
        profit,
        profit_margin_pct,

        -- Discount
        {{ calc_discount_amount('gross_revenue', 'net_revenue') }} AS discount_amount,
        
        {{ calc_discount_percentage('gross_revenue','net_revenue') }} AS discount_pct,

        CURRENT_TIMESTAMP() AS loaded_at

    FROM order_details
)

SELECT * FROM final
