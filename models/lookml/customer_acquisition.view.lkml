view: customer_acquisition{
  sql_table_name: fct_customer_acquisition ;;
  
  # Define datagroup for caching
  # Change the config on reporting requirements and dbt run frequency
  # Add PDT if/when appropriate for additional 'cache' layer
  datagroup: customer_acquisition_metrics {
    sql_trigger: SELECT MAX(updated_at) FROM `{{project_id}}.{{dataset_id}}.fct_customer_acquisition` ;;
    max_cache_age: "1 hour"
  }
  
  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  
  dimension: acquisition_date {
    type: time
    sql: ${TABLE}.acquisition_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: acquisition_channel {
    type: string
    sql: ${TABLE}.acquisition_channel ;;
  }
  
  dimension: acquisition_country {
    type: string
    sql: ${TABLE}.acquisition_country ;;
  }
  
  dimension: acquisition_device {
    type: string
    sql: ${TABLE}.acquisition_device ;;
  }
  
  dimension: acquisition_campaign {
    type: string
    sql: ${TABLE}.acquisition_campaign ;;
  }
  
  dimension: first_order {
    type: time
    sql: ${TABLE}.first_order ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: most_recent_order {
    type: time
    sql: ${TABLE}.most_recent_order ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: number_of_orders {
    type: number
    sql: ${TABLE}.number_of_orders ;;
  }
  
  dimension: total_subscriptions {
    type: number
    sql: ${TABLE}.total_subscriptions ;;
  }
  
  dimension: active_subscriptions {
    type: number
    sql: ${TABLE}.active_subscriptions ;;
  }
  
  dimension: current_payment_frequency {
    type: string
    sql: ${TABLE}.current_payment_frequency ;;
  }
  
  dimension: days_since_acquisition {
    type: number
    sql: ${TABLE}.days_since_acquisition ;;
  }
  
  dimension: days_to_first_order {
    type: number
    sql: ${TABLE}.days_to_first_order ;;
  }
  
  dimension: has_active_subscription {
    type: yesno
    sql: ${TABLE}.has_active_subscription ;;
  }
  
  dimension: has_placed_order {
    type: yesno
    sql: ${TABLE}.has_placed_order ;;
  }
  
  measure: count {
    type: count
    drill_fields: [customer_id, acquisition_date, acquisition_channel, acquisition_country]
  }
  
  measure: customer_lifetime_value {
    type: sum
    sql: ${TABLE}.customer_lifetime_value ;;
    value_format_name: usd_2
  }
  
  measure: avg_customer_lifetime_value {
    type: average
    sql: ${TABLE}.customer_lifetime_value ;;
    value_format_name: usd_2
  }
  
  measure: avg_days_to_first_order {
    type: average
    sql: ${TABLE}.days_to_first_order ;;
    value_format_name: decimal_1
  }
  
  measure: conversion_rate {
    type: number
    sql: SAFE_DIVIDE(${has_placed_order}, ${count}) ;;
    value_format_name: percent_2
  }
  
  measure: subscription_adoption_rate {
    type: number
    sql: SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
  }
  
  measure: avg_orders_per_customer {
    type: average
    sql: ${TABLE}.number_of_orders ;;
    value_format_name: decimal_1
  }
  
  measure: avg_subscriptions_per_customer {
    type: average
    sql: ${TABLE}.total_subscriptions ;;
    value_format_name: decimal_1
  }
  
  # Additional retention metrics
  measure: retention_rate_30d {
    type: number
    sql: SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
    filters: [days_since_acquisition: "<= 30"]
  }
  
  measure: retention_rate_90d {
    type: number
    sql: SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
    filters: [days_since_acquisition: "<= 90"]
  }
  
  measure: retention_rate_180d {
    type: number
    sql: SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
    filters: [days_since_acquisition: "<= 180"]
  }
  
  measure: churn_rate_30d {
    type: number
    sql: 1 - SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
    filters: [days_since_acquisition: "<= 30"]
  }
  
  measure: churn_rate_90d {
    type: number
    sql: 1 - SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
    filters: [days_since_acquisition: "<= 90"]
  }
  
  measure: churn_rate_180d {
    type: number
    sql: 1 - SAFE_DIVIDE(${has_active_subscription}, ${count}) ;;
    value_format_name: percent_2
    filters: [days_since_acquisition: "<= 180"]
  }
  
  measure: repeat_purchase_rate {
    type: number
    sql: SAFE_DIVIDE(${number_of_orders}, ${count}) ;;
    value_format_name: decimal_1
  }
  
  measure: subscription_renewal_rate {
    type: number
    sql: SAFE_DIVIDE(${active_subscriptions}, ${total_subscriptions}) ;;
    value_format_name: percent_2
  }
  
  measure: avg_subscription_duration {
    type: average
    sql: ${days_since_acquisition} ;;
    value_format_name: decimal_1
    filters: [has_active_subscription: "yes"]
  }
} 