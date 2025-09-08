class City < ApplicationRecord
  has_many :weather_records, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
