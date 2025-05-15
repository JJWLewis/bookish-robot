{{
    config(
        materialized='table',
        unique_key=['subscription_id'],
        partition_by={
            "field": "subscription_start_date",
            "data_type": "timestamp",
            "granularity": "month"
        },
        cluster_by=['subscription_status', 'payment_frequency', 'auto_renew']
    )
}}

with source_subscriptions as (
    select * from {{ ref('stg_subscriptions') }}
),

final as (
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
        subscription_age_days,
        subscription_duration_days,
        days_until_next_payment,
        is_active,
        is_cancelled,
        is_expired,
        payment_status,
        subscription_health,
        date_diff(
            date(subscription_end_date),
            date(subscription_start_date),
            day
        ) as subscription_duration_days,
        date_diff(
            date(next_payment_date),
            current_date(),
            day
        ) as days_until_next_payment,
        -- Add status flags
        subscription_status = 'active' as is_active,
        subscription_status = 'cancelled' as is_cancelled,
        subscription_status = 'expired' as is_expired,
        -- Add payment status flags
        case
            when
                last_payment_date is not null
                and next_payment_date > current_timestamp()
                then 'up_to_date'
            when
                last_payment_date is not null
                and next_payment_date <= current_timestamp()
                then 'payment_due'
            when last_payment_date is null
                then 'no_payment_history'
            else 'unknown'
        end as payment_status,
        -- Add subscription health indicators
        case
            when subscription_status = 'active' and auto_renew = true
                then 'healthy'
            when subscription_status = 'active' and auto_renew = false
                then 'at_risk'
            when subscription_status = 'cancelled'
                then 'churned'
            when subscription_status = 'expired'
                then 'expired'
            else 'unknown'
        end as subscription_health,
        -- Add any additional subscription metadata
        current_timestamp() as dbt_updated_at
    from source_subscriptions
)

select * from final
