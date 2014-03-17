require "pry"
require "nokogiri"
require "mechanize"

agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }

countries_file = eval(File.read("hostelworld_countries.txt"))
states_csv = File.new("hostelworld_states.csv", "w")
states_json = File.new("hostelworld_states.txt", "w")

state_by_country = {}

countries_file.each do |country, url|
  agent.get(url)
  states_XML = agent.page.search("#states a")
  states_name = states_XML.map(&:text).map(&:strip)
  states_urls = states_XML.map{ |a| a['href'] }.compact.uniq
  states = Hash[states_name.zip states_urls]
  states_full = Hash[country => states]

  if (states_full[country] == {})
  else state_by_country[country] = states
  end

  states_full.each do |country, state|
    state.each do |state, url|
      states_csv.write(country + "," + state + "," + url + "\n")
    end
  end
end

states_json.write(state_by_country)
