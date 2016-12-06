class AddBillToReadings < ActiveRecord::Migration
  def change
    add_column :readings, :bill_id, :integer

    add_index :readings, :bill_id
  end
end
