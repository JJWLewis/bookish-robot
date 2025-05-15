explore: retention_explore {
  label: "Customer Retention Analysis"
  description: "Analyze customer retention patterns across different dimensions including products, subscriptions, and user attributes"
  
  from: customer_retention
  
  join: customers {
    relationship: many_to_one
    sql_on: ${customer_retention.customer_id} = ${customers.customer_id} ;;
  }
  
  join: subscriptions {
    relationship: many_to_one
    sql_on: ${customer_retention.customer_id} = ${subscriptions.customer_id} ;;
  }
  
  join: products {
    relationship: many_to_one
    sql_on: ${subscriptions.product_id} = ${products.product_id} ;;
  }
  
  join: customer_acquisition {
    relationship: many_to_one
    sql_on: ${customer_retention.customer_id} = ${customer_acquisition.customer_id} ;;
  }
  
  join: user_attributes {
    relationship: many_to_one
    sql_on: ${customer_retention.customer_id} = ${user_attributes.customer_id} ;;
  }
  
  join: orders {
    relationship: one_to_many
    sql_on: ${customers.customer_id} = ${orders.customer_id} ;;
    fields: [
      orders.order_id,
      orders.order_date,
      orders.order_status,
      orders.order_total_amount,
      orders.order_type,
      orders.order_source,
      orders.order_platform
    ]
  }
  
  join: payments {
    relationship: one_to_many
    sql_on: ${subscriptions.subscription_id} = ${payments.subscription_id} ;;
    fields: [
      payments.payment_id,
      payments.payment_date,
      payments.payment_amount,
      payments.payment_status,
      payments.payment_method,
      payments.payment_processor
    ]
  }
  
  # Define default fields for the explore
  default_fields: [
    customer_retention.retention_month,
    customer_retention.retention_cohort,
    customer_retention.cohort_retention_rate,
    customer_retention.monthly_churn_rate,
    customer_retention.monthly_acquisition_rate,
    customer_retention.net_retention_rate,
    customer_acquisition.retention_rate_30d,
    customer_acquisition.retention_rate_90d,
    customer_acquisition.retention_rate_180d,
    customer_acquisition.churn_rate_30d,
    customer_acquisition.churn_rate_90d,
    customer_acquisition.churn_rate_180d,
    customer_acquisition.conversion_rate,
    customer_acquisition.subscription_adoption_rate,
    customer_acquisition.avg_customer_lifetime_value,
    customer_acquisition.acquisition_channel,
    customer_acquisition.acquisition_country,
    customer_acquisition.acquisition_device,
    products.product_category,
    user_attributes.user_type,
    user_attributes.subscription_tier
  ]

# Lock it on the main fact to limit any fast dim weirdness
explore: explore_name {
  persist_with: customer_acquisition_metrics
}
  
  
  # Define optimized measures
  measure: monthly_order_count {
    type: count_distinct
    sql: ${orders.order_id} ;;
    filters: {
      field: orders.order_date
      value: "this month"
    }
    datagroup_trigger: retention_metrics
  }
  
  measure: monthly_total_spend {
    type: sum
    sql: ${orders.order_total_amount} ;;
    filters: {
      field: orders.order_date
      value: "this month"
    }
    value_format_name: usd_2
    datagroup_trigger: retention_metrics
  }
  
  measure: monthly_average_order_value {
    type: average
    sql: ${orders.order_total_amount} ;;
    filters: {
      field: orders.order_date
      value: "this month"
    }
    value_format_name: usd_2
    datagroup_trigger: retention_metrics
  }
  
  measure: cohort_retention_month_1 {
    type: number
    sql: ${orders.order_count} / NULLIF(${customer_retention.cohort_size}, 0) ;;
    filters: {
      field: orders.order_date
      value: ">= DATE_ADD(${customer_retention.retention_cohort}, INTERVAL 1 MONTH)"
    }
    value_format_name: percent_2
    datagroup_trigger: weekly_metrics
  }
  
  measure: cohort_retention_month_2 {
    type: number
    sql: ${orders.order_count} / NULLIF(${customer_retention.cohort_size}, 0) ;;
    filters: {
      field: orders.order_date
      value: ">= DATE_ADD(${customer_retention.retention_cohort}, INTERVAL 2 MONTH)"
    }
    value_format_name: percent_2
    datagroup_trigger: weekly_metrics
  }
  
  measure: cohort_retention_month_3 {
    type: number
    sql: ${orders.order_count} / NULLIF(${customer_retention.cohort_size}, 0) ;;
    filters: {
      field: orders.order_date
      value: ">= DATE_ADD(${customer_retention.retention_cohort}, INTERVAL 3 MONTH)"
    }
    value_format_name: percent_2
    datagroup_trigger: weekly_metrics
  }
  
  # Define time-based dimensions for retention analysis
  dimension: retention_month {
    type: time
    timeframes: [raw, date, month, quarter, year]
    datagroup_trigger: retention_metrics
    drill_fields: [
      customer_retention.retention_rate,
      customer_retention.active_customers,
      customer_retention.churned_customers,
      customer_retention.retention_cohort,
      customer_retention.cohort_retention_rate,
      customer_retention.monthly_churn_rate,
      customer_retention.monthly_acquisition_rate
    ]
  }
  
  dimension: retention_cohort {
    type: time
    timeframes: [raw, date, month, quarter, year]
    datagroup_trigger: weekly_metrics
    drill_fields: [
      customer_retention.retention_month,
      customer_retention.cohort_retention_rate,
      customer_retention.cohort_size,
      customer_retention.cohort_active_customers,
      customer_retention.cohort_churned_customers,
      customer_retention.cohort_lifetime_value
    ]
  }
  
  # Define cohort-based measures
  measure: cohort_retention_rate {
    type: number
    sql: ${cohort_active_customers} / NULLIF(${cohort_size}, 0) ;;
    value_format_name: percent_2
    datagroup_trigger: weekly_metrics
    drill_fields: [
      customer_retention.cohort_size,
      customer_retention.cohort_active_customers,
      customer_retention.cohort_churned_customers
    ]
  }
  
  measure: cohort_size {
    type: count_distinct
    sql: ${customer_id} ;;
    datagroup_trigger: weekly_metrics
    drill_fields: [
      customer_retention.customer_id,
      customer_retention.retention_cohort
    ]
  }
  
  measure: cohort_active_customers {
    type: count_distinct
    sql: ${customer_id} ;;
    filters: {
      field: subscription_status
      value: "active"
    }
    datagroup_trigger: daily_metrics
    drill_fields: [
      customer_retention.customer_id,
      customer_retention.retention_cohort
    ]
  }
  
  measure: cohort_churned_customers {
    type: count_distinct
    sql: ${customer_id} ;;
    filters: {
      field: subscription_status
      value: "cancelled"
    }
    datagroup_trigger: daily_metrics
    drill_fields: [
      customer_retention.customer_id,
      customer_retention.retention_cohort
    ]
  }
  
  measure: cohort_lifetime_value {
    type: sum
    sql: ${customers.customer_lifetime_value} ;;
    value_format_name: usd_2
    datagroup_trigger: weekly_metrics
    drill_fields: [
      customer_retention.customer_id,
      customer_retention.retention_cohort
    ]
  }
  
  # Define key metrics measures
  measure: monthly_churn_rate {
    type: number
    sql: ${churned_customers} / NULLIF(${active_customers}, 0) ;;
    value_format_name: percent_2
    datagroup_trigger: daily_metrics
    drill_fields: [
      customer_retention.churned_customers,
      customer_retention.active_customers,
      customer_retention.retention_month
    ]
  }
  
  measure: monthly_acquisition_rate {
    type: number
    sql: ${customer_acquisition.count} / NULLIF(${active_customers}, 0) ;;
    value_format_name: percent_2
    datagroup_trigger: daily_metrics
    drill_fields: [
      customer_acquisition.count,
      customer_retention.active_customers,
      customer_retention.retention_month
    ]
  }
  
  measure: net_retention_rate {
    type: number
    sql: (${active_customers} + ${customer_acquisition.count} - ${churned_customers}) / NULLIF(${active_customers}, 0) ;;
    value_format_name: percent_2
    datagroup_trigger: daily_metrics
    drill_fields: [
      customer_retention.active_customers,
      customer_acquisition.count,
      customer_retention.churned_customers,
      customer_retention.retention_month
    ]
  }
  
  # Define drill fields for product dimensions
  dimension: product_category {
    datagroup_trigger: retention_metrics
    drill_fields: [
      products.product_name,
      products.product_type,
      products.is_prescription_required,
      products.requires_doctor_approval,
      products.monthly_price,
      products.annual_price
    ]
  }
  
  dimension: product_type {
    datagroup_trigger: retention_metrics
    drill_fields: [
      products.product_category,
      products.is_prescription_required,
      products.requires_doctor_approval,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate
    ]
  }
  
  # Define drill fields for subscription dimensions
  dimension: subscription_status {
    datagroup_trigger: daily_metrics
    drill_fields: [
      subscriptions.payment_frequency,
      subscriptions.auto_renew,
      subscriptions.last_payment_date,
      subscriptions.next_payment_date,
      payments.payment_status,
      payments.payment_method
    ]
  }
  
  dimension: payment_frequency {
    datagroup_trigger: retention_metrics
    drill_fields: [
      subscriptions.subscription_status,
      subscriptions.auto_renew,
      subscriptions.subscription_duration_days,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate
    ]
  }
  
  # Define drill fields for user attributes
  dimension: user_type {
    datagroup_trigger: retention_metrics
    drill_fields: [
      user_attributes.subscription_tier,
      user_attributes.account_status,
      user_attributes.has_completed_onboarding,
      user_attributes.preferred_payment_method,
      user_attributes.marketing_opt_in
    ]
  }
  
  dimension: subscription_tier {
    datagroup_trigger: retention_metrics
    drill_fields: [
      user_attributes.user_type,
      user_attributes.account_status,
      user_attributes.has_completed_onboarding,
      user_attributes.preferred_payment_method,
      user_attributes.marketing_opt_in
    ]
  }
  
  # Define drill fields for acquisition dimensions
  dimension: acquisition_channel {
    datagroup_trigger: retention_metrics
    drill_fields: [
      customer_acquisition.acquisition_country,
      customer_acquisition.acquisition_device,
      customer_acquisition.acquisition_campaign,
      customer_acquisition.conversion_rate,
      customer_acquisition.subscription_adoption_rate,
      customer_acquisition.avg_days_to_first_order,
      customer_acquisition.avg_customer_lifetime_value
    ]
  }
  
  dimension: acquisition_source {
    datagroup_trigger: retention_metrics
    drill_fields: [
      customer_acquisition.acquisition_channel,
      customer_acquisition.acquisition_campaign,
      customer_acquisition.acquisition_platform,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate,
      customer_retention.monthly_acquisition_rate
    ]
  }
  
  # Define drill fields for payment dimensions
  dimension: payment_status {
    datagroup_trigger: daily_metrics
    drill_fields: [
      payments.payment_method,
      payments.payment_processor,
      payments.payment_amount,
      payments.payment_date
    ]
  }
  
  dimension: payment_method {
    datagroup_trigger: retention_metrics
    drill_fields: [
      payments.payment_status,
      payments.payment_processor,
      payments.payment_amount,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate
    ]
  }
  
  # Define drill fields for order dimensions
  dimension: order_status {
    datagroup_trigger: retention_metrics
    drill_fields: [
      orders.order_type,
      orders.order_source,
      orders.order_platform,
      orders.order_total_amount,
      orders.order_date
    ]
  }
  
  dimension: order_type {
    datagroup_trigger: retention_metrics
    drill_fields: [
      orders.order_status,
      orders.order_source,
      orders.order_platform,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate
    ]
  }
  
  # Define drill fields for geographic dimensions
  dimension: order_country {
    datagroup_trigger: retention_metrics
    drill_fields: [
      orders.order_region,
      orders.order_city,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate
    ]
  }
  
  dimension: order_region {
    datagroup_trigger: retention_metrics
    drill_fields: [
      orders.order_country,
      orders.order_city,
      customer_retention.retention_rate,
      customer_retention.cohort_retention_rate,
      customer_retention.active_customers,
      customer_retention.monthly_churn_rate
    ]
  }
  
  # Define drill fields for customer dimensions
  dimension: customer_id {
    drill_fields: [
      customers.first_name,
      customers.last_name,
      customers.email,
      customers.created_at,
      subscriptions.subscription_status,
      subscriptions.subscription_start_date,
      subscriptions.subscription_end_date,
      products.product_name,
      products.product_category,
      customer_acquisition.acquisition_channel,
      customer_acquisition.acquisition_country,
      user_attributes.user_type,
      user_attributes.subscription_tier,
      user_attributes.account_status
    ]
  }
  
  # Define drill fields for key dimensions
  dimension: cohort_month {
    drill_fields: [
      customer_retention.retention_rate_30d,
      customer_retention.retention_rate_90d,
      customer_retention.retention_rate_180d,
      customer_retention.active_customers_30d,
      customer_retention.active_customers_90d,
      customer_retention.active_customers_180d,
      customer_retention.total_customers,
      customer_retention.churn_rate_30d,
      customer_retention.churn_rate_90d,
      customer_retention.churn_rate_180d
    ]
  }
  
  dimension: acquisition_country {
    drill_fields: [
      customer_acquisition.acquisition_channel,
      customer_acquisition.acquisition_device,
      customer_acquisition.conversion_rate,
      customer_acquisition.subscription_adoption_rate,
      customer_acquisition.avg_customer_lifetime_value
    ]
  }
  
  dimension: primary_product_category {
    drill_fields: [
      customer_retention.retention_rate_30d,
      customer_retention.retention_rate_90d,
      customer_retention.retention_rate_180d,
      customer_retention.active_customers_30d,
      customer_retention.active_customers_90d,
      customer_retention.active_customers_180d,
      customer_retention.total_customers,
      customer_retention.churn_rate_30d,
      customer_retention.churn_rate_90d,
      customer_retention.churn_rate_180d
    ]
  }
  
  dimension: user_type {
    drill_fields: [
      customer_retention.retention_rate_30d,
      customer_retention.retention_rate_90d,
      customer_retention.retention_rate_180d,
      customer_retention.active_customers_30d,
      customer_retention.active_customers_90d,
      customer_retention.active_customers_180d,
      customer_retention.total_customers,
      customer_retention.churn_rate_30d,
      customer_retention.churn_rate_90d,
      customer_retention.churn_rate_180d
    ]
  }
  
  dimension: subscription_tier {
    drill_fields: [
      customer_retention.retention_rate_30d,
      customer_retention.retention_rate_90d,
      customer_retention.retention_rate_180d,
      customer_retention.active_customers_30d,
      customer_retention.active_customers_90d,
      customer_retention.active_customers_180d,
      customer_retention.total_customers,
      customer_retention.churn_rate_30d,
      customer_retention.churn_rate_90d,
      customer_retention.churn_rate_180d
    ]
  }
} 