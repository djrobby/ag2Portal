class AddOldNoToBills < ActiveRecord::Migration
  def change
    add_column :bills, :old_no, :string
    add_index :bills, :old_no
  end
end
