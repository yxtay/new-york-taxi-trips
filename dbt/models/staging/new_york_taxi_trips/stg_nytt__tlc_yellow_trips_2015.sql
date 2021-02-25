with

source as (

  select * from {{ ref("base_nytt__tlc_yellow_trips_2015") }}

),

filtered as (

  select *

  from source

  where pickup_longitude > -75
    and pickup_longitude < -73
    and dropoff_longitude > -75
    and dropoff_longitude < -73
    and pickup_latitude > 40
    and pickup_latitude < 42
    and dropoff_latitude > 40
    and dropoff_latitude < 42
    and passenger_count > 0
    and passenger_count <= 6
    and trip_distance > 0
    and fare_amount > 0
    and fare_amount <= 600
    and extra_amount >= 0
    and mta_tax_amount >= 0
    and tip_amount >= 0
    and tip_amount <= 200
    and tolls_amount >= 0
    and imp_surcharge_amount >= 0
    and total_amount > 0
    and total_amount <= 800

)

select * from filtered
