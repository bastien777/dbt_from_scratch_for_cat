{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key=['order_id', 'user_id']
        , file_format='delta'
        , partition_by='order_date'
    )
}}

with shop_orders as (
    select *
    from {{ ref('jaffle_shop_orders_cleaned') }}
    {{ get_incremental_filter(date_column='order_date', operator='where') }}
)
, stripe_payments as (
    select *
    from {{ ref('stripe_payments_cleaned') }}
    {{ get_incremental_filter(date_column='created', operator='where') }}
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