require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }


hostel_url_json = File.new("hostel_url.txt", "w")

agent.page.link_with(:text => "Seattle").click
  hostels_XML = agent.page.search("h2 .gotoMicrosite")
  hostels_name = hostels_XML.map(&:text).map(&:strip)
  hostels_urls = hostels_XML.map{ |a| a['href'] }.compact.uniq
  hostels = Hash[hostels_name.zip hostels_urls]

  hostels_fp.write("\nHostels\n\n")
  hostels.each do |hostel, url|
    hostels_fp.write(hostel + ", " + url + "\n")
  end
