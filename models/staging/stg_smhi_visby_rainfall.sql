WITH source AS (

    SELECT
        raw_data,
        source_file,
        loaded_at
    FROM {{ source('raw', 'VISBY_RAINFALL_JSON_RAW') }}

),

parsed AS (

    SELECT
        raw_data:station.key::string AS station_id,
        raw_data:station.name::string AS station_name,
        raw_data:parameter.name::string AS parameter,
        raw_data:parameter.unit::string AS unit,
        TO_TIMESTAMP_NTZ(raw_data:value[0].date::number / 1000) AS observation_time,
        raw_data:value[0].value::float AS precipitation_mm,
        raw_data:value[0].quality::string AS quality,
        source_file,
        loaded_at
    FROM source
    WHERE raw_data:station.key::string = '78400'

)

SELECT *
FROM parsed