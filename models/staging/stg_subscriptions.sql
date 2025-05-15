{% set partitions_to_replace = [
  'current_date()',
  'date_sub(current_date(), interval 1 day)'
] %}

{{
    config(
        materialized='incremental',
        partition_by={
            "field": "subscription_start_date",
            "data_type": "timestamp",
            "granularity": "day"
        },
        incremental_strategy='insert_overwrite',
        unique_key=['subscription_id'],
        cluster_by=['customer_id', 'subscription_status'],
        partitions = partitions_to_replace
    )
}}

-- Some sample incremental logic which obviously makes no sense for seeds...
with source_subscriptions as (
    select * from {{ ref('subscriptions') }}
    {% if is_incremental() %}
        where subscription_start_date in ({{ partitions_to_replace | join(',') }})
    {% endif %}
),

subscriptions as (
    select
        subscription_id,
        customer_id,
        product_id,
        subscription_start_date,
        subscription_end_date,
        subscription_status,
        payment_frequency,
        auto_renew,
        last_payment_date,
        next_payment_date,
        doctor_approval_date,
        prescription_id,
        subscription_notes,
        -- Add any additional metadata
        current_timestamp() as _meta_updated_at,
    from source_subscriptions
)

select * from subscriptions 