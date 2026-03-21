WITH products AS (
    SELECT * FROM {{ ref('stg_product') }}
),
final AS (
    SELECT
        product_key,
        product_code,
        product_name,
        manufacturer,
        brand,
        color,
        weight_unit,
        weight,
        cost,
        price,
        category_key,
        category_name,
        subcategory_key,
        subcategory_name,

        ROUND(price - cost,2) AS margin_amount,
        CASE
            WHEN price > 0
            THEN ROUND(((price - cost) / price) * 100, 2)
            ELSE 0
        END AS margin_pct,
        CURRENT_TIMESTAMP() as loaded_at
    
    FROM products
)
SELECT * FROM final