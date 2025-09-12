require "rails_helper"
require "securerandom"

RSpec.describe WeatherSyncService, type: :service do
  let(:nats) { instance_double("NATS::IO::Client") }
  let(:jetstream) { double("jetstream") }
  let(:pull_sub) { double("pull_subscribe") }

  let(:city_name) { "Moscow-#{SecureRandom.hex(4)}" }
  let(:msg_data) do
    {
      "city" => city_name,
      "fetched_at" => Time.current.iso8601,
      "weather" => { "current" => { "temp_c" => 21.5 } }
    }.to_json
  end

  let(:msg) { double("NATS message", data: msg_data) }

  before do
    allow(NATS::IO::Client).to receive(:new).and_return(nats)
    allow(nats).to receive(:connect)
    allow(nats).to receive(:jetstream).and_return(jetstream)
    allow(jetstream).to receive(:add_consumer)
    allow(jetstream).to receive(:pull_subscribe).and_return(pull_sub)
    allow(pull_sub).to receive(:fetch).and_return([msg])
    allow(msg).to receive(:ack) { true }
  end

  describe "#sync" do
    let(:service) { WeatherSyncService.new }

    it "fetches messages and saves them to Postgres" do
      expect {
        service.sync(limit: 1)
      }.to change { City.count }.by(1)
       .and change { WeatherRecord.count }.by(1)

      city = City.last
      record = WeatherRecord.last
      data = JSON.parse(msg_data)

      expect(city.name).to eq(data["city"])
      expect(record.temp_c).to eq(data.dig("weather", "current", "temp_c"))
      expect(record.city).to eq(city)
      expect(record.fetched_at.iso8601).to eq(data["fetched_at"])
    end

    it "acks messages after saving" do
      expect(msg).to receive(:ack)
      service.sync(limit: 1)
    end

    it "logs error if save_to_postgres fails" do
      allow_any_instance_of(WeatherSyncService).to receive(:save_to_postgres).and_raise(StandardError, "fail")
      expect(Rails.logger).to receive(:warn).with(/Postgres save error: fail/)
      service.sync(limit: 1)
    end

    it "logs error if NATS fetch fails" do
      allow(pull_sub).to receive(:fetch).and_raise(StandardError, "nats fail")
      expect(Rails.logger).to receive(:warn).with(/NATS sync error: nats fail/)
      service.sync(limit: 1)
    end
  end

  describe "#initialize" do
    it "connects to NATS and creates a consumer normally" do
      expect(jetstream).to receive(:add_consumer)
      WeatherSyncService.new
    end

    it "logs error if NATS connection fails" do
      allow(NATS::IO::Client).to receive(:new).and_raise(StandardError, "connection fail")
      expect(Rails.logger).to receive(:warn).with(/NATS connection error: connection fail/)
      WeatherSyncService.new
    end

    it "logs warning if consumer already exists" do
      allow(jetstream).to receive(:add_consumer).and_raise(StandardError, "consumer exists")
      expect(Rails.logger).to receive(:warn).with(/Consumer may already exist: consumer exists/)
      WeatherSyncService.new
    end
  end
end
