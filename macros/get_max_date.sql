{# What this macro lets us is to compute once per table the max date of the table for our incrementals. #}

{% macro get_max_date(date_column) %}

    {% if not max_date is defined %}

        {% set max_date_query %}

            select coalesce(max({{ date_column }}), "{{ var('start_date') }}"::date) as max_date
            from {{ this }}

        {% endset %}

        {% set max_date_result = run_query(max_date_query) %}

        {% set max_date = max_date_result.columns[0].values()[0] %}

    {% endif %}

    {{ return(max_date) }}

{% endmacro %}