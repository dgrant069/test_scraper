require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

countries_file = eval(File.read("hostelbookers_countries.txt"))
states_file = eval(File.read("hostelbookers_states.txt"))
cities_csv = File.new("hostelbookers_cities.csv", "w")
cities_json = File.new("hostelbookers_cities.txt", "w")

cities_all = {}

countries_file.each do |country, url|
  agent.get(url)
  cities_XML = agent.page.search("#bottomlist a")
  cities_name = cities_XML.map(&:text).map(&:strip)
  cities_urls = cities_XML.map{ |a| a['href'] }.compact.uniq
  cities = Hash[cities_name.zip cities_urls]
  cities_by_state = Hash["" => cities]
  cities_by_country = Hash[country => cities_by_state]

  cities_all[country] = cities_by_state

  cities_by_country.each do |country, states|
    states.each do |state, cities|
      cities.each do |city, url|
        cities_csv.write(country + ",," + city + "," + url + "\n")
      end
    end
  end
end

states_file.each do |country, states|
  cities_by_state = {}
  states.each do |state, url|
    agent.get(url)
    cities_XML = agent.page.search("#bottomlist a")
    cities_name = cities_XML.map(&:text).map(&:strip)
    cities_urls = cities_XML.map{ |a| a['href'] }.compact.uniq
    cities = Hash[cities_name.zip cities_urls]
    cities_by_state[state] = cities
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
