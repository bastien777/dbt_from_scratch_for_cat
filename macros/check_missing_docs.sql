{% macro check_missing_docs() %}
    {% set models = graph.nodes.values() | selectattr("resource_type", "equalto", "model") %}

    {% for model in models %}
        {% for column in model.columns.values() %}
            {% if not column.description %}
                {{ log("⚠️  Missing description: " ~ model.name ~ "." ~ column.name, info=true) }}
            {% endif %}
        {% endfor %}
    {% endfor %}
{% endmacro %}


-- dbt run-operation check_missing_docs to run this macro.