class City < ApplicationRecord
  has_many :weather_records, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[id name created_at updated_at]
  end
end
