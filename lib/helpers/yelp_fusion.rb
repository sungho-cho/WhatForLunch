require "json"
require "http"
require "optparse"
require "pg"

# Place holders for Yelp Fusion's API key. Grab it
# from https://www.yelp.com/developers/v3/manage_app

# Constants, do not change these
API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path


DEFAULT_BUSINESS_ID = "yelp-san-francisco"
DEFAULT_TERM = "dinner"
DEFAULT_LOCATION = "San Francisco, CA"
DEFAULT_RADIUS = 5000
SEARCH_LIMIT = 5

module Yelp
  module Fusion
    class Client
      def initialize
        @http = HTTP.auth("Bearer #{Rails.application.secrets.yelp_fusion_key}")
      end


      # Make a request to the Fusion search endpoint. Full documentation is online at:
      # https://www.yelp.com/developers/documentation/v3/business_search
      #
      # term - search term used to find businesses
      # location - what geographic location the search should happen
      #
      # Returns a parsed json object of the request
      def search(lat, lng, lim=SEARCH_LIMIT)
        url = "#{API_HOST}#{SEARCH_PATH}"
        params = {
          latitude: lat,
          longitude: lng,
          radius: DEFAULT_RADIUS,
          sort_by: "best_match",
          limit: lim
        }

        response = @http.get(url, params: params)
        response.parse
      end


      # Look up a business by a given business id. Full documentation is online at:
      # https://www.yelp.com/developers/documentation/v3/business
      #
      # business_id - a string business id
      #
      # Returns a parsed json object of the request
      def business(business_id)
        url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}"

        response = @http.get(url)
        response.parse
      end


      # options = {}
      # OptionParser.new do |opts|
      #   opts.banner = "Example usage: ruby sample.rb (search|lookup) [options]"
      #
      #   opts.on("-tTERM", "--term=TERM", "Search term (for search)") do |term|
      #     options[:term] = term
      #   end
      #
      #   opts.on("-lLOCATION", "--location=LOCATION", "Search location (for search)") do |location|
      #     options[:location] = location
      #   end
      #
      #   opts.on("-bBUSINESS_ID", "--business-id=BUSINESS_ID", "Business id (for lookup)") do |id|
      #     options[:business_id] = id
      #   end
      #
      #   opts.on("-h", "--help", "Prints this help") do
      #     puts opts
      #     exit
      #   end
      # end.parse!
      #
      #
      # command = ARGV
      #
      #
      # case command.first
      # when "search"
      #   term = options.fetch(:term, DEFAULT_TERM)
      #   location = options.fetch(:location, DEFAULT_LOCATION)
      #
      #   raise "business_id is not a valid parameter for searching" if options.key?(:business_id)
      #
      #   response = search(term, location)
      #
      #   puts "Found #{response["total"]} businesses. Listing #{SEARCH_LIMIT}:"
      #   response["businesses"].each {|biz| puts biz["name"]}
      # when "lookup"
      #   business_id = options.fetch(:business_id, DEFAULT_BUSINESS_ID)
      #
      #
      #   raise "term is not a valid parameter for lookup" if options.key?(:term)
      #   raise "location is not a valid parameter for lookup" if options.key?(:lookup)
      #
      #   response = business(business_id)
      #
      #   puts "Found business with id #{business_id}:"
      #   puts JSON.pretty_generate(response)
      # else
      #   puts "Please specify a command: search or lookup"
      # end
    end
  end
end
