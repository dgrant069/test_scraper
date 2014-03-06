# ruby hostelworld_scraper.rb "http://www.hostelworld.com/hostels"
require "nokogiri"
require "pry"
require "mechanize"

url = ARGV[0]
fp = File.new("hostelworld_scraper.txt", "w")
counties_fp = File.new("hostelworld_countries.txt", "w")
states_fp = File.new("hostelworld_states.txt", "w")
cities_fp = File.new("hostelworld_cities.txt", "w")
hostels_fp = File.new("hostelworld_hostels.txt", "w")
hostel_info_fp = File.new("hostel_info.txt", "w")
agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
html = agent.get(url).body
html_doc = Nokogiri::HTML(html)

# countries = {}
# states = {}
# cities = {}
# hostels = {}
# hostel_info = {}


countries_XML = agent.page.search(".topratedlist a")
countries_name = countries_XML.map(&:text).map(&:strip)
countries_urls = countries_XML.map{ |a| a['href'] }.compact.uniq
countries = Hash[countries_name.zip countries_urls]

  counties_fp.write("Countries\n\n")
  countries.each do |country, url|
    counties_fp.write(country + ", " + url + "\n")

    # agent.page.link_with(:text => "#{countries}").click
    # country.gsub!(" ", "-")
    # hrefs = country.map{ |a|
    #   a['href'] if a['href'].match("/hostelworld/")
    # }.compact.uniq
  end

agent.page.link_with(:text => "USA").click
  states_XML = agent.page.search("#states a")
  states_name = states_XML.map(&:text).map(&:strip)
  states_urls = states_XML.map{ |a| a['href'] }.compact.uniq
  states = Hash[states_name.zip states_urls]

  states_fp.write("\nStates\n\n")
  states_fp.write(states_name)


agent.page.link_with(:text => "Washington").click
  cities_XML = agent.page.search("#bottomlist a")
  cities_name = cities_XML.map(&:text).map(&:strip)
  cities_urls = cities_XML.map{ |a| a['href'] }.compact.uniq
  cities = Hash[cities_name.zip cities_urls]

  cities_fp.write("\nCities\n\n")
  cities_fp.write(cities_name)


agent.page.link_with(:text => "Seattle").click
  hostels_XML = agent.page.search("h2 .gotoMicrosite")
  hostels_name = hostels_XML.map(&:text).map(&:strip)
  hostels_urls = hostels_XML.map{ |a| a['href'] }.compact.uniq
  hostels_address_XML = agent.page.search(".fabdetailsaddress")
  hostels_address = hostels_address_XML.map(&:text).map(&:strip)
  # hostels_dorm_prices_XML = agent.page.search("li .fabprice")
  # hostels_dorm_prices = hostels_dorm_prices_XML.map(&:text).map(&:strip)
  hostels_privates_prices_XML = agent.page.search(".fabpricespacer~ li .fabprice")
  hostels_privates_prices = hostels_privates_prices_XML.map(&:text).map(&:strip)
  hostels = Hash[hostels_name.zip hostels_urls]

  hostels_fp.write("\nHostels\n\n")
  hostels_fp.write(hostels_name)


#
agent.page.link_with(:text => "HotelHotel Hostel").click
  hostel_amenities_XML = agent.page.search(".facilitylist li")
  hostel_amenities = hostel_amenities_XML.map(&:text).map(&:strip)
  room_types = []
  room_prices = []

  form = agent.page.form_with(:action => "http://www.hostelworld.com/hosteldetails.php/HotelHotel-Hostel/Seattle/53155#availability")
  form.date_from = "14 May 2014"
  form.date_to = "15 May 2014"
  form.submit

  hostel_info_fp.write("HotelHotel Hostel\n\n")
  # Write Amenities
  hostel_amenities.each do |amenity|
    hostel_info_fp.write(amenity + ", ")
  end

  # Room types
  hostel_room_types_XML = agent.page.search(".roomtype td").map(&:children)
  hostel_room_types_XML.map!(&:children)
  hostel_room_types_XML.each do |room|
    room_type = room[0].to_s
    room_type.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
    room_types.push(room_type)
  end

  # Prices
  room_prices_XML = agent.page.search(".availability td:nth-child(2) .currency").map(&:text).map(&:strip)
  room_prices_XML.each do |price|
    room_price = price.gsub("US$", "").to_f
    room_prices.push(room_price)
  end

  # If the room has a price show them, if not just print the rooms
  hostel_info_fp.write("\nRooms and Prices\n\n")
  if room_types.length == room_prices.length
    room_info = Hash[room_types.zip room_prices]
    room_info.each do |type, price|
      hostel_info_fp.write("#{type} $#{price}," + "\n")
    end
  else room_types.each { |room| hostel_info_fp.write(room + "\n") }
  end

# countries_urls.each do |url|
#   agent.click(url)
#   if agent.page.search("#states a") == true
#     states = agent.page.search("#states a")
#     fp.write(states.text)
#   else
#     cities = agent.page.search("#bottomlist a")
#     fp.write(cities.text)
#   end
# end

# countries_urls.each do |city|
#   if agent.page.search("#states a")
#     fp.write(states.text)
#   end
#   fp.write(city + "\n")
# end
#   agent.page.link_with(:text => country).each do |link|
#     link.click
#     fp.write("Cities\n\n")
#     cities = agent.page.search("#bottomlist a").map(&:text).map(&:strip)
#     cities.each { |city| fp.write(city.text + "\n") }
#   end
# end

# fp.write("Cities\n\n")
# cities = agent.page.search("#bottomlist a")
# cities.each { |i| fp.write(i.text + "\n") }
