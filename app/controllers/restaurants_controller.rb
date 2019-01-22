class RestaurantsController < ApplicationController
  def create
    @restaurant = Restaurant.new(restaurant_params)
  end

  private
    def restaurant_params
      params.require(:restaurant).permit(:business_id)
    end
end
