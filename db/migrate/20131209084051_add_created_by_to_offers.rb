class AddCreatedByToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :created_by, :integer
    add_column :offers, :updated_by, :integer
  end
end
