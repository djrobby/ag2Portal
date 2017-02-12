class ChangeActiveInProducts < ActiveRecord::Migration
  def change
    change_column :products, :active, :boolean, null: false, default: true
  end
end
