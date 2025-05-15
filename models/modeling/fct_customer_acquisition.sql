{{
    config(
        materialized='table',
        unique_key=['customer_id'],
        partition_by={
            "field": "acquisition_date",
            "data_type": "timestamp",
            "granularity": "month"
        },
        cluster_by=['acquisition_channel', 'acquisition_country']
    )
}}

with source_acquisition as (
    select * from {{ ref('stg_customer_acquisition') }}
),

customer_metrics as (
    select
        c.customer_id,
        c.first_order,
        c.most_recent_order,
        c.number_of_orders,
        c.customer_lifetime_value
    from {{ ref('stg_customers') }} as c
),

subscription_metrics as (
    select
        customer_id,
        count(distinct subscription_id) as total_subscriptions,
        count(distinct case
            when subscription_status = 'active'
                then subscription_id
        end) as active_subscriptions
    from {{ ref('stg_subscriptions') }}
    group by 1
),

final as (
    select
        -- Primary key
        a.customer_id,

        -- Acquisition details
        a.acquisition_date,
        a.acquisition_channel,
        a.acquisition_country,
        a.acquisition_device,
        a.acquisition_campaign,

        -- Customer metrics
        c.first_order,
        c.most_recent_order,
        c.number_of_orders,
        c.customer_lifetime_value,

        -- Subscription metrics
        s.total_subscriptions,
        s.active_subscriptions,
        s.current_payment_frequency,

        -- Derived metrics
        -- Interesting argument for whether to do all of this in Looker
        -- I would say not for simple, reusable metrics like these
        date_diff(
            current_date(),
            date(a.acquisition_date),
            day
        ) as days_since_acquisition,

        date_diff(
            date(c.first_order),
            date(a.acquisition_date),
            day
        ) as days_to_first_order,

        coalesce(s.active_subscriptions > 0, false) as has_active_subscription,

        coalesce(c.number_of_orders > 0, false) as has_placed_order,

        -- ETL Metadata
        current_timestamp() as dbt_updated_at
    from source_acquisition as a
    left join customer_metrics as c
        on a.customer_id = c.customer_id
    left join subscription_metrics as s
        on a.customer_id = s.customer_id
)

select * from final
