{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key='id'
        , file_format='delta'
        , partition_by='created'
        , tags=['daily', 'payments']
    )
}}


select
    id
    , orderid
    , paymentmethod
    , status
    , amount
    , created
from {{ source('raw_data', 'bl_stripe_payments') }}
where 1 = 1
    {% if is_incremental() %}
        and created >= '{{ get_max_date('created') }}'::date - {{ var('lookback_days') }}
        and created <= '{{ get_max_date('created') }}'::date + {{ var("lookup_days") }}
    {% else %}
        and created >= '{{ var("start_date") }}'
        and created <= '{{ var("start_date") }}'::date + {{ var("lookup_days") }}
    {% endif %}