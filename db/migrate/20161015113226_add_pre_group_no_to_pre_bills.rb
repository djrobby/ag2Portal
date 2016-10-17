class AddPreGroupNoToPreBills < ActiveRecord::Migration
  def change
    add_column :pre_bills, :pre_group_no, :integer
  end
end
