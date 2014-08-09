class AddOrganizationToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :organization_id, :integer
  end
end
