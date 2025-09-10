class WeatherRecord < ApplicationRecord
  belongs_to :city

  validates :fetched_at, presence: true

  def self.ransackable_attributes(auth_object = nil)
    %w[city_id created_at fetched_at id temp_c updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[city]
  end
end