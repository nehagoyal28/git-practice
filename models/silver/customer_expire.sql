{{ config(
    materialized='incremental',
    unique_key='customer_id',
    schema='silver',
    post_hook="

MERGE INTO ecommerce_catalog.silver.customer_silver t

USING (

SELECT

s.customer_id

FROM ecommerce_catalog.silver.customer_stage s

JOIN ecommerce_catalog.silver.customer_silver c

ON s.customer_id=c.customer_id

WHERE c.is_current=true

AND (

coalesce(s.first_name,'')<>coalesce(c.first_name,'')

OR coalesce(s.last_name,'')<>coalesce(c.last_name,'')

OR coalesce(s.customer_name,'')<>coalesce(c.customer_name,'')

OR coalesce(s.email,'')<>coalesce(c.email,'')

OR coalesce(s.phone,'')<>coalesce(c.phone,'')

OR coalesce(s.account_name,'')<>coalesce(c.account_name,'')

OR coalesce(s.mailing_street,'')<>coalesce(c.mailing_street,'')

OR coalesce(s.mailing_city,'')<>coalesce(c.mailing_city,'')

OR coalesce(s.mailing_state,'')<>coalesce(c.mailing_state,'')

OR coalesce(s.mailing_country,'')<>coalesce(c.mailing_country,'')

OR coalesce(s.customer_status,'')<>coalesce(c.customer_status,'')

OR coalesce(s.loyalty_points,-1)<>coalesce(c.loyalty_points,-1)

OR coalesce(s.last_activity_date,timestamp('1900-01-01'))

<>

coalesce(c.last_activity_date,timestamp('1900-01-01'))

)

) src

ON t.customer_id=src.customer_id

AND t.is_current=true

WHEN MATCHED THEN

UPDATE SET

t.effective_end_date=current_timestamp(),

t.is_current=false

"
) }}

SELECT
customer_id

FROM {{ ref('customer_stage') }}

LIMIT 0