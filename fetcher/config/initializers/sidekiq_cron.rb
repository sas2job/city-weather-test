require "sidekiq"
require "sidekiq-cron"
require_relative "../../workers/weather_worker"

schedule_file = File.expand_path("../sidekiq.yml", __dir__)

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)["cron"]
end
