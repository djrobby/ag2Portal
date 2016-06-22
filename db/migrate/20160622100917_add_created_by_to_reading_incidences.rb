class AddCreatedByToReadingIncidences < ActiveRecord::Migration
  def change
    add_column :reading_incidences, :created_by, :integer
    add_column :reading_incidences, :updated_by, :integer
  end
end
