require "pry"
require "nokogiri"
require "mechanize"
require "logger"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

# countries_file = {"Georgia"=>"http://www.hostelbookers.com/hostels/georgia/", "Greece"=>"http://www.hostelbookers.com/hostels/greece/"}
countries_file = eval(File.read("hostelbookers_countries.txt"))
cities_csv = File.new("hostelbookers_cities.csv", "w")
cities_json = File.new("hostelbookers_cities.txt", "w")
agent.log = Logger.new $stderr
agent.agent.http.debug_output = $stderr

cities_all = {}

countries_file.each do |country, url|
  cities_urls = []
  agent.get(url)
  cities_XML = agent.page.search("#contentLeft .genLink a")
  cities_name = cities_XML.map(&:text).map(&:strip).compact.uniq
  cities_end_urls = cities_XML.map{ |a| a['href'] }.compact.uniq

  cities_end_urls.each do |url|
    cities_urls << "http://www.hostelbookers.com#{url}"
  end

  cities = Hash[cities_name.zip cities_urls]
  cities_by_country = Hash[country => cities]

  cities_all[country] = cities

  cities_by_country.each do |country, cities|
    cities.each do |city, url|
      cities_csv.write(country + ",," + city + "," + url + "\n")
    end
  end
end

cities_json.write(cities_all)
