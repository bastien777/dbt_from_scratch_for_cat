

{% test equal_column_sum(model, column_name, compare_model, compare_column_name) %}

with source_sum as (
    select sum({{ column_name }}) as total
    from {{ model }}
),

compare_sum as (
    select sum({{ compare_column_name }}) as total
    from {{ compare_model }}
)

select
    source_sum.total as source_total,
    compare_sum.total as compare_total,
    abs(source_sum.total - compare_sum.total) as difference
from source_sum
cross join compare_sum
where source_sum.total != compare_sum.total

{% endtest %}