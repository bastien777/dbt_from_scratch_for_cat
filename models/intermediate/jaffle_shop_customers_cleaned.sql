{{
    config(
        materialized='incremental'
        , incremental_strategy='merge'
        , unique_key='id'
        , file_format='delta'
        , partition_by='id'
        , tags=['dim', 'customers']
    )
}}


select *
from {{ source('raw_data', 'bl_jaffle_shop_customers') }}
