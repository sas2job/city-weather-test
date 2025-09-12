require "nats/io/client"
require "json"

class WeatherSyncService
  STREAM  = "WEATHER"
  SUBJECT = "weather.data"
  DURABLE = "viewer_reader"

  def initialize
    @nats_url = ENV.fetch("NATS_URL", "nats://nats-server:4222")
    @nats = NATS::IO::Client.new
    @nats.connect(servers: [@nats_url])
    @js = @nats.jetstream

    ensure_consumer
  rescue => e
    Rails.logger.warn "NATS connection error: #{e.message}"
  end

  def sync(limit: 50)
    sub = @js.pull_subscribe(SUBJECT, DURABLE)

    batch = sub.fetch(limit, timeout: 1)
    batch.each do |msg|
      begin
        data = JSON.parse(msg.data)
        save_to_postgres(data)
      rescue => e
        Rails.logger.warn "Postgres save error: #{e.message}"
      ensure
        msg.ack
      end
    end
  rescue => e
    Rails.logger.warn "NATS sync error: #{e.message}"
  end

  private

  def save_to_postgres(data)
    city = City.find_or_create_by!(name: data["city"])
    WeatherRecord.create!(
      city: city,
      temp_c: data.dig("weather", "current", "temp_c"),
      fetched_at: Time.zone.parse(data["fetched_at"])
    )
  end

  def ensure_consumer
    @js.add_consumer(STREAM, {
      durable_name: DURABLE,
      deliver_policy: "all",
      ack_policy: "explicit"
    })
  rescue => e
    Rails.logger.warn "Consumer may already exist: #{e.message}"
  end
end