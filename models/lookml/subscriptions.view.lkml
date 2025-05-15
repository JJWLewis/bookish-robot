view: subscriptions {
  sql_table_name: stg_subscriptions ;;
  
  dimension: subscription_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.subscription_id ;;
  }
  
  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
  }
  
  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }
  
  dimension: subscription_start_date {
    type: time
    sql: ${TABLE}.subscription_start_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: subscription_end_date {
    type: time
    sql: ${TABLE}.subscription_end_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: subscription_status {
    type: string
    sql: ${TABLE}.subscription_status ;;
  }
  
  dimension: payment_frequency {
    type: string
    sql: ${TABLE}.payment_frequency ;;
  }
  
  dimension: auto_renew {
    type: yesno
    sql: ${TABLE}.auto_renew ;;
  }
  
  dimension: last_payment_date {
    type: time
    sql: ${TABLE}.last_payment_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: next_payment_date {
    type: time
    sql: ${TABLE}.next_payment_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: doctor_approval_date {
    type: time
    sql: ${TABLE}.doctor_approval_date ;;
    timeframes: [raw, date, month, quarter, year]
  }
  
  dimension: prescription_id {
    type: string
    sql: ${TABLE}.prescription_id ;;
  }
  
  dimension: subscription_notes {
    type: string
    sql: ${TABLE}.subscription_notes ;;
  }
  
  dimension: subscription_age_days {
    type: number
    sql: ${TABLE}.subscription_age_days ;;
  }
  
  dimension: subscription_duration_days {
    type: number
    sql: ${TABLE}.subscription_duration_days ;;
  }
  
  dimension: days_until_next_payment {
    type: number
    sql: ${TABLE}.days_until_next_payment ;;
  }
  
  dimension: is_active {
    type: yesno
    sql: ${TABLE}.is_active ;;
  }
  
  dimension: is_cancelled {
    type: yesno
    sql: ${TABLE}.is_cancelled ;;
  }
  
  dimension: is_expired {
    type: yesno
    sql: ${TABLE}.is_expired ;;
  }
  
  dimension: payment_status {
    type: string
    sql: ${TABLE}.payment_status ;;
  }
  
  dimension: subscription_health {
    type: string
    sql: ${TABLE}.subscription_health ;;
  }
  
  measure: count {
    type: count
    drill_fields: [subscription_id, customer_id, product_id, subscription_status]
  }
  
  measure: active_subscriptions {
    type: count
    filters: {
      field: is_active
      value: "yes"
    }
  }
  
  measure: cancelled_subscriptions {
    type: count
    filters: {
      field: is_cancelled
      value: "yes"
    }
  }
  
  measure: expired_subscriptions {
    type: count
    filters: {
      field: is_expired
      value: "yes"
    }
  }
  
  measure: auto_renew_rate {
    type: average
    sql: ${TABLE}.auto_renew ;;
    value_format_name: percent_2
  }
  
  measure: healthy_subscription_rate {
    type: average
    sql: CASE WHEN ${subscription_health} = 'healthy' THEN 1 ELSE 0 END ;;
    value_format_name: percent_2
  }
  
  measure: at_risk_subscription_rate {
    type: average
    sql: CASE WHEN ${subscription_health} = 'at_risk' THEN 1 ELSE 0 END ;;
    value_format_name: percent_2
  }
  
  measure: churned_subscription_rate {
    type: average
    sql: CASE WHEN ${subscription_health} = 'churned' THEN 1 ELSE 0 END ;;
    value_format_name: percent_2
  }
  
  measure: payment_due_rate {
    type: average
    sql: CASE WHEN ${payment_status} = 'payment_due' THEN 1 ELSE 0 END ;;
    value_format_name: percent_2
  }
  
  measure: up_to_date_payment_rate {
    type: average
    sql: CASE WHEN ${payment_status} = 'up_to_date' THEN 1 ELSE 0 END ;;
    value_format_name: percent_2
  }
  
  measure: average_subscription_duration {
    type: average
    sql: ${subscription_duration_days} ;;
    value_format_name: decimal_1
  }
  
  measure: median_subscription_duration {
    type: median
    sql: ${subscription_duration_days} ;;
    value_format_name: decimal_1
  }
  
  measure: average_days_until_payment {
    type: average
    sql: ${days_until_next_payment} ;;
    value_format_name: decimal_1
  }
} 