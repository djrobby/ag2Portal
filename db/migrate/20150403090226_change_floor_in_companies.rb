class ChangeFloorInCompanies < ActiveRecord::Migration
  def change
    change_column :companies, :floor, :string
  end
end
