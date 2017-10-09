class AddOfficeToDebtClaims < ActiveRecord::Migration
  def change
    add_column :debt_claims, :office_id, :integer

    add_index :debt_claims, :office_id
  end
end
