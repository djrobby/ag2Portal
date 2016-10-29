class AddMainToReadingIncidenceTypes < ActiveRecord::Migration
  def change
    add_column :reading_incidence_types, :is_main, :boolean
    add_column :reading_incidence_types, :code, :string, :limit => 2

    add_index :reading_incidence_types, :code
  end
end
