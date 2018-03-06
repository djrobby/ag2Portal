class AddRemarksToCashMovements < ActiveRecord::Migration
  def change
    add_column :cash_movements, :remarks, :string
  end
end
