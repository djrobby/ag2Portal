class CreateWithholdingTypes < ActiveRecord::Migration
  def change
    create_table :withholding_types do |t|
      t.string :description
      t.decimal :tax, :precision => 6, :scale => 2, :null => false, :default => '0'
      t.date :expiration

      t.timestamps
    end
    add_index :withholding_types, :tax
  end
end
