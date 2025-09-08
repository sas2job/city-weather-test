class WeatherSyncWorker
  include Sidekiq::Worker

  def perform
    WeatherSyncService.new.sync(limit: 50)
  end
end
