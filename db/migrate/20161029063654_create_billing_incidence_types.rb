class CreateBillingIncidenceTypes < ActiveRecord::Migration
  def change
    create_table :billing_incidence_types do |t|
      t.string :name
      t.boolean :is_main
      t.string :code, :limit => 2

      t.timestamps
    end
    add_index :billing_incidence_types, :code
  end
end
