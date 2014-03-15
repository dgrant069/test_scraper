require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

countries_file = eval(File.read("hostelworld_countries.txt"))
states_file = eval(File.read("hostelworld_states.txt"))
cities_csv = File.new("hostelworld_cities.csv", "w")
cities_json = File.new("hostelworld_cities.txt", "w")

# Need to turn this into a city approach where if the country in the state file is null,
# it uses the country file to get the cities. Or write two seperate files and join later
# in Access
countries_file.each do |country, url|
  country = country
  agent.get(url)
  states_XML = agent.page.search("#states a")
  states_name = states_XML.map(&:text).map(&:strip)
  states_urls = states_XML.map{ |a| a['href'] }.compact.uniq
  states = Hash[states_name.zip states_urls]
  states_full = Hash[country => states]
  states_json.write(states_full)

  states_full.each do |country, state|
    state.each do |state, url|
      states_csv.write(country + "," + state + "," + url + "\n")
    end
  end
end
