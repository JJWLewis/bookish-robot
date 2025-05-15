{{
    config(
        materialized='table',
        unique_key=['customer_id'],
        cluster_by=['customer_segment', 'customer_status']
    )
}}

with source_customers as (
    select * from {{ ref('stg_customers') }}
),

customer_metrics as (
    select
        customer_id,
        first_order,
        most_recent_order,
        number_of_orders,
        customer_lifetime_value,
        -- Calculate additional customer attributes/metrics
        date_diff(
            current_date(),
            date(first_order),
            day
        ) as customer_age_days,
        date_diff(
            date(most_recent_order),
            date(first_order),
            day
        ) as customer_tenure_days,
        case
            when number_of_orders > 10 then 'high_value'
            when number_of_orders > 5 then 'medium_value'
            else 'low_value'
        end as customer_segment,
        case
            when date_diff(
                current_date(),
                date(most_recent_order),
                day
            ) <= 30 then 'active'
            when date_diff(
                current_date(),
                date(most_recent_order),
                day
            ) >= 90 then 'at_risk'
            else 'inactive'
        end as customer_status,
        -- ETL Metadata
        current_timestamp() as dbt_updated_at
    from source_customers
)

select * from customer_metrics 