desc "This task is called by the Heroku scheduler add-on"
task :update_forecasts => :environment do
  puts "Updating forecasts now..."
  Forecast.destroy_all
  puts "previous forecasts destroyed"
  Spot.all.each do |spot|
    begin
      GetStormglassApiService.new(spot).call
      puts "Successfully imported FORECAST data for #{spot.name}!"
    rescue GetStormglassApiService::ProcessingError
      puts "Error occured with getting the forecast api data for #{spot.name}..."
    end
  end
  puts "---------"
  puts "forecast API update is  done"
  puts "---------"
end

task :update_tides => :environment do
  puts "Updating tides now..."
  Tide.destroy_all
  puts "previous tides destroyed"
  Spot.all.each do |spot|
    begin
      GetTideApiService.new(spot).call
      puts "Successfully imported the TIDE data for #{spot.name}!"
    rescue GetTideApiService::ProcessingError
      puts "Error occured with getting the tide api data #{spot.name}..."
    end
  end
  puts "---------"
  puts "tide API update is  done"
  puts "---------"
end
