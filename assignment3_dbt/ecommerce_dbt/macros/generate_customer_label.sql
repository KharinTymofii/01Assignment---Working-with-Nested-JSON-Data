{% macro generate_customer_label(status_column) %}
    case
        when {{ status_column }} = 'active' then 'engaged'
        when {{ status_column }} = 'inactive' then 'at_risk'
        when {{ status_column }} = 'blocked' then 'restricted'
        else 'unknown'
    end
{% endmacro %}
