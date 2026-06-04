WITH source AS (

    SELECT
        raw_data,
        source_file,
        loaded_at
    FROM {{ source('raw', 'VISBY_RAINFALL_JSON_RAW') }}

),

flattened AS (

    SELECT
        raw_data:station.key::string AS station_id,
        raw_data:station.name::string AS station_name,
        raw_data:parameter.name::string AS parameter,
        raw_data:parameter.unit::string AS unit,
        TO_TIMESTAMP_NTZ(value_item.value:date::number / 1000) AS observation_time,
        value_item.value:value::float AS precipitation_mm,
        value_item.value:quality::string AS quality,
        source_file,
        loaded_at
    FROM source,
    LATERAL FLATTEN(input => raw_data:value) AS value_item
    WHERE raw_data:station.key::string = '78400'

),

deduplicated AS (

    SELECT *
    FROM flattened
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY station_id, observation_time
        ORDER BY loaded_at DESC, source_file DESC
    ) = 1

)

SELECT *
FROM deduplicated