view: products {
  sql_table_name: products ;;
  
  dimension: product_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.product_id ;;
  }
  
  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }
  
  dimension: product_category {
    type: string
    sql: ${TABLE}.product_category ;;
  }
  
  dimension: product_type {
    type: string
    sql: ${TABLE}.product_type ;;
  }
  
  dimension: is_prescription_required {
    type: yesno
    sql: ${TABLE}.is_prescription_required ;;
  }
  
  dimension: requires_doctor_approval {
    type: yesno
    sql: ${TABLE}.requires_doctor_approval ;;
  }
  
  dimension: product_description {
    type: string
    sql: ${TABLE}.product_description ;;
  }
  
  measure: monthly_price {
    type: average
    sql: ${TABLE}.monthly_price ;;
    value_format_name: usd_2
  }
  
  measure: annual_price {
    type: average
    sql: ${TABLE}.annual_price ;;
    value_format_name: usd_2
  }
  
  measure: count {
    type: count
    drill_fields: [product_id, product_name, product_category, product_type]
  }
} 