class AddCreatedByToBanks < ActiveRecord::Migration
  def change
    add_column :banks, :created_by, :integer
    add_column :banks, :updated_by, :integer
  end
end
