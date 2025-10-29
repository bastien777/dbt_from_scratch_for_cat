{% macro create_schema(database_name=None, schema_name=None, relation=None) %}
    -- Do nothing: disable automatic schema creation
    -- We possibly never will have access to create different schemas I know its very sad.
{% endmacro %}