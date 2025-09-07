class WeatherController < ApplicationController
  def index
    @messages = WEATHER_READER.fetch_messages(limit: 100)
  end
end
