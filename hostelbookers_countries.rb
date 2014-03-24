# ruby hostelbookers_countries.rb
require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
countries_csv = File.new("hostelbookers_countries.csv", "w")
countries_json = File.new("hostelbookers_countries.txt", "w")

countries_urls = []

agent.get("http://www.hostelbookers.com/hostels")
countries_XML = agent.page.search("#accordion h5 a")
countries_name = countries_XML.map(&:text).map(&:strip)
countries_end_url = countries_XML.map{ |a| a['href'] }.compact.uniq

countries_end_url.each do |url|
  countries_urls << "http://www.hostelbookers.com#{url}"
end
countries = Hash[countries_name.zip countries_urls]

countries_json.write(countries)

countries.each do |country, url|
  countries_csv.write(country + "," + url + "\n")
end

# remove Burundi - returns a 404
