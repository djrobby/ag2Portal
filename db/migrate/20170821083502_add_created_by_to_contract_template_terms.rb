class AddCreatedByToContractTemplateTerms < ActiveRecord::Migration
  def change
    add_column :contract_template_terms, :created_by, :integer
    add_column :contract_template_terms, :updated_by, :integer
  end
end
