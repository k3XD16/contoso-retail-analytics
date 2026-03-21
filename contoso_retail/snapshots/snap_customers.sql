{% snapshot snap_customers %}

{{
    config(
        target_database = 'DEV_CONTOSO_RETAIL',
        target_schema   = 'SNAPSHOTS',
        unique_key      = 'customer_key',
        strategy        = 'check',
        check_cols      = [
            'city', 'state_name', 'country_name',
            'zip_code', 'street_address',
            'occupation', 'company', 'vehicle', 'age'
        ]
    )
}}

SELECT
    customer_key,
    full_name,
    first_name,
    last_name,
    gender,
    birth_date,
    age,
    occupation,
    company,
    vehicle,
    continent,
    country_code,
    country_name,
    state_code,
    state_name,
    city,
    zip_code,
    street_address,
    latitude,
    longitude,
    start_dt,
    end_dt

FROM {{ ref('stg_customer') }}

{% endsnapshot %}
