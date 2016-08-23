class CreatePreReadingIncidences < ActiveRecord::Migration
  def change
    create_table :pre_reading_incidences do |t|
      t.references :pre_reading, index: true
      t.references :reading_incidence_type, index: true

      t.timestamps
    end
  end
end
