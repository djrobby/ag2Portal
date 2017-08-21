class AddNoToContractTemplateTerms < ActiveRecord::Migration
  def change
    add_column :contract_template_terms, :term_no, :string, :limit => 4

    add_index :contract_template_terms, :term_no
  end
end
