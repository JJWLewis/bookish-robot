{{
    config(
        materialized='table',
        partition_by={
            'field': 'cohort_month',
            'data_type': 'date',
            'granularity': 'month'
        },
        cluster_by=['acquisition_channel', 'acquisition_country']
    )
}}

with customer_base as (
    select
        c.customer_id,
        c.first_order as first_activity_date,
        c.most_recent_order as last_activity_date,
        ua.user_type,
        ua.subscription_tier,
        ua.account_status,
        ua.preferred_language,
        ua.timezone,
        ua.is_verified,
        ua.has_completed_onboarding,
        ua.preferred_payment_method,
        ua.marketing_opt_in,
        date_trunc('month', c.first_order) as cohort_month,
        date_trunc('month', current_date) as current_month,
        date_diff('day', c.first_order, current_date) as days_since_first_activity,
        date_diff('day', c.most_recent_order, current_date) as days_since_last_activity
    from {{ ref('customers') }} as c
    left join {{ ref('stg_user_attributes') }} as ua
        on c.customer_id = ua.customer_id
),

subscription_metrics as (
    select
        customer_id,
        count(distinct subscription_id) as total_subscriptions,
        count(distinct case 
            when subscription_status = 'active' 
            then subscription_id 
        end) as active_subscriptions,
        max(case 
            when subscription_status = 'active' 
            then payment_frequency 
        end) as current_payment_frequency,
        max(case 
            when subscription_status = 'active' 
            then auto_renew 
        end) as has_auto_renew
    from {{ ref('stg_subscriptions') }}
    group by 1
),

product_metrics as (
    select
        s.customer_id,
        max(p.product_category) as primary_product_category,
        max(p.product_type) as primary_product_type,
        max(p.is_prescription_required) as has_prescription_required,
        max(p.requires_doctor_approval) as requires_doctor_approval
    from {{ ref('stg_subscriptions') }} as s
    left join {{ ref('stg_products') }} as p
        on s.product_id = p.product_id
    where s.subscription_status = 'active'
    group by 1
),

customer_activity as (
    select
        cb.*,
        sm.total_subscriptions,
        sm.active_subscriptions,
        sm.current_payment_frequency,
        sm.has_auto_renew,
        pm.primary_product_category,
        pm.primary_product_type,
        pm.has_prescription_required,
        pm.requires_doctor_approval,
        acq.acquisition_date,
        acq.acquisition_channel,
        acq.acquisition_country,
        acq.acquisition_device,
        acq.acquisition_campaign
    from customer_base as cb
    left join subscription_metrics as sm
        on cb.customer_id = sm.customer_id
    left join product_metrics as pm
        on cb.customer_id = pm.customer_id
    left join {{ ref('stg_customer_acquisition') }} as acq
        on cb.customer_id = acq.customer_id
),

monthly_activity as (
    select
        customer_id,
        cohort_month,
        acquisition_channel,
        acquisition_country,
        acquisition_device,
        acquisition_campaign,
        user_type,
        subscription_tier,
        account_status,
        preferred_language,
        timezone,
        is_verified,
        has_completed_onboarding,
        preferred_payment_method,
        marketing_opt_in,
        primary_product_category,
        primary_product_type,
        has_prescription_required,
        requires_doctor_approval,
        current_payment_frequency,
        has_auto_renew,
        total_subscriptions,
        active_subscriptions,
        days_since_first_activity,
        days_since_last_activity,
        date_trunc('month', first_activity_date) as activity_month,
        coalesce(days_since_last_activity <= 30, false) as is_active_30d,
        coalesce(days_since_last_activity <= 90, false) as is_active_90d,
        coalesce(days_since_last_activity <= 180, false) as is_active_180d
    from customer_activity
),

cohort_metrics as (
    select
        cohort_month,
        acquisition_channel,
        acquisition_country,
        acquisition_device,
        acquisition_campaign,
        user_type,
        subscription_tier,
        account_status,
        preferred_language,
        timezone,
        is_verified,
        has_completed_onboarding,
        preferred_payment_method,
        marketing_opt_in,
        primary_product_category,
        primary_product_type,
        has_prescription_required,
        requires_doctor_approval,
        current_payment_frequency,
        has_auto_renew,
        count(distinct customer_id) as total_customers,
        sum(case when is_active_30d then 1 else 0 end) as active_customers_30d,
        sum(case when is_active_90d then 1 else 0 end) as active_customers_90d,
        sum(case when is_active_180d then 1 else 0 end) as active_customers_180d,
        avg(total_subscriptions) as avg_subscriptions_per_customer,
        avg(active_subscriptions) as avg_active_subscriptions_per_customer,
        avg(days_since_first_activity) as avg_customer_lifetime_days,
        avg(days_since_last_activity) as avg_days_since_last_activity,
        sum(case when is_active_30d then 1 else 0 end) * 100.0 
            / nullif(count(distinct customer_id), 0) as retention_rate_30d,
        sum(case when is_active_90d then 1 else 0 end) * 100.0 
            / nullif(count(distinct customer_id), 0) as retention_rate_90d,
        sum(case when is_active_180d then 1 else 0 end) * 100.0 
            / nullif(count(distinct customer_id), 0) as retention_rate_180d
    from monthly_activity
    group by 
        cohort_month,
        acquisition_channel,
        acquisition_country,
        acquisition_device,
        acquisition_campaign,
        user_type,
        subscription_tier,
        account_status,
        preferred_language,
        timezone,
        is_verified,
        has_completed_onboarding,
        preferred_payment_method,
        marketing_opt_in,
        primary_product_category,
        primary_product_type,
        has_prescription_required,
        requires_doctor_approval,
        current_payment_frequency,
        has_auto_renew
)

select
    cohort_month,
    acquisition_channel,
    acquisition_country,
    acquisition_device,
    acquisition_campaign,
    user_type,
    subscription_tier,
    account_status,
    preferred_language,
    timezone,
    is_verified,
    has_completed_onboarding,
    preferred_payment_method,
    marketing_opt_in,
    primary_product_category,
    primary_product_type,
    has_prescription_required,
    requires_doctor_approval,
    current_payment_frequency,
    has_auto_renew,
    total_customers,
    active_customers_30d,
    active_customers_90d,
    active_customers_180d,
    avg_subscriptions_per_customer,
    avg_active_subscriptions_per_customer,
    avg_customer_lifetime_days,
    avg_days_since_last_activity,
    retention_rate_30d,
    retention_rate_90d,
    retention_rate_180d,
    date_diff('month', cohort_month, current_month) as months_since_cohort
from cohort_metrics
order by 
    cohort_month desc,
    acquisition_channel asc,
    acquisition_country asc 