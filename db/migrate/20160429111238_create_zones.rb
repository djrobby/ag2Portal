class CreateZones < ActiveRecord::Migration
  def change
    create_table :zones do |t|
      t.string :name
      t.decimal :max_order_total, :decimal, :precision => 13, :scale => 4, :null => false, :default => '0'
      t.decimal :max_order_price, :decimal, :precision => 12, :scale => 4, :null => false, :default => '0'
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
  end
end
