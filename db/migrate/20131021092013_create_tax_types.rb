class CreateTaxTypes < ActiveRecord::Migration
  def change
    create_table :tax_types do |t|
      t.string :description
      t.decimal :tax, :precision => 6, :scale => 2, :null => false, :default => '0'

      t.timestamps
    end
  end
end
