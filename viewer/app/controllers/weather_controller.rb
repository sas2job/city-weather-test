class WeatherController < ApplicationController
  def index
    start_of_day = Time.zone.now.beginning_of_day
    now          = Time.zone.now

    @q = WeatherRecord.includes(:city).joins(:city).where(fetched_at: start_of_day..now).ransack(params[:q])
    @messages = @q.result(distinct: true)
  end
end
