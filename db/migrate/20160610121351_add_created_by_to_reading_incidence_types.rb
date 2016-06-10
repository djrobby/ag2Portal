class AddCreatedByToReadingIncidenceTypes < ActiveRecord::Migration
  def change
    add_column :reading_incidence_types, :created_by, :integer
    add_column :reading_incidence_types, :updated_by, :integer
  end
end
