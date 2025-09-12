require "rails_helper"

RSpec.describe WeatherSyncWorker, type: :worker do
  describe "#perform" do
    it "calls WeatherSyncService with limit: 50" do
      service = instance_double(WeatherSyncService)
      allow(WeatherSyncService).to receive(:new).and_return(service)
      allow(service).to receive(:sync)

      described_class.new.perform

      expect(service).to have_received(:sync).with(limit: 50)
    end
  end
end
