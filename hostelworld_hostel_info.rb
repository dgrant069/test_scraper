require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

# every_hostel_url = eval(File.read("every_hostel_url.txt"))
every_hostel_url = {"HotelHotel-Hostel"=>"http://www.hostelworld.com/hosteldetails.php/HotelHotel-Hostel/Seattle/53155","Berat Backpackers Hostel"=>"http://www.hostelworld.com/hosteldetails.php/Berat-Backpackers-Hostel/Berat/30936", "Nasho Vruho Hotel and Guesthouse"=>"http://www.hostelworld.com/hosteldetails.php/Nasho-Vruho-Hotel-and-Guesthouse/Berat/61560", "Guesthouse Kris"=>"http://www.hostelworld.com/hosteldetails.php/Guesthouse-Kris/Berat/52067"}
hostel_info_fp = File.new("hostel_info.csv", "w")
hostel_info_json = File.new("hostel_info.txt", "w")

hostel_info_complete = {}

every_hostel_url.each do |hostel, url|
  each_hostel_all_info = {}

  full_address = []
  room_types = []
  room_prices = []
  rating = 0
  individual_ratings_categories = ["Value", "Safety", "Location", "Staff", "Atmosphere", "Cleanliness", "Facilities"]
  individual_ratings = []
  num_reviews = 0
  description = ""
  additional_notes = ""

  agent.get(url)

  hostel_address_XML = agent.page.search(".address")
  hostel_address = hostel_address_XML.map(&:text).map(&:strip)
  # Get the address
  hostel_address.each do |address|
    bad_format_address = address.to_s
    bad_format_address.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
    good_format_address = bad_format_address.split(",").map(&:strip)
    full_address.push(good_format_address)
  end
  full_address.flatten!

  hostel_amenities_XML = agent.page.search(".facilitylist li")
  hostel_amenities = hostel_amenities_XML.map(&:text).map(&:strip)

  # Get the description
  description_XML = agent.page.search(".bigtext")
  description = description_XML.map(&:text).map(&:strip)[0]
  if description != nil
    description.gsub!(/(\s[,])/, ",")
    description.gsub!(/(\s[.])/, ".")
    description.gsub!(/(\s[!])/, "!")
    description.gsub!(/(\s[?])/, "?")
    description.gsub!(/([,.!?][abd-zA-Z])/, " ")
  end

  # Get the extra notes
  additional_notes_XML = agent.page.search(".cancellationpolicy")
  additional_notes = additional_notes_XML.map(&:text).map(&:strip)[0]
  if additional_notes != nil
    additional_notes.gsub!(/(\s[,])/, ",")
    additional_notes.gsub!(/(\s[.])/, ".")
    additional_notes.gsub!(/(\s[!])/, "!")
    additional_notes.gsub!(/(\s[?])/, "?")
    additional_notes.gsub!(/([,.!?][abd-zA-Z])/, " ")
  end

  form = agent.page.form_with(:action => "#{url}#availability")
  form.date_from = "14 May 2014" # Always do 3 months out on a Tuesday to a Wednesday
  form.date_to = "15 May 2014" # May hit holidays sometimes. Will know if rooms come back nil or $$$$
  form.submit

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

  room_and_price = Hash[room_types.zip room_prices]

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

    rating_by_category = Hash[individual_ratings_categories.zip individual_ratings]

    last_review_XML = agent.page.search(".reviewrating")
    last_review = last_review_XML.map(&:text).map(&:strip)[0]


  # JSON hostel info
  each_hostel_all_info["url"] = url
  each_hostel_all_info["address"] = full_address
  each_hostel_all_info["combined_rating"] = rating
  each_hostel_all_info["total_reviews"] = num_reviews
  each_hostel_all_info["last_review"] = last_review
  each_hostel_all_info["description"] = description
  each_hostel_all_info["additional_info"] = additional_notes
  each_hostel_all_info["amenities"] = hostel_amenities
  each_hostel_all_info["individual_ratings"] = rating_by_category
  each_hostel_all_info["rooms"] = room_and_price

  hostel_info_complete[hostel] = each_hostel_all_info


  # CVS Hostel info
  csv_hostel_info = Hash[hostel => each_hostel_all_info]
  csv_hostel_info.each do |hostel, info|
    hostel_info_fp.write(hostel + "," + info)
  end
end

hostel_info_json.write(hostel_info_complete)
