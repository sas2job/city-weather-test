require "spec_helper"
require_relative "../../lib/weather_api_client"
require "net/http"

RSpec.describe WeatherApiClient do
  let(:api_key) { "test_api_key" }
  let(:city) { "Moscow" }
  let(:client) { described_class.new(api_key: api_key) }

  describe "#fetch_weather" do
    let(:url) { URI("http://api.weatherapi.com/v1/forecast.json?key=#{api_key}&q=#{city}&hours=1") }

    context "when API returns success" do
      let(:response_body) { { "location" => { "name" => city }, "forecast" => {} }.to_json }
      let(:http_response) do
        instance_double(Net::HTTPOK, body: response_body, code: "200", is_a?: true)
      end

      before do
        allow(Net::HTTP).to receive(:get_response).with(url).and_return(http_response)
      end

      it "calls the correct URL" do
        client.fetch_weather(city)
        expect(Net::HTTP).to have_received(:get_response).with(url)
      end

      it "parses JSON response" do
        result = client.fetch_weather(city)
        expect(result["location"]["name"]).to eq(city)
      end
    end

    context "when API returns error" do
      let(:http_response) do
        instance_double(Net::HTTPResponse, code: "500", is_a?: false)
      end

      before do
        allow(Net::HTTP).to receive(:get_response).with(url).and_return(http_response)
      end

      it "raises an error" do
        expect { client.fetch_weather(city) }.to raise_error("Weather API error: 500")
      end
    end
  end
end
 
