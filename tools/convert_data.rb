#!/usr/bin/env ruby

require 'json'
require 'csv'

input_filename = ARGV[0]

output_filename = File.basename(input_filename, File.extname(input_filename)) + ".json"

country_codes = ["CHN", "USA", "EUU", "IND", "RUS", "JPN"]

years = (1961..2008).to_a

data = {}

CSV.foreach(input_filename, :headers => true) do |row|
  if country_codes.include? row["Country Code"]
    years.each do |year|
      data[year] ||= Hash.new
      data[year]["year"] = year
      data[year]["values"] ||= []
      data[year]["values"]<< {"name" => row["Country Code"], "value" => row[year.to_s].to_f}
    end
  end
end

data = data.values

data.each do |year|
  year["values"].sort! {|a,b| country_codes.find_index(a["name"]) <=> country_codes.find_index(b["name"])}
end

File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(data.to_json))
end



