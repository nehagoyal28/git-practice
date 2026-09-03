{{ config(
    materialized='view'
) }}

SELECT

    trim(Id) AS customer_id,

    trim(FirstName) AS first_name,

    trim(LastName) AS last_name,

    trim(Name) AS customer_name,

    lower(trim(Email)) AS email,

    cast(Phone AS STRING) AS phone,

    trim(AccountName) AS account_name,

    trim(MailingStreet) AS mailing_street,

    trim(MailingCity) AS mailing_city,

    trim(MailingState) AS mailing_state,

    trim(MailingCountry) AS mailing_country,

    trim(CustomerStatus) AS customer_status,

    cast(LoyaltyPoints AS INT) AS loyalty_points,

    to_timestamp(CreatedDate, 'M/d/yyyy H:mm') AS created_date,

    to_timestamp(LastActivityDate, 'M/d/yyyy H:mm') AS last_activity_date

FROM {{ source('bronze','customers_salesforce') }}

WHERE Id IS NOT NULL