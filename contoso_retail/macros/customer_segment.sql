{% macro calc_customer_segment(revenue) %}
    CASE
        WHEN {{ revenue }} >= 10000 THEN 'VIP'
        WHEN {{ revenue }} >= 5000 THEN 'High Value'
        WHEN {{ revenue }} >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END
{% endmacro %}