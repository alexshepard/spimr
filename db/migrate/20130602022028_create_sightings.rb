class CreateSightings < ActiveRecord::Migration
  def change
    create_table :sightings do |t|
      t.integer :spime_id, :presence => true
      t.string :location_name
      t.float :latitude
      t.float :longitude
      t.string :finder_person_name
      t.timestamp :date

      t.timestamps
    end
  end
end
