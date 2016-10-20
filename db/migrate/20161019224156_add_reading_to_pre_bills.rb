class AddReadingToPreBills < ActiveRecord::Migration
  def change
    add_column :pre_bills, :reading_1_id, :integer
    add_column :pre_bills, :reading_2_id, :integer
  end
end
