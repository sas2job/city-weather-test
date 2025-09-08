class WeatherController < ApplicationController
  def index
    @messages = WeatherRecord.includes(:city).order(:fetched_at)
  end
end
