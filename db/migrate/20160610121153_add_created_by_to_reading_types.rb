class AddCreatedByToReadingTypes < ActiveRecord::Migration
  def change
    add_column :reading_types, :created_by, :integer
    add_column :reading_types, :updated_by, :integer
  end
end
