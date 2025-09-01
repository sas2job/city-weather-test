#!/usr/bin/env ruby

require "dotenv/load"
require_relative "../lib/weather_service"

WeatherService.new.run
