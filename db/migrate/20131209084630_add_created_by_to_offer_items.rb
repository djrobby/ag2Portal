class AddCreatedByToOfferItems < ActiveRecord::Migration
  def change
    add_column :offer_items, :created_by, :integer
    add_column :offer_items, :updated_by, :integer
  end
end
