class AddCreatedByToWithholdingTypes < ActiveRecord::Migration
  def change
    add_column :withholding_types, :created_by, :integer
    add_column :withholding_types, :updated_by, :integer
  end
end
