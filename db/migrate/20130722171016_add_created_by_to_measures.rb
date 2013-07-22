class AddCreatedByToMeasures < ActiveRecord::Migration
  def change
    add_column :measures, :created_by, :string
    add_column :measures, :updated_by, :string
  end
end
