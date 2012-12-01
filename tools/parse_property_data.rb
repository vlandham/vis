#!/usr/bin/env ruby

require 'json'
require 'csv'

input_filename = ARGV[0]

output_filename = "properties.json"

cities = {}

agg_values = ["percent_govt_leased", "rent_prsf", "total_leased_rsf", "total_annual_rent"]

CSV.foreach(input_filename, :headers => true) do |row|

  # key = row["city"] + "_" + row["state"]
  key = row["city"] + "_" + row["state"] + row["gsa_building_no"]

  if !cities[key]
    data = {"city" => row["city"], "state" => row["state"], "zip" => row["zipcode"]}
    agg_values.each {|v| data[v] = 0.0}
    data["count"] = 0
    data["lon_lat"] = [row["longitude"].to_f, row["latitude"].to_f]
    cities[key] = data
  end

  agg_values.each do |v|
    cities[key][v] += row[v].to_f
  end

  cities[key]["count"] += 1

  if cities[key]["lon_lat"][0] == 0.0
    # puts "replacing lat lon"
    cities[key]["lon_lat"] =  [row["longitude"].to_f, row["latitude"].to_f]
  end

  # if cities[row["city"]]["state"] != row["state"]
  #   puts "ERROR state mismatch"
  #   puts "#{cities[row["city"]]}"
  #   puts "#{cities[row["city"]]["state"] }"
  #   puts "#{row["state"]}"

  # end

end

data = cities.values.sort {|a,b| b["count"] <=> a["count"]}

data.each do |city|
  agg_values.each do |v|
    city[v] = city[v].round(3)
    avg_key = v+"_avg"
    city[avg_key] = (city[v] / city["count"]).round(3)
  end
end

File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(data.to_json))
end


