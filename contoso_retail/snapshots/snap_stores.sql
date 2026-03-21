{% snapshot snap_stores %}

{{
    config(
        target_database = 'DEV_CONTOSO_RETAIL',
        target_schema   = 'SNAPSHOTS',
        unique_key      = 'store_key',
        strategy        = 'check',
        check_cols      = ['status', 'square_meters', 'close_date']
    )
}}

SELECT
    store_key,
    store_code,
    country_code,
    country_name,
    state,
    open_date,
    close_date,
    description,
    square_meters,
    status

FROM {{ ref('stg_store') }}

{% endsnapshot %}
