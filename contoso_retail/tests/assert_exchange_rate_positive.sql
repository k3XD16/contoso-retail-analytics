-- Fail if exchange rate is zero or negative

SELECT
    exchange_date,
    from_currency,
    to_currency,
    exchange_rate
FROM {{ ref('stg_currencyexchange') }}
WHERE exchange_rate <= 0