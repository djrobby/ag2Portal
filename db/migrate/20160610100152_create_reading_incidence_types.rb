class CreateReadingIncidenceTypes < ActiveRecord::Migration
  def change
    create_table :reading_incidence_types do |t|
      t.string :name
      t.boolean :should_estimate

      t.timestamps
    end
  end
end
