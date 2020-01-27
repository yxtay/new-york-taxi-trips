with

source AS (

  SELECT * FROM {{ source("new_york_taxi_trips", "tlc_yellow_trips_2015") }}

),

selected AS (

  SELECT
    pickup_datetime,
    pickup_longitude,
    pickup_latitude,
    dropoff_datetime,
    dropoff_longitude,
    dropoff_latitude,
    passenger_count,
    trip_distance,
    fare_amount,
    extra AS extra_amount,
    mta_tax AS mta_tax_amount,
    tip_amount,
    tolls_amount,
    imp_surcharge AS imp_surcharge_amount,
    total_amount

  FROM source

)

SELECT * FROM selected
