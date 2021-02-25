with

source as (

  select * from {{ source("new_york_taxi_trips", "tlc_yellow_trips_2015") }}

),

renamed as (

  select
    pickup_datetime,
    pickup_longitude,
    pickup_latitude,
    dropoff_datetime,
    dropoff_longitude,
    dropoff_latitude,
    passenger_count,
    trip_distance,
    fare_amount,
    extra as extra_amount,
    mta_tax as mta_tax_amount,
    tip_amount,
    tolls_amount,
    imp_surcharge as imp_surcharge_amount,
    total_amount

  from source

)

select * from renamed
