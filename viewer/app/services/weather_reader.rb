require "nats/io/client"
require "json"

class WeatherReader
  STREAM  = "WEATHER"
  SUBJECT = "weather.data"
  DURABLE = "viewer_reader"

  def initialize
    @nats_url = ENV.fetch("NATS_URL", "nats://nats-server:4222")
    @nats = NATS::IO::Client.new
    @nats.connect(servers: [@nats_url])
    @js = @nats.jetstream

    @buffer = []

    ensure_consumer
  end

  def fetch_messages(limit: 50)
    begin
      sub = @js.pull_subscribe(SUBJECT, DURABLE)
      batch = sub.fetch(limit, timeout: 1)

      batch.each do |msg|
        data = JSON.parse(msg.data)
        @buffer << data
        msg.ack
      end
    rescue => e
      Rails.logger.warn "NATS read error: #{e.message}"
    end

    @buffer
  end

  def close
    @nats.close if @nats
  end

  private

  def ensure_consumer
    begin
      @js.add_consumer(STREAM, {
        durable_name: DURABLE,
        deliver_policy: "all",
        ack_policy: "explicit"
      })
      Rails.logger.info "Consumer #{DURABLE} is ready"
    rescue => e
      Rails.logger.warn "Consumer #{DURABLE} may already exist: #{e.message}"
    end
  end
end
