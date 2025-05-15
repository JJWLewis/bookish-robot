view: customers {
  sql_table_name: customers ;;
  
  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
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
  
  measure: customer_lifetime_value {
    type: sum
    sql: ${TABLE}.customer_lifetime_value ;;
    value_format_name: usd_0
  }
  
  measure: count {
    type: count
    drill_fields: [customer_id, first_order, most_recent_order, number_of_orders, customer_lifetime_value]
  }
} 