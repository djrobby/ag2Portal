class AddCreatedByToDegreeTypes < ActiveRecord::Migration
  def change
    add_column :degree_types, :created_by, :integer
    add_column :degree_types, :updated_by, :integer
  end
end
