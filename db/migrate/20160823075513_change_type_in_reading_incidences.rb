class ChangeTypeInReadingIncidences < ActiveRecord::Migration
  def change
    remove_index :reading_incidences, :reading_incidence_id
    remove_column :reading_incidences, :reading_incidence_id

    add_column :reading_incidences, :reading_incidence_type_id, :integer
    add_index :reading_incidences, :reading_incidence_type_id
  end
end
