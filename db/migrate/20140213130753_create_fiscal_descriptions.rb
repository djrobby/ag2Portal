class CreateFiscalDescriptions < ActiveRecord::Migration
  def change
    create_table :fiscal_descriptions do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :fiscal_descriptions, :code, unique: true
  end
end
