{% macro get_incremental_filter(date_column='created_at', lookback_days=None, operator='and') %}

    {% if is_incremental() %}

        {% set lookback = lookback_days or var('lookback_days', 3) %}

        -- Obtenir la date max existante
        {% set max_date_query %}
            select coalesce(max({{ date_column }}), '1900-01-01'::date) as max_date
            from {{ this }}
        {% endset %}

        {% set max_date_result = run_query(max_date_query) %}

        {% if execute %}
            {% set max_date = max_date_result.columns[0].values()[0] %}

                {{ operator }} {{ date_column }} >= dateadd(day, -{{ lookback }}, '{{ max_date }}'::date)
        {% endif %}

    {% endif %}

{% endmacro %}