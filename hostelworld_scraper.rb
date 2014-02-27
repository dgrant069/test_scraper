require "nokogiri"
require "pry"
require "mechanize"

url = ARGV[0]
fp = File.new("hostelworld_scraper.txt", "w")
country_fp = File.new("hostelworld_country.txt", "w")
state_fp = File.new("hostelworld_state.txt", "w")
city_fp = File.new("hostelworld_city.txt", "w")
hostel_fp = File.new("hostelworld_hostel.txt", "w")
agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
html = agent.get(url).body
html_doc = Nokogiri::HTML(html)

countries = {}
states = {}
cities = {}
hostels = {}

# agent.get("http://www.hostelworld.com/hostels")
countries_XML = agent.page.search(".topratedlist a")
countries_name = countries_XML.map(&:text).map(&:strip)
countries_urls = countries_XML.map{ |a| a['href'] }.compact.uniq
countries = Hash[countries_name.zip countries_urls]

fp.write("Countries\n\n")

countries.each do |country, url|
  fp.write(country + ", " + url + "\n")

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

state_fp.write("\nStates\n\n")
state_fp.write(states_name)

agent.page.link_with(:text => "Washington").click
cities_XML = agent.page.search("#bottomlist a")
cities_name = cities_XML.map(&:text).map(&:strip)
cities_urls = cities_XML.map{ |a| a['href'] }.compact.uniq
cities = Hash[cities_name.zip cities_urls]


city_fp.write("\nCities\n\n")
city_fp.write(cities_name)
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
