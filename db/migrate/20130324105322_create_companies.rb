class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :fiscal_id

      t.timestamps
    end
  end
end
