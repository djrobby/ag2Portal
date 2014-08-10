class AddUniqueIndexCodeOrganizationToOffers < ActiveRecord::Migration
  def change
    add_index :offers, :organization_id    
    add_index :offers, [:organization_id, :supplier_id, :offer_no], unique: true
  end
end
