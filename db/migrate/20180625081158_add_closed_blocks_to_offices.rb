class AddClosedBlocksToOffices < ActiveRecord::Migration
  def change
    add_column :offices, :closed_blocks, :boolean, null: false, default: true
  end
end
