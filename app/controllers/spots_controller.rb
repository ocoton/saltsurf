class SpotsController < ApplicationController
  before_action :set_spot, only: [:show]
  skip_before_action(:authenticate_user!, only: [ :index, :show ])

  def index

    if params[:query].present?
      @spots = Spot.near(params[:query], params[:distance].presence || 100)
      @query_coordinates = Geocoder.search(params[:query]).first&.coordinates
    else
      @spots = Spot.geocoded
    end
    @spots = @spots.sort_by{ |spot| spot.forecast_today.rating }.reverse

    @markers = @spots.map do |spot|
      {
        lat: spot.latitude,
        lng: spot.longitude,
        name: spot.name,
        spotId: spot.id,
        infoWindow: render_to_string(partial: "info_window", locals: { spot: spot })
      }
    end
  end

  def show
    @array = []
    @array << @spot
    @markers = @array.map do |spot| {
      lat: spot.latitude,
      lng: spot.longitude,
      infoWindow: render_to_string(partial: "info_window", locals: { spot: spot })
    }
    end
    @tides = @spot.tides
    @today_low_tides = []
    @today_high_tides = []
    # extract todays data
    @tides.each do |tide|
      if tide.timestamp.day == Time.now.day && tide.status == "low"
        @today_low_tides << tide
      elsif tide.timestamp.day == Time.now.day && tide.status == "high"
        @today_high_tides << tide
      end

    end
  end

  private

  def set_spot
    @spot = Spot.find(params[:id])
  end

  def spot_params
    params.require(:spot).permit(:name, :description, :latitude, :longitude)
  end
end
