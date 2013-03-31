class AddIndexOnFiscalIdToCompanies < ActiveRecord::Migration
  def change
    add_index :companies, :fiscal_id
  end
end
