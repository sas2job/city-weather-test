class WeatherRecord < ApplicationRecord
  belongs_to :city

  validates :fetched_at, presence: true
end