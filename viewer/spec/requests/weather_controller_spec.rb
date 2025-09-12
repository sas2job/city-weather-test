# spec/requests/weather_controller_spec.rb
require "rails_helper"

RSpec.describe WeatherController, type: :request do
  before(:each) do
    WeatherRecord.delete_all
    City.delete_all
  end

  let!(:city1) { City.create!(name: "Moscow") }
  let!(:city2) { City.create!(name: "Saint Petersburg") }

  let!(:record1) { WeatherRecord.create!(city: city1, fetched_at: Time.current.beginning_of_day + 1.hour, temp_c: 20.0) }
  let!(:record2) { WeatherRecord.create!(city: city2, fetched_at: Time.current.beginning_of_day + 2.hours, temp_c: 15.5) }
  let!(:record3) { WeatherRecord.create!(city: city1, fetched_at: Time.current.beginning_of_day + 3.hours, temp_c: 22.0) }
  let!(:old_record) { WeatherRecord.create!(city: city1, fetched_at: 1.day.ago, temp_c: 10.0) }

  describe "GET /" do
    it "returns success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "assigns only today's weather records" do
      get root_path
      html = Nokogiri::HTML(response.body)

      rows = html.css("table tbody tr").map do |tr|
        city_name  = tr.css("td:first-child").text.strip
        fetched_at = tr.css("td:nth-child(3)").text.strip
        [city_name, fetched_at]
      end

      city_names = rows.map(&:first).uniq
      expect(city_names).to include("Moscow", "Saint Petersburg")

      dates = rows.map(&:last)
      expect(dates).not_to include(old_record.fetched_at.strftime("%d %b %H:%M"))

      expect(rows.size).to eq(3)
    end


    it "orders records by city ASC, then fetched_at DESC" do
      get root_path
      html = Nokogiri::HTML(response.body)

      rows = html.css("table tbody tr").map do |tr|
        city_name  = tr.css("td:first-child").text.strip
        fetched_at = tr.css("td:nth-child(3)").text.strip
        [city_name, fetched_at]
      end

      city_order = rows.map(&:first).uniq
      expect(city_order).to eq(["Moscow", "Saint Petersburg"])

      rows.group_by(&:first).each do |_city, city_rows|
        times = city_rows.map { |(_, time)| Time.zone.parse(time) }
        expect(times).to eq(times.sort.reverse)
      end
    end

    it "applies ransack filtering" do
      get root_path, params: { q: { city_name_eq: "Moscow" } }
      html = Nokogiri::HTML(response.body)
      cities_in_table = html.css("table tbody tr td:first-child").map { |td| td.text.strip }

      expect(cities_in_table).to all(eq("Moscow"))
      expect(cities_in_table).not_to include("Saint Petersburg")
      expect(cities_in_table.size).to eq(2)
    end
  end
end
