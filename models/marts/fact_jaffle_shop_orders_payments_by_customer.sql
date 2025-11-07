{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key=['order_id', 'user_id']
        , file_format='delta'
        , partition_by='order_date'
    )
}}

with shop_orders_payments as (
    select *
    from {{ ref('fact_jaffle_shop_orders') }}
    where 1 = 1
        {% if is_incremental() %}
            and order_date >= '{{ get_max_date('order_date') }}'::date - {{ var('lookback_days') }}
            and order_date <= '{{ get_max_date('order_date') }}'::date + {{ var("lookup_days") }}
        {% else %}
            and order_date >= '{{ var("start_date") }}'
            and order_date <= '{{ var("start_date") }}'::date + {{ var("lookup_days") }}
        {% endif %}
)
, customers as (
    select *
    from {{ ref('jaffle_shop_customers_cleaned') }}
)
select
    sop.order_id
    , sop.user_id
    , sop.order_date
    , sop.order_status
    , sop.payment_id
    , sop.payment_method
    , sop.payment_status
    , sop.payment_amount
    , sop.payment_date

    , cust.first_name
    , cust.last_name
from shop_orders_payments sop
left join customers cust
    on sop.user_id = cust.id