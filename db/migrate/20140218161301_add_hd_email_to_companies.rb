class AddHdEmailToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :hd_email, :string
    add_column :organizations, :hd_email, :string
  end
end
