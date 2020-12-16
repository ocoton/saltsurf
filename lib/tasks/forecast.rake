namespace :forecast do
  desc "updating forecast data"
  task update: :environment do
    puts "updating task"
    Spot.all.each do |spot|
      GetStormglassApiService.new(spot).call
      GetTideApiService.new(spot).call
    end
    puts "done"
  end

end
