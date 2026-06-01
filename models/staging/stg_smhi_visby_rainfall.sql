with source as (

    select
        raw_data,
        source_file,
        loaded_at
    from {{ source('raw', 'RAW_SMHI_VISBY_RAINFALL') }}

),

flattened as (

    select
        raw_data:station:key::string as station_id,
        raw_data:station:name::string as station_name,
        raw_data:parameter:key::string as parameter_id,
        raw_data:parameter:name::string as parameter_name,
        raw_data:parameter:unit::string as unit,

        value_item.value:date::number as observation_timestamp_ms,
        to_timestamp_ntz(value_item.value:date::number / 1000) as observation_time,

        value_item.value:value::float as precipitation_mm,
        value_item.value:quality::string as quality,

        source_file,
        loaded_at

    from source,
    lateral flatten(input => raw_data:value) as value_item

)

select
    station_id,
    station_name,
    parameter_id,
    parameter_name,
    unit,
    observation_timestamp_ms,
    observation_time,
    precipitation_mm,
    quality,
    source_file,
    loaded_at
from flattened