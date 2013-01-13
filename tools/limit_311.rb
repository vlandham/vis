#!/usr/bin/env ruby

require 'date'

input_filename = ARGV[0]

output_filename = File.join(Dir.pwd, "311_contrained.csv")

output_file = File.open(output_filename, 'w')

# year = 2012

start_date = DateTime.new(2012, 10, 01)
end_date = DateTime.new(2012, 11, 30)

# start_date = DateTime.new(2013, 01, 04)
# end_date = DateTime.new(2013, 01, 05)

date_range = (start_date..end_date)

header = false

File.open(input_filename, 'r').each_line do |line|
  if !header
    output_file.puts line
    header = true
    next
  end

  fields = line.split(",")
  time_format = '%m/%d/%Y %I:%M %p'
  time = DateTime.strptime(fields[1], time_format)

  # next unless time.year == year

  if date_range.cover?(time)
    output_file.puts line
  end
end

output_file.close
