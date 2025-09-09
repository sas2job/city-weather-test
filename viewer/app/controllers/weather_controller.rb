class WeatherController < ApplicationController
  def index
    start_of_day = Time.zone.now.beginning_of_day
    now          = Time.zone.now

    @messages = WeatherRecord
                  .includes(:city)
                  .joins(:city)
                  .where(fetched_at: start_of_day..now)
                  .order('cities.name ASC, weather_records.fetched_at ASC')
  end
end
