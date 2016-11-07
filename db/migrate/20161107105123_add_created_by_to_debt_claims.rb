class AddCreatedByToDebtClaims < ActiveRecord::Migration
  def change
    add_column :debt_claims, :created_by, :integer
    add_column :debt_claims, :updated_by, :integer
  end
end
