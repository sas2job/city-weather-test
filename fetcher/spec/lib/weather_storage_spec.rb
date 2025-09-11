# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/weather_storage"

RSpec.describe WeatherStorage do
  let(:logger) { instance_double(Logger) }
  let(:nats_client) { instance_double(NATS::IO::Client) }
  let(:jetstream) { instance_double("JetStream") }
  let(:subscription) { instance_double("Subscription") }

  before do
    stub_const("#{described_class}::LOGGER", logger)
    allow(logger).to receive(:info)
    allow(logger).to receive(:error)
    allow(logger).to receive(:warn)

    allow(NATS::IO::Client).to receive(:new).and_return(nats_client)
    allow(nats_client).to receive(:connect)
    allow(nats_client).to receive(:jetstream).and_return(jetstream)
    allow(nats_client).to receive(:close)

    allow(jetstream).to receive(:add_stream)
  end

  describe "#initialize" do
    it "connects to NATS and ensures stream" do
      described_class.new
      expect(logger).to have_received(:info).with(/Connecting to NATS server/)
      expect(jetstream).to have_received(:add_stream).with(name: "WEATHER", subjects: ["weather.data"])
    end

    it "logs a warning if stream already exists" do
      allow(jetstream).to receive(:add_stream).and_raise("already exists")
      described_class.new
      expect(logger).to have_received(:warn).with(/Stream WEATHER may already exist: already exists/)
    end
  end

  describe "#save" do
    let(:storage) { described_class.new }

    before do
      allow(jetstream).to receive(:publish)
    end

    it "publishes weather data to JetStream" do
      storage.save("Moscow", { "temp" => 20 })
      expect(jetstream).to have_received(:publish).with("weather.data", kind_of(String))
      expect(logger).to have_received(:info).with(/Saved weather data for Moscow/)
    end

    it "logs error when publish fails" do
      allow(jetstream).to receive(:publish).and_raise("publish error")
      storage.save("Moscow", { "temp" => 20 })
      expect(logger).to have_received(:error).with(/Error while saving to JetStream: publish error/)
    end
  end

  describe "#read_all" do
    let(:storage) { described_class.new }
    let(:msg1) { double("Msg", data: { city: "Moscow" }.to_json, ack: true) }
    let(:msg2) { double("Msg", data: { city: "Saint Petersburg" }.to_json, ack: true) }

    before do
      allow(jetstream).to receive(:pull_subscribe).and_return(subscription)
    end

    it "returns parsed messages from JetStream" do
      allow(subscription).to receive(:fetch).and_return([msg1, msg2])
      result = storage.read_all
      expect(result).to eq([{ "city" => "Moscow" }, { "city" => "Saint Petersburg" }])
    end

    it "logs error if fetch fails" do
      allow(subscription).to receive(:fetch).and_raise("fetch error")
      result = storage.read_all
      expect(result).to eq([])
      expect(logger).to have_received(:error).with(/Error while reading from JetStream: fetch error/)
    end
  end

  describe "#close" do
    it "closes NATS client" do
      storage = described_class.new
      storage.close
      expect(nats_client).to have_received(:close)
    end
  end
end
