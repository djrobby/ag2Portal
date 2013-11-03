class AddCreatedByToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :created_by, :integer
    add_column :stocks, :updated_by, :integer
  end
end
