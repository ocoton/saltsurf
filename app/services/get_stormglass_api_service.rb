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
    hours = rawresponse['hours']
    # Calculate shakas more effectively
    hours.each do |hour|
      wave_height_us = hour["waveHeight"]["noaa"].to_f
      wave_period_us = hour["wavePeriod"]["noaa"].to_f
      wind_speed_us = hour["windSpeed"]["noaa"].to_f
      rating_us = get_rating(wave_height_us, wave_period_us, wind_speed_us)

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

     # get rating for Meteo
      wave_height_mf = hour["waveHeight"]["meteo"].to_f
      wave_period_mf = hour["wavePeriod"]["meteo"].to_f
      wind_speed_mf = hour["windSpeed"]["meteo"].to_f

      rating_mf = get_rating(wave_height_mf, wave_period_mf, wind_speed_mf)

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

  private

  def get_rating(wave_height, wave_period, wind_speed)
    if wave_height <= 0.5
        wave_rating = 0
    elsif wave_height <= 1
        wave_rating = 1
    elsif wave_height <= 2
        wave_rating = 2
    elsif wave_height <= 3.5
        wave_rating = 3
    elsif wave_height > 3.5
        wave_rating = 1
    end


    if wave_period <= 5
        period_rating = -3
    elsif wave_period <= 7
        period_rating = -2
    elsif wave_period <= 8
        period_rating = -1
    else
        period_rating = 0
    end


    if wind_speed <= 12
        wind_rating = 0
    elsif wind_speed <= 15
        wind_rating = -1
    elsif wind_speed <= 20
        wind_rating = -2
    else
        wind_rating = -3
    end

    rating = wave_rating + period_rating + wind_rating
    if rating < 0 then rating = 0 end

    return rating
  end
end
