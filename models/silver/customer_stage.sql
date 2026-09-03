{{ config(
    materialized='table',
    schema='silver'
) }}

WITH ranked_customers AS (

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

        ROW_NUMBER() OVER (

            PARTITION BY customer_id
            ORDER BY last_activity_date DESC,
                     created_date DESC

        ) AS rn

    FROM {{ ref('stg_customers') }}

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
    last_activity_date

FROM ranked_customers

WHERE rn = 1;