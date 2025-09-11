# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/weather_service"

RSpec.describe WeatherService do
  let(:logger) { instance_double(Logger) }
  let(:client) { instance_double(WeatherApiClient) }
  let(:storage) { instance_double(WeatherStorage) }
  let(:cities) { ["Moscow", "Saint Petersburg"] }
  let(:weather_data) { { "current" => { "temp_c" => 20 } } }

  subject(:service) { described_class.new(api_key: "test-key") }

  before do
    stub_const("#{described_class}::LOGGER", logger)
    allow(logger).to receive(:info)

    allow(WeatherApiClient).to receive(:new).and_return(client)
    allow(WeatherStorage).to receive(:new).and_return(storage)

    allow(client).to receive(:fetch_weather).and_return(weather_data)
    allow(storage).to receive(:save)
    allow(storage).to receive(:close)

    allow(YAML).to receive(:load_file).and_return({ "default_cities" => cities })
  end

  describe "#run" do
    it "fetches weather for each city" do
      service.run
      expect(client).to have_received(:fetch_weather).with("Moscow")
      expect(client).to have_received(:fetch_weather).with("Saint Petersburg")
    end

    it "saves weather data for each city" do
      service.run
      expect(storage).to have_received(:save).with("Moscow", weather_data)
      expect(storage).to have_received(:save).with("Saint Petersburg", weather_data)
    end

    it "logs fetched temperature for each city" do
      service.run
      expect(logger).to have_received(:info).with(/Fetched for Moscow: 20°C/)
      expect(logger).to have_received(:info).with(/Fetched for Saint Petersburg: 20°C/)
    end

    it "closes storage after run" do
      service.run
      expect(storage).to have_received(:close)
    end
  end
end
