## ZIPCODE TO COUNTY mapping
## Every zipcode maps to exactly one county, based on the population of the zipcode.

view: zipcode_county {
  derived_table: {
    persist_for: "10000 hours"
    sql: SELECT zcta5, state, geoid as county_code  FROM
      (select *,  ROW_NUMBER() OVER (PARTITION BY zcta5 ORDER BY ZPOPPCT DESC) row_num
      from `lookerdata.weather.zcta_county_map`)
      where row_num = 1;;
  }

  dimension: zipcode {
    primary_key: yes
    hidden: yes
    sql: CAST(${TABLE}.ZCTA5 as STRING);;
    type: zipcode
  }

  dimension: state_code {
    group_label: "State"
    hidden: yes
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: county_code {
    group_label: "County"
    type: string
    sql: ${TABLE}.county_code;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [zipcode, state_code, county_code]
  }
}
