require "sidekiq"
require "sidekiq-cron"

Sidekiq.configure_server do |_config|
  Dir[Rails.root.join("app/workers/*.rb")].each { |file| require file }

  schedule_file = Rails.root.join("config/sidekiq.yml")

  if File.exist?(schedule_file)
    schedule_hash = YAML.load_file(schedule_file)["schedule"] || {}
    Sidekiq::Cron::Job.load_from_hash(schedule_hash) unless schedule_hash.empty?
    Rails.logger.info "[SidekiqCron] Loaded schedule: #{schedule_hash.keys.join(', ')}"
  else
    Rails.logger.warn "[SidekiqCron] No schedule file found at #{schedule_file}"
  end
end
