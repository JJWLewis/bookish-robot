with source as (
    select * from {{ ref('customer_acquisition') }}
),

-- Assume some beautiful, clean data out of Hubspot or similar... sure
renamed as (
    select
        customer_id,
        acquisition_date,
        acquisition_channel,
        acquisition_source,
        acquisition_campaign,
        acquisition_device,
        acquisition_country,
        acquisition_city,
        acquisition_region,
        acquisition_platform,
        acquisition_medium,
        acquisition_term,
        acquisition_content,
        acquisition_cost
    from source
)

select * from renamed
