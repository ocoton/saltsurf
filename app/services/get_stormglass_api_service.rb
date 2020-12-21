require 'open-uri'

class GetStormglassApiService

  def initialize(spot)
    @spot = spot
  end

  def call
    lat = @spot.latitude;
    lng =  @spot.longitude;
    source = 'sg,meteo,noaa';
    end_time = Time.now.utc.beginning_of_day + 7.days;
    params = 'waveHeight,swellDirection,swellHeight,swellPeriod,waveDirection,waveHeight,wavePeriod,windDirection,windSpeed,airTemperature,seaLevel,waterTemperature';
    response = HTTParty.get("https://api.stormglass.io/v2/weather/point?lat=#{lat}&lng=#{lng}&params=#{params}&source=#{source}&end=#{end_time}",
      headers: {
        'Authorization': "#{ENV['STORM_GLASS']}"
      }
    )
    rawresponse = JSON.parse(response.body)
   #p rawresponse['meta']['requestCount'] # uncomment to display request count (max 50 /day)
    hours = rawresponse['hours']
    hours.each do |hour|
      rating_us = [hour["waveHeight"]["noaa"].to_f+hour["wavePeriod"]["noaa"].to_f/10,3].min
      Forecast.create!(
        spot: @spot,
        timestamp: hour["time"],
        wave_height: hour["waveHeight"]["noaa"],
        wind_direction: hour["windDirection"]["noaa"],
        wind_speed: hour["windSpeed"]["noaa"],
        swell_height: hour["swellHeight"]["noaa"],
        swell_direction: hour["swellDirection"]["noaa"],
        period: hour["wavePeriod"]["noaa"],
        rating: rating_us,
        source: "US NOAA",
        low_tide: DateTime.now + 6.25.hours,
        high_tide: DateTime.now,
        sea_level: hour["seaLevel"]["sg"],
        air_temperature: hour["airTemperature"]["sg"],
        water_temperature:hour["waterTemperature"]["sg"],
      )
      rating_mf = [hour["waveHeight"]["meteo"].to_f+hour["wavePeriod"]["meteo"].to_f/10,3].min
      Forecast.create!(
        spot: @spot,
        timestamp: hour["time"],
        wave_height: hour["waveHeight"]["meteo"] ,
        wind_direction: hour["windDirection"]["sg"],
        wind_speed: hour["windSpeed"]["sg"],
        swell_height: hour["swellHeight"]["meteo"],
        swell_direction: hour["swellDirection"]["meteo"],
        period: hour["wavePeriod"]["meteo"],
        rating: rating_mf,
        source: "Météo-France",
        low_tide: DateTime.now + 6.25.hours,
        high_tide: DateTime.now,
        sea_level: hour["seaLevel"]["sg"],
        air_temperature: hour["airTemperature"]["sg"],
        water_temperature:hour["waterTemperature"]["sg"],
      )
    end
  end
end
