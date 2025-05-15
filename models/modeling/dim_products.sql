{{
    config(
        materialized='table',
        unique_key=['product_id'],
        cluster_by=['product_category', 'product_type']
    )
}}

with source_products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        product_id,
        product_name,
        product_category,
        product_type,
        is_prescription_required,
        requires_doctor_approval,
        product_description,
        monthly_price,
        annual_price,
        created_at,
        updated_at,
        -- Add any additional product metadata
        current_timestamp() as dbt_updated_at
    from source_products
)

select * from final 