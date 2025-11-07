{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key='id'
        , file_format='delta'
        , partition_by='order_date'
        , tags=['daily', 'orders']
    )
}}


select *
from {{ source('raw_data', 'bl_jaffle_shop_orders') }}
where 1 = 1
    {% if is_incremental() %}
        and order_date >= '{{ get_max_date('order_date') }}'::date - {{ var('lookback_days') }}
        and order_date <= '{{ get_max_date('order_date') }}'::date + {{ var("lookup_days") }}
    {% else %}
        and order_date >= '{{ var("start_date") }}'
        and order_date <= '{{ var("start_date") }}'::date + {{ var("lookup_days") }}
    {% endif %}