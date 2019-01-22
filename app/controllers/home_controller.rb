require './lib/helpers/yelp_fusion.rb'
require './lib/helpers/google_maps.rb'
require 'google_maps_service'
require 'haversine'
require 'date'

class HomeController < ApplicationController
  # before_action :check_login, only: [:search]

  DEFAULT_RADIUS = 5000
  DEFAULT_RECENT = 5
  def index
  end

  def search
    # Redirect to home if parameters are empty
    # if params[:location].blank?
    #   flash[:error] = "Location is invalid"
    #   redirect_to action: 'search', location: 'Pittsburgh', delivery: params[:delivery], dining: params[:dining]
    # end

    @location = params[:location]
    # params[:delivery], params[:dining]

    # Fetching search result
    @YelpClient = Yelp::Fusion::Client.new()
    @GoogleClient = GoogleMaps::Geocoding::Client.new()
    locationResult = @GoogleClient.geocode(@location)
    latAndLong = locationResult[0][:geometry][:location]
    @lat = latAndLong[:lat]
    @lng = latAndLong[:lng]
    result = @YelpClient.search(@lat, @lng)
    @businesses = result["businesses"]
    @total = result["total"]
    @region = result["region"]

    # Calculating recommendations
    if @businesses.nil?
      flash[:error] = "Location is invalid"
      redirect_back(fallback_location: home_path)
    else
      rating = @businesses[0] # best rating
      @recommendations = [rating,favorite,recent]
    end
  end

  private
    def filterOrdersFav()
      # TEMPORARY TESTING
      @jun = User.find(1)
      orders = @jun.orders.to_a
      orders.map! {|order| @YelpClient.business(order.restaurant.business_id)}

      filtered = orders.select do |order|
        order_lat = order["coordinates"]["latitude"]
        order_lng = order["coordinates"]["longitude"]
        distance = Haversine.distance(order_lat,order_lng, @lat, @lng)
        distance.to_meters < DEFAULT_RADIUS
      end
      return filtered
    end

    def largest_hash_key(hash)
      hash.max_by{|k,v| v}[0]
    end

    def favorite
      orders = filterOrdersFav()
      #find which restaurant current user has ordered from the most
      counter = {}
      for order in orders
        if counter[order] == nil then
          counter[order] = 1
        else
          counter[order] += 1
        end
      end
      return largest_hash_key(counter)
    end

    def filterOrdersRecent()
      @jun = User.find(1)
      orders = @jun.orders.to_a
      orders.select do |order|
        (DateTime.now.to_date-order.date.to_date).to_i < DEFAULT_RECENT
      end
      orders.map! {|order| @YelpClient.business(order.restaurant.business_id)}

      filtered = orders.select do |order|
        order_lat = order["coordinates"]["latitude"]
        order_lng = order["coordinates"]["longitude"]
        distance = Haversine.distance(order_lat,order_lng, @lat, @lng)
        distance.to_meters < DEFAULT_RADIUS
      end
      return filtered
    end

    def recent
      orders = filterOrdersRecent()
      business_ids = orders.map! {|order| order["alias"]}
      result = @YelpClient.search(@lat,@lng,orders.length+1)
      businesses = result["businesses"]
      businesses.delete_if {|item| business_ids.include?(item["alias"])}
      return businesses[0]
    end
end
