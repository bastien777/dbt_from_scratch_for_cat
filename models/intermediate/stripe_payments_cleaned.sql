{{
    config(
        materialized='incremental'
        , incremental_strategy='insert_overwrite'
        , unique_key='id'
        , file_format='delta'
        , partition_by='created'
    )
}}


select *
from {{ source('raw_data', 'bl_stripe_payments') }}

{{ get_incremental_filter(date_column='created', operator='where') }}