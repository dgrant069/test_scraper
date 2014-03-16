# ruby hostelworld_countries.rb
require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
countries_csv = File.new("hostelworld_countries.csv", "w")
countries_json = File.new("hostelworld_countries.txt", "w")

agent.get("http://www.hostelworld.com/hostels")
countries_XML = agent.page.search(".topratedlist a")
countries_name = countries_XML.map(&:text).map(&:strip)
countries_urls = countries_XML.map{ |a| a['href'] }.compact.uniq
countries = Hash[countries_name.zip countries_urls]
countries_json.write(countries)

countries.each do |country, url|
  countries_csv.write(country + "," + url + "\n")
end

# # INDIVIDUAL HOSTEL INFO
# hostel_info_fp = File.new("hostel_info.csv", "w")
# hostel_info_json = File.new("hostel_info.txt", "w")
# agent.page.link_with(:text => "HotelHotel Hostel").click
#   hostel_amenities_XML = agent.page.search(".facilitylist li")
#   hostel_amenities = hostel_amenities_XML.map(&:text).map(&:strip)
#   hostel_address_XML = agent.page.search(".address")
#   hostel_address = hostel_address_XML.map(&:text).map(&:strip)
#   full_address = []
#   room_types = []
#   room_prices = []
#   rating = 0
#   individual_ratings_categories = ["Value", "Safety", "Location", "Staff", "Atmosphere", "Cleanliness", "Facilities"]
#   individual_ratings = []
#   num_reviews = 0
#   description = ""
#   additional_notes = ""

#   # Get the rating
#   agent.page.link_with(:text => "Reviews").click
#     rating_XML = agent.page.search("h3")
#     rating = rating_XML.map(&:text).map(&:strip)[0].to_i

#     num_reviews_XML = agent.page.search(".numreviews")
#     num_reviews = num_reviews_XML.map(&:text).map(&:strip)[0].to_i

#     individual_rating_helper_XML = agent.page.search(".microratingpanel li")
#     individual_rating_helper = individual_rating_helper_XML.children.children.map(&:text).map(&:strip)
#     individual_rating_helper.each do |rated|
#       ind_rating = rated.to_i
#       individual_ratings.push(ind_rating)
#     end
#   agent.back()

#   # Get the address
#   hostel_address.each do |address|
#     bad_format_address = address.to_s
#     bad_format_address.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
#     good_format_address = bad_format_address.split(",").map(&:strip)
#     full_address.push(good_format_address)
#   end
#   full_address.flatten!

#   # Write Name, rating, and address
#   hostel_info_fp.write("HotelHotel Hostel\n\n")
#   hostel_info_fp.write("\n#{full_address}\n")
#   hostel_info_fp.write("\nHostelworld rating: #{rating}\n")
#   hostel_info_fp.write("\nNumber of Reviews: #{num_reviews}\n")
#   hostel_info_fp.write("\n#{individual_ratings_categories}\n")
#   hostel_info_fp.write("\n#{individual_ratings}\n")


#   # Get the description
#   description_XML = agent.page.search(".bigtext")
#   description = description_XML.map(&:text).map(&:strip)[0]
#   description = description.gsub(/(\s[,])/, ",").gsub(/(\s[.])/, ".").gsub(/(\s[!])/, "!").gsub(/(\s[?])/, "?")
#   description = description.gsub(/([,.!?][abd-zA-Z])/, " ")

#   # Get the extra notes
#   additional_notes_XML = agent.page.search(".cancellationpolicy")
#   additional_notes = additional_notes_XML.map(&:text).map(&:strip)[0]
#   additional_notes = additional_notes.gsub(/(\s[,])/, ",").gsub(/(\s[.])/, ".").gsub(/(\s[!])/, "!").gsub(/(\s[?])/, "?")
#   additional_notes = additional_notes.gsub(/([,.!?][abd-zA-Z])/, " ")


#   # Write description and additional info
#   hostel_info_fp.write("\nDescription: \n#{description}\n")
#   hostel_info_fp.write("\nAddtional info:\n#{additional_notes}\n")


#   # Write Amenities
#   hostel_info_fp.write("Amenities:\n")
#   hostel_amenities.each do |amenity|
#     hostel_info_fp.write(amenity + ", ")
#   end

#   form = agent.page.form_with(:action => "http://www.hostelworld.com/hosteldetails.php/HotelHotel-Hostel/Seattle/53155#availability")
#   form.date_from = "14 May 2014"
#   form.date_to = "15 May 2014"
#   form.submit

#   # Room types
#   hostel_room_types_XML = agent1.page.search(".roomtype td").map(&:children)
#   hostel_room_types_XML.map!(&:children)
#   hostel_room_types_XML.each do |room|
#     room_type = room[0].to_s
#     room_type.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
#     room_types.push(room_type)
#   end

#   # Prices
#   room_prices_XML = agent1.page.search(".availability td:nth-child(2) .currency").map(&:text).map(&:strip)
#   room_prices_XML.each do |price|
#     room_price = price.gsub("US$", "").to_f
#     room_prices.push(room_price)
#   end

#   # If the room has a price show them, if not just print the rooms
#   hostel_info_fp.write("\n\nRooms and Prices:\n")
#   if room_types.length == room_prices.length
#     room_info = Hash[room_types.zip room_prices]
#     room_info.each do |type, price|
#       hostel_info_fp.write("#{type} $#{price}," + "\n")
#     end
#   else room_types.each { |room| hostel_info_fp.write(room + "\n") }
#   end

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
