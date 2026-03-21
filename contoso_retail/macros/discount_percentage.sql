{% macro calc_discount_percentage(gross, net) %}
    CASE
        WHEN {{ gross }} > 0
        THEN ROUND((({{ gross }} - {{ net }}) / {{ gross }}) * 100, 2)
        ELSE 0
    END
{% endmacro %}


{% macro calc_discount_amount(gross, net) %}
    ROUND({{ gross }} - {{ net }}, 2)
{% endmacro %}