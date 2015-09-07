class AddCreatedByToBankOffices < ActiveRecord::Migration
  def change
    add_column :bank_offices, :created_by, :integer
    add_column :bank_offices, :updated_by, :integer
  end
end
