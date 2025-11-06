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
    {{ get_incremental_filter(date_column='order_date', operator='where') }}
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