require 'open-uri'

class GetTideApiService

  def initialize(spot)
    @spot = spot
  end

  def call
    lat = @spot.latitude;
    lng =  @spot.longitude;
    end_time = Time.now.utc.beginning_of_day + 4.days ;
    # params = 'waveHeight,swellDirection,swellHeight,swellPeriod,waveDirection,waveHeight,wavePeriod,windDirection,windSpeed';
    response = HTTParty.get("https://api.stormglass.io/v2/tide/extremes/point?lat=#{lat}&lng=#{lng}&end=#{end_time}",
      headers: {
        'Authorization': "#{ENV['STORM_GLASS']}"
      }
    )
    rawresponse = JSON.parse(response.body)

    if rawresponse['data']
      rawresponse['data'].each do |data| 
        tide = Tide.new
        tide.timestamp = Time.new(data['time'])
        tide.height = data['height']
        tide.status = data['type']
        tide.spot_id = @spot.id
        tide.save
      end
    end
   
  end
end

