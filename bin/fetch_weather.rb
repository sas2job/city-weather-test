#!/usr/bin/env ruby

require "dotenv/load"
require_relative "../lib/weather_api_client"
require "yaml"

config = YAML.load_file("config/cities.yml")
client = WeatherApiClient.new(api_key: ENV.fetch("WEATHER_API_KEY"))

config["default_cities"].each do |city|
  data = client.fetch_weather(city)
  puts "Fetched for #{city}: #{data["current"]["temp_c"]}°C"
end
