class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in? && current_user.favorites.present?
      @top_spots = current_user.spots if current_user.spots
    else
      @top_spots = []
      all = []
      Spot.all.each do |spot|
        all << spot.forecast_today
      end
      top_forecasts = all.sort_by(&:rating).reverse.take(4)

      top_forecasts.each do |f|
        @top_spots << f.spot
      end
    end
  end
end
