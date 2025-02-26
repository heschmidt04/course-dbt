{{
    config(
        materialzed = 'view'
    )
}}

WITH orders_source AS (
    SELECT 
        order_id
        , user_id       -- user guid 
        , LOWER(
                regexp_replace(promo_id, '[- ]', '','g')
            )  AS promo_id    -- mostly nulls 
        , address_id    -- address guid
        , created_at
        , order_cost    -- without shipping
        , shipping_cost
        , order_total   -- cost and shipping
        , tracking_id   -- tracking guid 
        , shipping_service   
        , estimated_delivery_at
        , delivered_at
        , status        -- delivery status
    FROM
        {{
            source('greenery', 'orders')
        }}
)

, renamed_casted AS (
    SELECT
        order_id AS order_guid
        , user_id AS user_guid
        , address_id AS address_guid
        , order_cost
        , shipping_cost
        , order_total AS order_total_cost
        , status AS order_status
        , (CASE WHEN (promo_id::varchar) is NULL 
                THEN 'no_promotion' else promo_id END) AS promo_description
        , created_at AS created_at_utc
        , tracking_id AS tracking_guid
        , CASE WHEN shipping_service is NULL then 'empty' ELSE shipping_service END
        , estimated_delivery_at AS estimated_delivery_at_utc 
        , delivered_at AS delivered_at_utc
    FROM 
        orders_source  
)

SELECT 
        order_guid
        , user_guid
        , order_cost
        , shipping_cost
        , order_total_cost
        , order_status
        , promo_description
        , created_at_utc
        , tracking_guid
        , shipping_service
        , estimated_delivery_at_utc 
        , delivered_at_utc
FROM 
    renamed_casted
