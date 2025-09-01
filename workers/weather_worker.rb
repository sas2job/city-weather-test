$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "weather_service"
require "sidekiq"

class WeatherWorker
  include Sidekiq::Worker

  def perform
    puts "[WeatherWorker] running at #{Time.now}"
    WeatherService.new.run
  end
end

