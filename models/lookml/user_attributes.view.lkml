view: user_attributes {
  sql_table_name: user_attributes ;;
  
  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  
  dimension: user_created_at {
    type: time
    sql: ${TABLE}.user_created_at ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: user_type {
    type: string
    sql: ${TABLE}.user_type ;;
  }
  
  dimension: subscription_tier {
    type: string
    sql: ${TABLE}.subscription_tier ;;
  }
  
  dimension: account_status {
    type: string
    sql: ${TABLE}.account_status ;;
  }
  
  dimension: last_login_date {
    type: time
    sql: ${TABLE}.last_login_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: preferred_language {
    type: string
    sql: ${TABLE}.preferred_language ;;
  }
  
  dimension: timezone {
    type: string
    sql: ${TABLE}.timezone ;;
  }
  
  dimension: is_verified {
    type: yesno
    sql: ${TABLE}.is_verified ;;
  }
  
  dimension: account_age_days {
    type: number
    sql: ${TABLE}.account_age_days ;;
  }
  
  dimension: has_completed_onboarding {
    type: yesno
    sql: ${TABLE}.has_completed_onboarding ;;
  }
  
  dimension: preferred_payment_method {
    type: string
    sql: ${TABLE}.preferred_payment_method ;;
  }
  
  dimension: marketing_opt_in {
    type: yesno
    sql: ${TABLE}.marketing_opt_in ;;
  }
  
  measure: count {
    type: count
    drill_fields: [customer_id, user_type, subscription_tier, account_status]
  }
  
  measure: verification_rate {
    type: average
    sql: ${TABLE}.is_verified ;;
    value_format_name: percent_2
  }
  
  measure: onboarding_completion_rate {
    type: average
    sql: ${TABLE}.has_completed_onboarding ;;
    value_format_name: percent_2
  }
  
  measure: marketing_opt_in_rate {
    type: average
    sql: ${TABLE}.marketing_opt_in ;;
    value_format_name: percent_2
  }
} 