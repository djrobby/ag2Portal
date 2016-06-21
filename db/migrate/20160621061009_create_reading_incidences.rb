class CreateReadingIncidences < ActiveRecord::Migration
  def change
    create_table :reading_incidences do |t|
      t.references :reading
      t.references :reading_incidence

      t.timestamps
    end
    add_index :reading_incidences, :reading_id
    add_index :reading_incidences, :reading_incidence_id
  end
end
