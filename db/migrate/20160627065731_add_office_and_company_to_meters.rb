class AddOfficeAndCompanyToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :company_id, :integer
    add_column :meters, :office_id, :integer

    add_index :meters, :company_id
    add_index :meters, :office_id
  end
end
