class AddCreatedByToContractTypes < ActiveRecord::Migration
  def change
    add_column :contract_types, :created_by, :integer
    add_column :contract_types, :updated_by, :integer
  end
end
