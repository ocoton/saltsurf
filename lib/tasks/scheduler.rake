desc "This task is called by the Heroku scheduler add-on"
task :update_forecasts => :environment do
  puts "Updating forecasts..."
  Spot.all.each do |spot|
    GetStormglassApiService.new(spot).call
    GetTideApiService.new(spot).call
  end
  puts "done."
end
