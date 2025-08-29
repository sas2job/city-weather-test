require "net/http"
require "json"

class WeatherApiClient
  BASE_URL = "http://api.weatherapi.com/v1"

  def initialize(api_key:)
    @api_key = api_key
  end

  def fetch_weather(city)
    url = URI("#{BASE_URL}/forecast.json?key=#{@api_key}&q=#{city}&hours=1")
    res = Net::HTTP.get_response(url)
    raise "Weather API error: #{res.code}" unless res.is_a?(Net::HTTPSuccess)
    JSON.parse(res.body)
  end
end
