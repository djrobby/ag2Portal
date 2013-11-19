class AddExpirationToTaxTypes < ActiveRecord::Migration
  def change
    add_column :tax_types, :expiration, :date
  end
end
