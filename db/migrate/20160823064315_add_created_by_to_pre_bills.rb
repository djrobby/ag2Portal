class AddCreatedByToPreBills < ActiveRecord::Migration
  def change
    add_column :pre_bills, :created_by, :integer
    add_column :pre_bills, :updated_by, :integer
  end
end
