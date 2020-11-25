class SpotsController < ApplicationController
  before_action :set_spot, only: [:show]
  skip_before_action(:authenticate_user!, only: [ :index, :show ])

  def index
    @spots = Spot.all
    @markers = @spots.geocoded.map do |spot|
    {
      lat: spot.latitude,
      lng: spot.longitude
    }

    if params[:query].present?
      @spots = spots.near(params[:query],5)
    else
      @spots = Spot.all
    end
  end

  def show
  end

  private

  def set_spot
    @spot = Spot.find(params[:id])
  end
end
