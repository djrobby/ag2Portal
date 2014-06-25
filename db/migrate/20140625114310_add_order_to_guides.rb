class AddOrderToGuides < ActiveRecord::Migration
  def change
    add_column :guides, :sort_order, :integer

    add_index :guides, :sort_order
  end
end
