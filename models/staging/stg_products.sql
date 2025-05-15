with source_products as (
    select
        product_id,
        product_name,
        product_category,
        product_type,
        product_description,
        is_prescription_required,
        requires_doctor_approval,
        monthly_price,
        annual_price,
        created_at,
        updated_at
    from {{ ref('products') }}
),

-- Some example cleaning.
-- Gnerally would cast, rename, and add metadata in this layer
-- Importantly, any names chosen here will be used in the final model and thus
-- should be in data dictionaries/meta data management to avoid 3 people 
-- defining what "join date" is etc.
cleaned_products as (
    select
        -- Primary key
        product_id,
        -- Product details
        trim(product_name) as product_name,
        trim(product_category) as product_category,
        trim(product_type) as product_type,
        trim(product_description) as product_description,
        -- Healthcare specific attributes
        coalesce(is_prescription_required, false) as is_prescription_required,
        coalesce(requires_doctor_approval, false) as requires_doctor_approval,
        -- Pricing
        cast(monthly_price as decimal(10, 2)) as monthly_price,
        cast(annual_price as decimal(10, 2)) as annual_price,
        -- Metadata
        created_at,
        updated_at,
        -- ETL Metadata
        current_timestamp() as dbt_updated_at
    from source_products
)

select * from cleaned_products 