with

source AS (

  SELECT * FROM {{ ref("base_nytt__tlc_yellow_trips_2015") }}

),

filtered AS (

  SELECT *

  FROM source

  WHERE pickup_longitude > -75
    AND pickup_longitude < -73
    AND dropoff_longitude > -75
    AND dropoff_longitude < -73
    AND pickup_latitude > 40
    AND pickup_latitude < 42
    AND dropoff_latitude > 40
    AND dropoff_latitude < 42
    AND passenger_count > 0
    AND passenger_count <= 6
    AND trip_distance > 0
    AND fare_amount > 0
    AND fare_amount <= 600
    AND extra_amount >= 0
    AND mta_tax_amount >= 0
    AND tip_amount >= 0
    AND tip_amount <= 200
    AND tolls_amount >= 0
    AND imp_surcharge_amount >= 0
    AND total_amount > 0
    AND total_amount <= 800

)

SELECT * FROM filtered
