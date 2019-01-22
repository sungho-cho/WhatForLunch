require 'google_maps_service'
require 'json'

# gmaps = GoogleMapsService::Client.new(key: API_KEY)
#
# results = gmaps.geocode('4500 Centre Avenue, Pittsburgh, PA')

module GoogleMaps
  module Geocoding
    class Client
      def initialize
        @gmaps = GoogleMapsService::Client.new(key: Rails.application.secrets.google_maps_key)
      end

      def geocode(location)
        @gmaps.geocode(location)
      end
    end
  end
end
