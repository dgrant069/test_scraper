require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

# cities_file = {"Egypt"=>{"Alexandria"=>"http://www.hostelbookers.com/hostels/egypt/alexandria/", "Aswan"=>"http://www.hostelbookers.com/hostels/egypt/aswan/", "Cairo"=>"http://www.hostelbookers.com/hostels/egypt/cairo/"}, "Sweden"=>{"Broddetorp"=>"http://www.hostelbookers.com/hostels/sweden/broddetorp/", "Degerhamn"=>"http://www.hostelbookers.com/hostels/sweden/degerhamn/"}}
cities_file = eval(File.read("hostelbookers_cities.txt"))
hostel_list_csv = File.new("hostelbookers_hostel_list.csv", "w")
hostel_list_json = File.new("hostelbookers_hostel_list.txt", "w")
every_hostel_url = File.new("hostelbookers_every_hostels_url.txt", "w")

hostel_list_complete = {}
hostels_url = {}

cities_file.each do |country, cities|
  hostels_by_city = {}

  cities.each do |city, url|
    hostels_urls = []
    agent.get(url)
    hostels_XML = agent.page.search(".propertyTitle")
    hostels_name = hostels_XML.map(&:text).map(&:strip).compact.uniq
    hostels_end_urls = hostels_XML.map{ |a| a['href'] }.compact.uniq

    hostels_end_urls.each do |url|
      hostels_urls << "http://www.hostelbookers.com#{url}"
    end

    hostels = Hash[hostels_name.zip hostels_urls]
    hostels_by_city[city] = hostels
  end

  hostel_list_complete[country] = hostels_by_city
  hostels_by_country = Hash[country => hostels_by_city]

  hostels_by_country.each do |country, cities|
    cities.each do |city, hostel|
      hostel.each do |hostel, url|
        hostel_list_csv.write(country + ",," + city + "," + hostel + "," + url + "\n")
        hostels_url[hostel] = url
      end
    end
  end
end

hostel_list_json.write(hostel_list_complete)
every_hostel_url.write(hostels_url)

# Need to remove http://www.hostelbookers.com/hostels/slovenia/mavcice/ from cities - 404
