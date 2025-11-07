{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key=['order_id', 'user_id']
        , file_format='delta'
        , partition_by='order_date'
        , tags=['daily', 'orders', 'r6m']
    )
}}

with shop_orders as (
    select
        *
    from {{ ref('jaffle_shop_orders_cleaned') }}
    where 1 = 1
        {% if is_incremental() %}
            and order_date >= '{{ get_max_date('order_date') }}'::date - {{ var('lookback_days') }}
            and order_date <= '{{ get_max_date('order_date') }}'::date + {{ var("lookup_days") }}
        {% else %}
            and order_date >= '{{ var("start_date") }}'
            and order_date <= '{{ var("start_date") }}'::date + {{ var("lookup_days") }}
        {% endif %}
)
, stripe_payments as (
    select
        *
    from {{ ref('stripe_payments_cleaned') }}
    where 1 = 1
        {% if is_incremental() %}
            and created >= '{{ get_max_date('order_date') }}'::date - {{ var('lookback_days') }}
            and created <= '{{ get_max_date('order_date') }}'::date + {{ var("lookup_days") }}
        {% else %}
            and created >= '{{ var("start_date") }}'
            and created <= '{{ var("start_date") }}'::date + {{ var("lookup_days") }}
        {% endif %}
)
select
    so.id as order_id
    , so.user_id
    , so.order_date
    , so.status as order_status

    , sp.id as payment_id
    , sp.paymentmethod as payment_method
    , sp.status as payment_status
    , sp.amount as payment_amount
    , sp.created as payment_date
from shop_orders so
left join stripe_payments sp
    on so.id = sp.orderid