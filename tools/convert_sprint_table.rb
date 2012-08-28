#!/usr/bin/env ruby

require 'json'

input_filename = ARGV[0]

output_filename = input_filename.split(".")[0..-2].join(".") + "_data.json"


raw_data = File.open(input_filename,'r').read.split("\n").collect {|l| l.split("\t")}

header = nil
all_data = []
raw_data.each_with_index do |line, line_index|
  if !header
    header = line
    next
  end

  if line_index == 1
    next
  end

  if line_index % 2 == 0
    fields = header.zip(line)

    run = fields.select{|f| f[0] =~ /^[S\d]+-[F\d]+/}
    run_keys = run.collect {|r| r[0]}
    run = run.collect {|r| {"name" => r[0], "time" => r[1].to_f}}
    data = Hash[fields]
    data.select! {|k,v| !run_keys.include?(k) }
    data["run"] = run
    all_data << data
  else
  end

end

File.open(output_filename,'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(all_data.to_json))
end
