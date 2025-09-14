#!/usr/bin/env ruby
require_relative '../config/environment'
require 'erb'

Dir.glob('features/**/*.feature.erb').each do |erb_file|
  puts "[DEBUG] Generating #{erb_file.gsub('.erb','')}"
  content = ERB.new(File.read(erb_file)).result(binding)
  File.write(erb_file.gsub('.erb',''), content)
end
