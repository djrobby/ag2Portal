class AddTaxIndexToTaxTypes < ActiveRecord::Migration
  def change
    add_index :tax_types, :tax
  end
end
