class AddCreatedByToTaxTypes < ActiveRecord::Migration
  def change
    add_column :tax_types, :created_by, :integer
    add_column :tax_types, :updated_by, :integer
  end
end
