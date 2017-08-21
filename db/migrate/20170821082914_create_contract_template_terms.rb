class CreateContractTemplateTerms < ActiveRecord::Migration
  def change
    create_table :contract_template_terms do |t|
      t.references :contract_template
      t.integer :term_type, limit: 2, null: false, default: 0
      t.text :description

      t.timestamps
    end
    add_index :contract_template_terms, :contract_template_id
    add_index :contract_template_terms, :term_type
  end
end
