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
