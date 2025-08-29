require 'nats/io/client'
require 'json'

class WeatherPublisher
  def initialize
    @nats_url = ENV.fetch("NATS_URL", "nats://127.0.0.1:4222")
    @api_key = ENV["WEATHER_API_KEY"]
  end

  def connect
    puts "Connecting to NATS server at #{@nats_url}"
    @nats = NATS::IO::Client.new
    @nats.connect(servers: [@nats_url])
  end

  def publish(subject, message)
    payload = message.is_a?(String) ? message : message.to_json
    @nats.publish(subject, payload)
    @nats.flush
  end

  def close
    @nats.close if @nats
  end
end

