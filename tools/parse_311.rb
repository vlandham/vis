#!/usr/bin/env ruby

require 'time'
require 'date'
require 'json'

input_filename = ARGV[0]
output_filename = File.join(Dir.pwd, "requests.json")

start = Time.now


start_date = DateTime.new(2012, 10, 14)
end_date = DateTime.new(2012, 11, 17)
date_range = (start_date..end_date)


def date_string datetime
  datetime.strftime('%m/%d/%y')
end

nypd_counts = Hash.new {|h,k| h[k] = Hash.new(0)}
other_counts = Hash.new {|h,k| h[k] = Hash.new(0)}
all_counts = Hash.new {|h,k| h[k] = Hash.new(0)}


field_index = 5
header = false
File.open(input_filename, 'r').each_line do |line|
  if !header
    header = true
    next
  end

  fields = line.split(",")
  time_format = '%m/%d/%Y %I:%M %p'
  # puts fields[1]
  time = DateTime.strptime(fields[1], time_format)

  call_type = fields[field_index]
  call_type = call_type.split("-")[0].strip.downcase.capitalize

  date_string = date_string(time)
  if fields[3] == "NYPD"
    nypd_counts[call_type][date_string] += 1
  else
    other_counts[call_type][date_string] += 1
  end
    all_counts[call_type][date_string] += 1
end

# counts = nypd_counts
counts = all_counts

def total report_hash
  report_hash.values.inject(0) {|memo, obj| memo += obj; memo}
end
counts = counts.to_a.sort {|a,b| total(b[1]) <=> total(a[1])}

output = []
counts.each do |count|
  # puts count[0]

  entry = {"key" => count[0], "values" => []}

  # hours = count[1].to_a.sort {|a,b| a[0] <=> b[0]}
  hours = count[1]
  date_range.to_a.each do |day|
    day_string = date_string(day)
    count = hours[day_string]
    if !count
      count = 0
    end
    value = {"date" => day_string, "count" => count}
    entry["values"] << value
  end

  output << entry
end

File.open(output_filename, 'w') do |file|
file.puts JSON.pretty_generate(JSON.parse(output.to_json))
end

stop = Time.now

puts (stop - start).to_f

