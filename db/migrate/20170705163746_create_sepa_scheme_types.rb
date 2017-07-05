class CreateSepaSchemeTypes < ActiveRecord::Migration
  def change
    create_table :sepa_scheme_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
