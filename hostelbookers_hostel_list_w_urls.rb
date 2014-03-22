require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

# cities_file = {"Albania"=>{""=>{"Berat"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Berat/ChosenCountry.Albania", "Himare"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Himare/ChosenCountry.Albania"}}, "Australia"=>{"Western Australia"=>{"Albany"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Albany/ChosenCountry.Australia", "Bunbury"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Bunbury/ChosenCountry.Australia"}, "Northern Territory"=>{"Alice Springs"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Alice-Springs/ChosenCountry.Australia", "Darwin"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Darwin/ChosenCountry.Australia", "Tennant Creek"=>"http://www.hostelworld.com/findabed.php/ChosenCity.Tennant-Creek/ChosenCountry.Australia"}}}
cities_file = eval(File.read("hostelbookers_cities.txt"))
hostel_list_csv = File.new("hostelbookers_hostel_list.csv", "w")
hostel_list_json = File.new("hostelbookers_hostel_list.txt", "w")
every_hostel_url = File.new("hostelbookers_every_hostels_url.txt", "w")

hostel_list_complete = {}
hostels_url = {}

cities_file.each do |country, states|
  hostels_by_state = {}

  states.each do |state, cities|
    hostels_by_city = {}

    cities.each do |city, url|
      agent.get(url)
      hostels_XML = agent.page.search("h2 .gotoMicrosite")
      hostels_name = hostels_XML.map(&:text).map(&:strip)
      hostels_urls = hostels_XML.map{ |a| a['href'] }.compact.uniq
      hostels = Hash[hostels_name.zip hostels_urls]
      hostels_by_city[city] = hostels
    end

    hostels_by_state[state] = hostels_by_city
  end

  hostels_by_country = Hash[country => hostels_by_state]

  hostel_list_complete[country] = hostels_by_country

  hostels_by_country.each do |country, states|
    states.each do |state, city|
      city.each do |city, hostel|
        hostel.each do |hostel, url|
          hostel_list_csv.write(country + "," + state + "," + city + "," + hostel + "," + url + "\n")
          hostels_url[hostel] = url
        end
      end
    end
  end

end

hostel_list_json.write(hostel_list_complete)
every_hostel_url.write(hostels_url)
