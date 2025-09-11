require "nats/io/client"
require "json"
require "logger"

class WeatherStorage
  STREAM  = "WEATHER"
  SUBJECT = "weather.data"
  LOGGER  = Logger.new($stdout)

  def initialize
    @nats_url = ENV.fetch("NATS_URL", "nats://127.0.0.1:4222")

    LOGGER.info("Connecting to NATS server at #{@nats_url}")
    @nats = NATS::IO::Client.new
    @nats.connect(servers: [@nats_url])

    @js = @nats.jetstream

    ensure_stream
  end

  def save(city, data)
    payload = { city: city, weather: data, fetched_at: Time.now.utc }.to_json
    @js.publish(SUBJECT, payload)
    LOGGER.info("Saved weather data for #{city}")
  rescue => e
    LOGGER.error("Error while saving to JetStream: #{e.message}")
  end

  def read_all
    messages = []
    begin
      sub = @js.pull_subscribe(SUBJECT, "weather_reader")
      batch = sub.fetch(10, timeout: 1)
      batch.each do |msg|
        messages << JSON.parse(msg.data)
        msg.ack
      end
    rescue => e
      LOGGER.error("Error while reading from JetStream: #{e.message}")
    end
    messages
  end

  def close
    @nats.close if @nats
  end

  private

  def ensure_stream
    begin
      @js.add_stream(name: STREAM, subjects: [SUBJECT])
      LOGGER.info("Stream #{STREAM} is ready")
    rescue => e
      LOGGER.warn("Stream #{STREAM} may already exist: #{e.message}")
    end
  end
end
