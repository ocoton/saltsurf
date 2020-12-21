require 'open-uri'

class GetTideApiService

  def initialize(spot)
    @spot = spot
  end

  def call
    lat = @spot.latitude;
    lng =  @spot.longitude;
    start_time = Time.now.utc.strftime("%Y-%m-%d")
    end_time = (Time.now.utc.beginning_of_day + 7.days).strftime("%Y-%m-%d")
    # params = 'waveHeight,swellDirection,swellHeight,swellPeriod,waveDirection,waveHeight,wavePeriod,windDirection,windSpeed';
    response = HTTParty.get("https://api.stormglass.io/v2/tide/extremes/point?lat=#{lat}&lng=#{lng}&start=#{start_time}&end=#{end_time}",
      headers: {
        'Authorization': "#{ENV['STORM_GLASS']}"
      }
    )
    rawresponse = JSON.parse(response.body)

    if rawresponse['data']
      rawresponse['data'].each do |data|
        tide = Tide.new
        tide.timestamp = DateTime.parse(data['time'])
        tide.height = data['height']
        tide.status = data['type']
        tide.spot_id = @spot.id
        tide.save
      end
    end
    return
  end
end
