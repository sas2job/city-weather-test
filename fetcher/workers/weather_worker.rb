$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "weather_service"
require "sidekiq"
require "logger"

class WeatherWorker
  include Sidekiq::Worker

  LOGGER = Logger.new($stdout)

  def perform
    LOGGER.info("[WeatherWorker] running at #{Time.now}")
    WeatherService.new.run
  end
end

