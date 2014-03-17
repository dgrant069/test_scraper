require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

# every_hostel_url = eval(File.read("every_hostel_url.txt"))
every_hostel_url = {"Berat Backpackers Hostel"=>"http://www.hostelworld.com/hosteldetails.php/Berat-Backpackers-Hostel/Berat/30936", "Nasho Vruho Hotel and Guesthouse"=>"http://www.hostelworld.com/hosteldetails.php/Nasho-Vruho-Hotel-and-Guesthouse/Berat/61560", "Guesthouse Kris"=>"http://www.hostelworld.com/hosteldetails.php/Guesthouse-Kris/Berat/52067"}
hostel_info_fp = File.new("hostel_info.csv", "w")
hostel_info_json = File.new("hostel_info.txt", "w")

every_hostel_url.each do |hostel, url|
  agent.get(url)
  hostel_amenities_XML = agent.page.search(".facilitylist li")
  hostel_amenities = hostel_amenities_XML.map(&:text).map(&:strip)
  hostel_address_XML = agent.page.search(".address")
  hostel_address = hostel_address_XML.map(&:text).map(&:strip)
  full_address = []
  room_types = []
  room_prices = []
  rating = 0
  individual_ratings_categories = ["Value", "Safety", "Location", "Staff", "Atmosphere", "Cleanliness", "Facilities"]
  individual_ratings = []
  num_reviews = 0
  description = ""
  additional_notes = ""

  # Get the address
  hostel_address.each do |address|
    bad_format_address = address.to_s
    bad_format_address.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
    good_format_address = bad_format_address.split(",").map(&:strip)
    full_address.push(good_format_address)
  end
  full_address.flatten!

  # Get the description
  description_XML = agent.page.search(".bigtext")
  description = description_XML.map(&:text).map(&:strip)[0]
  description = description.gsub(/(\s[,])/, ",").gsub(/(\s[.])/, ".").gsub(/(\s[!])/, "!").gsub(/(\s[?])/, "?")
  description = description.gsub(/([,.!?][abd-zA-Z])/, " ")

  # Get the extra notes
  additional_notes_XML = agent.page.search(".cancellationpolicy")
  additional_notes = additional_notes_XML.map(&:text).map(&:strip)[0]
  additional_notes = additional_notes.gsub(/(\s[,])/, ",").gsub(/(\s[.])/, ".").gsub(/(\s[!])/, "!").gsub(/(\s[?])/, "?")
  additional_notes = additional_notes.gsub(/([,.!?][abd-zA-Z])/, " ")

  form = agent.page.form_with(:action => "http://www.hostelworld.com/hosteldetails.php/HotelHotel-Hostel/Seattle/53155#availability")
  form.date_from = "14 May 2014" # Always do 3 months out on a Tuesday to a Wednesday
  form.date_to = "15 May 2014" # May hit holidays sometimes. Will know if rooms come back nil or $$$$
  form.submit

  # Room types
  hostel_room_types_XML = agent1.page.search(".roomtype td").map(&:children)
  hostel_room_types_XML.map!(&:children)
  hostel_room_types_XML.each do |room|
    room_type = room[0].to_s
    room_type.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
    room_types.push(room_type)
  end

  # Prices
  room_prices_XML = agent1.page.search(".availability td:nth-child(2) .currency").map(&:text).map(&:strip)
  room_prices_XML.each do |price|
    room_price = price.gsub("US$", "").to_f
    room_prices.push(room_price)
  end

  # Get the rating
  agent.page.link_with(:text => "Reviews").click
    rating_XML = agent.page.search("h3")
    rating = rating_XML.map(&:text).map(&:strip)[0].to_i

    num_reviews_XML = agent.page.search(".numreviews")
    num_reviews = num_reviews_XML.map(&:text).map(&:strip)[0].to_i

    individual_rating_helper_XML = agent.page.search(".microratingpanel li")
    individual_rating_helper = individual_rating_helper_XML.children.children.map(&:text).map(&:strip)
    individual_rating_helper.each do |rated|
      ind_rating = rated.to_i
      individual_ratings.push(ind_rating)
    end
    last_review_XML = agent.page.search(".reviewrating")
    last_review = last_review_XML.map(&:text).map(&:strip)[0]

  agent.back() # If at end of loop, don't need to go back

  hostel_info_fp.write("HotelHotel Hostel\n\n")
  hostel_info_fp.write("\n#{full_address}\n")
  hostel_info_fp.write("\nHostelworld rating: #{rating}\n")
  hostel_info_fp.write("\nNumber of Reviews: #{num_reviews}\n")
  hostel_info_fp.write("\n#{individual_ratings_categories}\n")
  hostel_info_fp.write("\n#{individual_ratings}\n")
  hostel_info_fp.write("\nDescription: \n#{description}\n")
  hostel_info_fp.write("\nAddtional info:\n#{additional_notes}\n")
  hostel_info_fp.write("Amenities:\n")
  hostel_amenities.each do |amenity|
    hostel_info_fp.write(amenity + ", ")
  end
  hostel_info_fp.write("\n\nRooms and Prices:\n")
  if room_types.length == room_prices.length
    room_info = Hash[room_types.zip room_prices]
    room_info.each do |type, price|
      hostel_info_fp.write("#{type} $#{price}," + "\n")
    end
  else room_types.each { |room| hostel_info_fp.write(room + "\n") }
  end
end
