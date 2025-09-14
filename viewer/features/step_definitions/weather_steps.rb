DEBUG_MODE = ENV['DEBUG_CUCUMBER'] == 'true'

Given('the following cities exist:') do |table|
  table.hashes.each do |row|
    puts "[DEBUG] Creating city: #{row.inspect}" if DEBUG_MODE
    City.create!(row)
  end
end

Given('the following weather records exist:') do |table|
  table.hashes.each do |row|
    puts "[DEBUG] Raw weather row: #{row.inspect}" if DEBUG_MODE
    WeatherRecord.create!(
      city: City.find_by!(name: row['city']),
      temp_c: row['temp_c'],
      fetched_at: row['fetched_at']
    )
    puts "[DEBUG] Saved WeatherRecord OK" if DEBUG_MODE
  end
end

When('I go to the weather records page') do
  visit root_path
end
