{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key='id'
        , file_format='delta'
        , partition_by='order_date'
    )
}}


select *
from {{ source('raw_data', 'bl_jaffle_shop_orders') }}

{{ get_incremental_filter(date_column='order_date', operator='where') }}