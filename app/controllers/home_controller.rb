require './lib/helpers/yelp_fusion.rb'
require './lib/helpers/google_maps.rb'
require 'google_maps_service'
require 'haversine'
require 'date'

class HomeController < ApplicationController
  before_action :check_login, only: [:search]

  DEFAULT_RADIUS = 5000
  DEFAULT_RECENT = 5
  def index
    # Geocoder.configure(lookup: :test, ip_lookup: request.ip)
    # puts request.ip
    # puts request.remote_ip
    # if Rails.env.production?
    #   request.remote_ip
    # else
    #   puts Net::HTTP.get(URI.parse('http://checkip.amazonaws.com/')).squish
    # end
  end

  def search
    # Redirect to home if parameters are empty
    if params[:location].blank?
      flash[:error] = "Location is blank"
      redirect_back(fallback_location: home_path)
    else
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
        @rating = @businesses[0] # best rating
        @jun = User.find(1)
        orders = @jun.orders.to_a
        restaurants = orders.map {|order| order.restaurant}
        business_ids = restaurants.map {|restaurant| restaurant.business_id}

        @favorite = favorite(orders,business_ids)
        @recent = recent(orders,business_ids)
        @recommendations = [@rating,@favorite,@recent]
        @recommendations = toMi()
      end
    end
  end

  private
    def filterOrdersFav(orders,business_ids)
      # TEMPORARY TESTING
      orders = business_ids.map {|business_id| @YelpClient.business(business_id)}
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

    def favorite(orders,business_ids)
      orders = filterOrdersFav(orders,business_ids)
      orders.delete_if {|item| item["alias"] == @rating["alias"]}
      #find which restaurant current user has ordered from the most
      counter = {}
      for order in orders
        if counter[order] == nil then
          counter[order] = 1
        else
          counter[order] += 1
        end
      end
      fav = largest_hash_key(counter)

      order_lat = fav["coordinates"]["latitude"]
      order_lng = fav["coordinates"]["longitude"]
      dist = Haversine.distance(order_lat,order_lng,@lat,@lng)
      fav["distance"] = dist.to_meters
      return fav
    end

    def filterOrdersRecent(orders,business_ids)
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

    def recent(orders,business_ids)
      orders = filterOrdersRecent(orders,business_ids)
      business_ids = orders.map! {|order| order["alias"]}
      business_ids.push(@rating["alias"])
      business_ids.push(@favorite["alias"])
      result = @YelpClient.search(@lat,@lng)
      businesses = result["businesses"]
      businesses.delete_if {|item| business_ids.include?(item["alias"])}
      return businesses[0]
    end

    def toMi
      @recommendations.each {|item|
          item["distance"] = item["distance"]/1609.344
      }
      return @recommendations
    end
end
