require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

countries_file = {"Canada" => "http://www.hostelworld.com/hostels/Canada","Australia" => "http://www.hostelworld.com/hostels/Australia","Albania" => "http://www.hostelworld.com/hostels/Albania"}#eval(File.read("hostelworld_countries.txt"))
states_file = {"Canada"=>{"Alberta"=>"http://www.hostelworld.com/hostels/area/Alberta/Canada", "British Columbia"=>"http://www.hostelworld.com/hostels/area/British-Columbia/Canada"}, "Australia"=>{"Australian Capital Territory"=>"http://www.hostelworld.com/hostels/area/Australian-Capital-Territory/Australia", "New South Wales"=>"http://www.hostelworld.com/hostels/area/New-South-Wales/Australia", "Northern Territory"=>"http://www.hostelworld.com/hostels/area/Northern-Territory/Australia"}}#eval(File.read("hostelworld_states.txt"))
cities_csv = File.new("hostelworld_cities.csv", "w")
cities_json = File.new("hostelworld_cities.txt", "w")

cities_all = {}

# Needs to fix up
countries_file.each do |country, url|
  country = country
  filler = ""
  agent.get(url)
  cities_XML = agent.page.search("#bottomlist a")
  cities_name = cities_XML.map(&:text).map(&:strip)
  cities_urls = cities_XML.map{ |a| a['href'] }.compact.uniq
  cities = Hash[cities_name.zip cities_urls]
  cities_by_state = Hash[filler => cities]
  cities_by_country = Hash[country => cities_by_state]

  cities_all[country] = cities_by_state

  cities_by_country.each do |country, states|
    states.each do |state, cities|
      cities.each do |city, url|
        cities_csv.write(country + "," + ",," + city + "," + url + "\n")
      end
    end
  end
end

states_file.each do |country, states|
  cities_by_state = {}
  states.each do |state, url|
    country = country
    state = state
    agent.get(url)
    cities_XML = agent.page.search("#bottomlist a")
    cities_name = cities_XML.map(&:text).map(&:strip)
    cities_urls = cities_XML.map{ |a| a['href'] }.compact.uniq
    cities = Hash[cities_name.zip cities_urls]
    cities_by_state = Hash[state => cities]
  end

  cities_by_country = Hash[country => cities_by_state]

  cities_all[country] = cities_by_state

  cities_by_country.each do |country, states|
    states.each do |state, cities|
      cities.each do |city, url|
        cities_csv.write(country + "," + state + "," + city + "," + url + "\n")
      end
    end
  end
end

cities_json.write(cities_all)
