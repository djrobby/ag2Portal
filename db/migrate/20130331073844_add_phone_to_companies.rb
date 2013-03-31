class AddPhoneToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :phone, :string
    add_column :companies, :fax, :string
    add_column :companies, :cellular, :string
    add_column :companies, :email, :string
  end
end
