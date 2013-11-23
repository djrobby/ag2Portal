class AddCreatedByToSexes < ActiveRecord::Migration
  def change
    add_column :sexes, :created_by, :integer
    add_column :sexes, :updated_by, :integer
  end
end
