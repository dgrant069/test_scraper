require "pry"
require "nokogiri"
require "mechanize"
require "logger"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

# every_hostel_url = {}
every_hostel_url = eval(File.read("hostelbookers_every_hostels_url.txt"))
hostel_info_fp = File.new("hostelbookers_hostel_info.csv", "w")
hostel_table_rooms = File.new("hostelbookers_hostel_table_rooms.csv", "w")
hostel_table_ratings = File.new("hostelbookers_hostel_table_ratings.csv", "w")
hostel_table_amenities = File.new("hostelbookers_hostel_table_amenities.csv", "w")
hostel_info_json = File.new("hostelbookers_hostel_info.txt", "w")
agent.keep_alive = false
agent.idle_timeout = 0
agent.log = Logger.new $stderr
agent.agent.http.debug_output = $stderr

hostel_info_complete = {}

every_hostel_url.each do |hostel, url|
  each_hostel_all_info = {}

  full_address = []
  room_types = []
  room_prices = []
  rating = 0
  individual_ratings_categories = ["Atmosphere", "Location", "Facilities", "Cleanliness", "Staff", "Value", "Safety"]
  individual_ratings = []
  num_reviews = 0
  description = ""
  additional_notes = ""

  agent.get(url)
  sleep(1)
  hostel_address_XML = agent.page.search("span span")
  hostel_address = hostel_address_XML.map(&:text).map(&:strip)
  hostel_address.each do |address|
    bad_format_address = address.to_s
    bad_format_address.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    bad_format_address.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
    good_format_address = bad_format_address.split(",").map(&:strip)
    full_address.push(good_format_address)
  end
  full_address.flatten!

  hostel_amenities_XML = agent.page.search("#included li , #facilities li")
  hostel_amenities = hostel_amenities_XML.map(&:text).map(&:strip).compact.uniq

  # Get the description
  description_XML = agent.page.search("#about div")
  description = description_XML.map(&:text).map(&:strip)[0]
  if description != nil
    description.gsub!(/(\s[,])/, ",")
    description.gsub!(/(\s[.])/, ".")
    description.gsub!(/(\s[!])/, "!")
    description.gsub!(/(\s[?])/, "?")
    description.gsub!(/([,.!?][abd-zA-Z])/, " ")
  end

  # Get the extra notes
  additional_notes_XML = agent.page.search("#about p")
  additional_notes = additional_notes_XML.map(&:text).map(&:strip)[0]
  if additional_notes != nil
    additional_notes.gsub!(/(\s[,])/, ",")
    additional_notes.gsub!(/(\s[.])/, ".")
    additional_notes.gsub!(/(\s[!])/, "!")
    additional_notes.gsub!(/(\s[?])/, "?")
    additional_notes.gsub!(/([,.!?][abd-zA-Z])/, " ")
  end

  appointment_details_XML = agent.page.search("#checkInCheckout p")
  appointment_details = appointment_details_XML.map(&:text).map(&:strip)[0]
  if appointment_details != nil
    appointment_details.gsub!(/(\s[,])/, ",")
    appointment_details.gsub!(/(\s[.])/, ".")
    appointment_details.gsub!(/(\s[!])/, "!")
    appointment_details.gsub!(/(\s[?])/, "?")
    appointment_details.gsub!(/([,.!?][abd-zA-Z])/, " ")
  end


  form = agent.page.form_with###(:action => "#{url}#availability")
  form.strArrivalDate = "16 Jun 2014" # Always do 3 months out on a Tuesday to a Wednesday
  form.strCheckoutDate = "17 Jun 2014" # May hit holidays sometimes. Will know if rooms come back nil or $$$$
  form.submit
  sleep(1)

  # Room types
  hostel_room_types_XML = agent.page.search("#rooms h3").map(&:children)
  if hostel_room_types_XML != nil
  hostel_room_types_XML.map!(&:children)
    hostel_room_types_XML.each do |room|
      room_type = room[0].to_s
      room_type.gsub!(/(?<=^|\[)\s+|\s+(?=$|\])|(?<=\s)\s+/, "")
      room_types.push(room_type)
    end
  end

  # Prices
  room_prices_XML = agent.page.search(".bedPrice strong").map(&:text).map(&:strip)
  if room_prices_XML != nil
    room_prices_XML.each do |price|
      room_price = price.gsub("US$", "").to_f
      room_prices.push(room_price)
    end
  end

  room_and_price = Hash[room_types.zip room_prices]

  # Get the rating
  if agent.page.link_with(:text => "ratings & reviews") != nil
    agent.page.link_with(:text => "ratings & reviews").click
    sleep(1)
    rating_XML = agent.page.search("#overallRatingBubble")
    rating = rating_XML.map(&:text).map(&:strip)[0].to_i

    num_reviews_XML = agent.page.search("strong:nth-child(1) span")
    num_reviews = num_reviews_XML.map(&:text).map(&:strip)[0].to_i

    individual_rating_helper_XML = agent.page.search(".ratingPercentage")
    individual_rating_helper = individual_rating_helper_XML.children.children.map(&:text).map(&:strip)
    individual_rating_helper.each do |rated|
      ind_rating = rated.to_i
      individual_ratings.push(ind_rating)
    end

    rating_by_category = Hash[individual_ratings_categories.zip individual_ratings]

    last_review_XML = agent.page.search("#latestReview h2").map(&:text).map(&:strip)[0]
    last_review_length = last_review_XML.length - 10
    last_review = last_review_XML[last_review_length..-2]
  end

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

  if description != nil
    description.gsub!("\n", " ")
    description.gsub!("\r", " ")
    description.gsub!("  ", " ")
  end

  if additional_notes != nil
    additional_notes.gsub!("\n", " ")
    additional_notes.gsub!("\r", " ")
    additional_notes.gsub!("  ", " ")
  end

  hostel_info_fp.write(hostel + ";" + url + ";" + "#{full_address}" + ";" + "#{rating}" + ";" + "#{num_reviews}" + ";" + "#{last_review}" + ";" + "#{description}" + ";" + "#{additional_notes}" + ";" + "#{hostel_amenities}" + "\n")

  if room_and_price != nil
    room_and_price.each do |room, price|
      hostel_table_rooms.write(hostel + "," + url + "," + room +  "," + "#{price}" + "\n")
    end
  end

  if rating_by_category != nil
    rating_by_category.each do |type, rating|
      hostel_table_ratings.write(hostel + "," + url + "," + type +  "," + "#{rating}" + "\n")
    end
  end

  if hostel_amenities != nil
    hostel_amenities.each do |amenity|
      hostel_table_amenities.write(amenity + "\n")
    end
  end
end

hostel_info_json.write(hostel_info_complete)
