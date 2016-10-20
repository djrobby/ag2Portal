class AddReadingToBills < ActiveRecord::Migration
  def change
    add_column :bills, :reading_1_id, :integer
    add_column :bills, :reading_2_id, :integer
  end
end
