class AddCreatedByToPreReadingIncidences < ActiveRecord::Migration
  def change
    add_column :pre_reading_incidences, :created_by, :integer
    add_column :pre_reading_incidences, :updated_by, :integer
  end
end
