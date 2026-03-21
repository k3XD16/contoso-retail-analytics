{% macro calc_profit_margin(profit,revenue) %}
    CASE
        WHEN {{ revenue }} > 0
        THEN ROUND(({{profit}} / {{revenue}}) * 100, 2)
        ELSE 0
    END
{% endmacro %}