WITH source AS (
    SELECT * FROM {{ source('bronze', 'BRONZE_PRODUCT') }}
),
renamed_and_cleaned AS (
    SELECT
        ProductKey AS product_key,
        TRIM(ProductCode) AS product_code,
        TRIM(ProductName) AS product_name,
        TRIM(Manufacturer) AS manufacturer,
        TRIM(Brand) AS brand,
        TRIM(Color) AS color,
        TRIM(WeightUnit) AS weight_unit,
        CAST(Weight AS DECIMAL(18,2)) AS weight,
        CAST(Cost AS DECIMAL(18,2)) AS cost,
        CAST(Price AS DECIMAL(18,2)) AS price,
        CategoryKey AS category_key,
        TRIM(CategoryName) AS category_name,
        SubCategoryKey AS subcategory_key,
        TRIM(SubCategoryName) AS subcategory_name,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS loaded_at
    FROM source
)

SELECT * FROM renamed_and_cleaned