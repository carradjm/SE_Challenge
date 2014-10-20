# I didn't feel the need to add any error rescuing.
# I also tried to keep the number of instance variables as low as possible.
# The use of Addressable::URI makes it easy to search for other types
#   of listings / use other criteria if we ever wanted to change the script.

require 'rest_client'
require 'addressable/uri'
require 'json'

class StreetEasy
  
  attr_reader :listing_type, :area, :api_key

  def initialize(listing_type, area, api_key)
    @listing_type = listing_type
    @area = area
    @api_key = api_key
  end
  
  def build_output
    output = {@listing_type =>[]}
    
    listings = JSON.parse(self.get_api_data)
    
    listings['listings'].each do |listing|
      output[@listing_type].push(
        {
          'listing_class' => @listing_type,
          'address' => listing['addr_street'],
          'unit' => listing['addr_unit'],
          'url' => listing['url'],
          'price' => listing['price']
        }
      )
    end
    output
  end
  
  def get_api_data
    url = self.build_url
    RestClient.get url
  end
  
  def build_url
    # Can change any of these parameters very quickly; makes it easy to get different data
    @url = Addressable::URI.new(
      :scheme => "http",
      :host => "streeteasy.com",
      :path => "nyc/api/#{@listing_type}/search",
      :query_values => {
        :criteria => "area:#{@area}",
        :key => @api_key,
        :format => 'json',
        }
    ).to_s
  end
  
end

puts "Please enter your API key for StreetEasy.com: "

api_key = gets.chomp.to_s

sales = StreetEasy.new('sales', 'soho', api_key).build_output

rentals = StreetEasy.new('rentals', 'soho', api_key).build_output

File.open("output.json","w") do |file|
  file.write(sales.merge!(rentals).to_json)
end