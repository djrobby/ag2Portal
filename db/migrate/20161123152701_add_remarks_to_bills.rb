class AddRemarksToBills < ActiveRecord::Migration
  def change
    add_column :bills, :remarks, :string
  end
end
