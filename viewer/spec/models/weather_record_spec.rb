# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeatherRecord, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:city) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:fetched_at) }
  end

  describe ".ransackable_attributes" do
    it "returns only allowed attributes" do
      expect(described_class.ransackable_attributes).to match_array(
        %w[city_id created_at fetched_at id temp_c updated_at]
      )
    end
  end

  describe ".ransackable_associations" do
    it "returns only allowed associations" do
      expect(described_class.ransackable_associations).to match_array(%w[city])
    end
  end
end
