class AddCreatedByToContractedTariffs < ActiveRecord::Migration
  def change
    add_column :contracted_tariffs, :created_by, :integer
    add_column :contracted_tariffs, :updated_by, :integer
  end
end
