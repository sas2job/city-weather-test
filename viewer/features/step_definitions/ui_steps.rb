Then('I should see {string} in table') do |text|
  rows = page.all('table tbody tr')
  found = rows.any? { |row| row.has_content?(text) }
  expect(found).to be(true), "Expected to find '#{text}' in table, but did not."
end

Then('I should not see {string} in table') do |text|
  rows = page.all('table tbody tr')
  rows.each do |row|
    expect(row).not_to have_content(text), "Expected not to find '#{text}' in row: #{row.text}"
  end
end

When('I select {string} from {string}') do |option, field|
  select(option, from: field)
end

When('I press {string}') do |button|
  click_button(button)
end

Then(/^I should see (\d+) records?$/) do |count|
  rows = page.all('table tbody tr')
  rows = page.all('table tr') if rows.empty?
  expect(rows.count).to eq(count.to_i)
end

Then('I should see only {string} in table') do |city|
  rows = page.all('table tbody tr')
  expect(rows).not_to be_empty, "Table has no rows"
  rows.each do |row|
    expect(row).to have_content(city), "Expected row to have city '#{city}', but got: #{row.text}"
  end
end
