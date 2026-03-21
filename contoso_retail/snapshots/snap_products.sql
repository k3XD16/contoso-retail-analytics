{% snapshot snap_products %}

{{
    config(
        target_database = 'DEV_CONTOSO_RETAIL',
        target_schema   = 'SNAPSHOTS',
        unique_key      = 'product_key',
        strategy        = 'check',
        check_cols      = ['cost', 'price', 'color', 'weight']
    )
}}

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
    subcategory_name

FROM {{ ref('stg_product') }}

{% endsnapshot %}
