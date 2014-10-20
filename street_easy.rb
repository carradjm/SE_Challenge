# I didn't feel the need to add any error rescuing. The way the script is
# set up, all of the logic is abstracted from the user, so as long as the user
# runs the script, there will be no errors.
# I also tried to keep the number of instance variables as low as possible.
# The use of Addressable::URI makes it easy to search for other types
# of listings / use other criteria if we ever wanted to change the script.

require 'rest_client'
require 'addressable/uri'
require 'json'

class StreetEasy

  def initialize(listing_type, area)
    @listing_type = listing_type
    @area = area
  end
  
  def build_output
    output = {@listing_type =>[]}
    
    listings = JSON.parse(self.get_api_data)
    
    # Goes through each listing returned from the API call, removes the information
    # we need, puts that info in a new hash, and then pushes that hash into our array.
    
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
    
    #RestClient makes it super easy to make API requests.
    RestClient.get url
  end
  
  def build_url
    # Can change any of these parameters very quickly; makes it easy to get different data
    
    # The defeault 'order' for an API search is 'price DESC' so I left that out of the 'query_values'.
    # Same with 'limit'.  It already defaults to the top 20.  If we wished to change these query values we could
    # easily add them in.
    
    @url = Addressable::URI.new(
      :scheme => "http",
      :host => "streeteasy.com",
      :path => "nyc/api/#{@listing_type}/search",
      :query_values => {
        :criteria => "area:#{@area}",
        :format => 'json'
        }
    ).to_s
  end
  
end

# Originally I had the user enter their API key here when the script ran.
# However, I realized that in order to get search API data from StreetEasy,
# you don't need an API key! So I removed that logic from the script.

sales = StreetEasy.new('sales', 'soho').build_output

rentals = StreetEasy.new('rentals', 'soho').build_output

# Will write the returned output from the api to a file named
# 'output.json' on the desktop

File.open("output.json","w") do |file|
  file.write(sales.merge!(rentals).to_json)
end