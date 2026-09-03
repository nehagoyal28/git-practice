{{ config(
    materialized='table',
    schema='gold'
) }}

SELECT

    customer_id,
    customer_name,
    customer_status,
    loyalty_points,

    CASE
        WHEN loyalty_points >= 5000 THEN 'Platinum'
        WHEN loyalty_points >= 3000 THEN 'Gold'
        WHEN loyalty_points >= 1000 THEN 'Silver'
        ELSE 'Bronze'
    END AS loyalty_tier,

    mailing_city,
    mailing_state,
    mailing_country,

    created_date,
    last_activity_date

FROM {{ ref('customer_silver') }}

WHERE is_current = true;