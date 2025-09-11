require "rails_helper"

RSpec.describe City, type: :model do
  describe "associations" do
    it { should have_many(:weather_records).dependent(:destroy) }
  end

  describe "validations" do
    subject { described_class.new(name: "Moscow") }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe ".ransackable_attributes" do
    it "returns expected attributes" do
      expect(described_class.ransackable_attributes).to match_array(
        %w[id name created_at updated_at]
      )
    end
  end
end
