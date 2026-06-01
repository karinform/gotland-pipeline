with rainfall as (

    select
        station_id,
        station_name,
        observation_time,
        date_trunc('hour', observation_time) as observation_hour,
        precipitation_mm,
        quality,
        unit,
        source_file,
        loaded_at
    from {{ ref('stg_smhi_visby_rainfall') }}

),

deduplicated as (

    select *
    from rainfall
    qualify row_number() over (
        partition by station_id, observation_time
        order by loaded_at desc
    ) = 1

),

final as (

    select
        station_id,
        station_name,
        observation_time,
        observation_hour,
        precipitation_mm,

        case
            when precipitation_mm = 0 then 'No rain'
            when precipitation_mm > 0 and precipitation_mm < 1 then 'Light rain'
            when precipitation_mm >= 1 and precipitation_mm < 4 then 'Moderate rain'
            when precipitation_mm >= 4 then 'Heavy rain'
            else 'Unknown'
        end as rainfall_category,

        case
            when precipitation_mm >= 4 then true
            else false
        end as heavy_rain_flag,

        quality,
        unit,
        source_file,
        loaded_at

    from deduplicated

)

select *
from final