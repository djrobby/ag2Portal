class AddCreatedByToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :created_by, :integer
    add_column :currencies, :updated_by, :integer
  end
end
