class AddCreatedByToContractTemplates < ActiveRecord::Migration
  def change
    add_column :contract_templates, :created_by, :integer
    add_column :contract_templates, :updated_by, :integer
  end
end
