# frozen_string_literal: true

require "spec_helper"
require_relative "../../workers/weather_worker"

RSpec.describe WeatherWorker do
  describe "#perform" do
    let(:logger) { instance_double(Logger) }
    let(:weather_service) { instance_double(WeatherService) }

    before do
      stub_const("#{described_class}::LOGGER", logger)

      allow(WeatherService).to receive(:new).and_return(weather_service)
      allow(weather_service).to receive(:run)

      allow(logger).to receive(:info)
    end

    it "calls WeatherService.run" do
      described_class.new.perform
      expect(weather_service).to have_received(:run)
    end

    it "logs a message when running" do
      described_class.new.perform
      expect(logger).to have_received(:info).with(/WeatherWorker.*running/)
    end
  end
end
