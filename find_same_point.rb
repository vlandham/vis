#!/usr/bin/env ruby


location_csv_filename = ARGV[0]

location_data = File.open(location_csv_filename, 'r').read.split("\n").collect {|l| l.split(",")}

location_lat_lons = location_data.collect {|d| "#{d[1]}_#{d[2]}"}

location_lat_lons.each do |lat_lon|

  if location_lat_lons.index(lat_lon) != location_lat_lons.rindex(lat_lon)
    puts location_data[location_lat_lons.index(lat_lon)].join(",")
  end

end
