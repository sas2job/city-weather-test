require_relative "weather_api_client"
require_relative "weather_storage"
require "yaml"

class WeatherService
  def initialize(api_key: ENV.fetch("WEATHER_API_KEY"))
    @client = WeatherApiClient.new(api_key: api_key)
    @storage = WeatherStorage.new
  end

  def run
    cities.each do |city|
      data = @client.fetch_weather(city)
      temp = data.dig("current", "temp_c")
      puts "Fetched for #{city}: #{temp}°C"

      @storage.save(city, data)
    end
  ensure
    @storage.close if @storage
  end

  private

  def cities
    config = YAML.load_file(File.expand_path("../../config/cities.yml", __FILE__))
    config["default_cities"]
  end
end
