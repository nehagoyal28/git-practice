{{ config(
    materialized='incremental',
    schema='silver',
    unique_key='customer_id',
    incremental_strategy='append',
    on_schema_change='sync_all_columns'
) }}

WITH source_data AS (

    SELECT *
    FROM {{ ref('customer_stage') }}

),

current_records AS (

{% if is_incremental() %}

SELECT *
FROM {{ this }}
WHERE is_current = true

{% else %}

SELECT *
FROM source_data
WHERE 1=0

{% endif %}

),

new_or_changed AS (

SELECT

    s.*

FROM source_data s

LEFT JOIN current_records c

ON s.customer_id = c.customer_id

WHERE

      c.customer_id IS NULL

   OR coalesce(s.first_name,'') <> coalesce(c.first_name,'')

   OR coalesce(s.last_name,'') <> coalesce(c.last_name,'')

   OR coalesce(s.customer_name,'') <> coalesce(c.customer_name,'')

   OR coalesce(s.email,'') <> coalesce(c.email,'')

   OR coalesce(s.phone,'') <> coalesce(c.phone,'')

   OR coalesce(s.account_name,'') <> coalesce(c.account_name,'')

   OR coalesce(s.mailing_street,'') <> coalesce(c.mailing_street,'')

   OR coalesce(s.mailing_city,'') <> coalesce(c.mailing_city,'')

   OR coalesce(s.mailing_state,'') <> coalesce(c.mailing_state,'')

   OR coalesce(s.mailing_country,'') <> coalesce(c.mailing_country,'')

   OR coalesce(s.customer_status,'') <> coalesce(c.customer_status,'')

   OR coalesce(s.loyalty_points,-1) <> coalesce(c.loyalty_points,-1)

   OR coalesce(s.last_activity_date,timestamp('1900-01-01'))
      <>
      coalesce(c.last_activity_date,timestamp('1900-01-01'))

)

SELECT

    customer_id,
    first_name,
    last_name,
    customer_name,
    email,
    phone,
    account_name,
    mailing_street,
    mailing_city,
    mailing_state,
    mailing_country,
    customer_status,
    loyalty_points,
    created_date,
    last_activity_date,

    current_timestamp() AS effective_start_date,

    timestamp('9999-12-31 23:59:59') AS effective_end_date,

    true AS is_current

FROM new_or_changed