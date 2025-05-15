with source as (
    select * from {{ ref('user_attributes') }}
),

renamed as (
    select
        customer_id,
        user_created_at,
        user_type,
        subscription_tier,
        account_status,
        last_login_date,
        preferred_language,
        timezone,
        is_verified,
        account_age_days,
        has_completed_onboarding,
        preferred_payment_method,
        marketing_opt_in,
        attribute_name,
        attribute_value,
        attribute_source,
        attribute_confidence,
        attribute_last_updated
    from source
)

select * from renamed 