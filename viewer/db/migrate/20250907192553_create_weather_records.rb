class CreateWeatherRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :weather_records do |t|
      t.references :city, null: false, foreign_key: true
      t.float :temp_c
      t.datetime :fetched_at

      t.timestamps
    end
  end
end
